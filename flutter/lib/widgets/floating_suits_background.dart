import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

// ---------------------------------------------------------------------------
// Usage:
//
//   MaterialApp(
//     home: SuitsBackgroundWrapper(
//       child: YourHomeScreen(),
//     ),
//   );
//
// Or wrap any subtree:
//
//   SuitsBackgroundWrapper(
//     backgroundColor: Colors.white,
//     particleCount: 150,   // target count at the reference screen area
//     child: Scaffold(...),
//   )
//
// particleCount is the target density at _kReferenceArea (1080 × 1920).
// Larger/smaller screens get proportionally more/fewer particles so visual
// density stays constant regardless of window size.
// ---------------------------------------------------------------------------

/// Reference area used to normalise particle density (1080 × 1920 px).
const double _kReferenceArea = 1080.0 * 1920.0;

class SuitsBackgroundWrapper extends StatelessWidget {
  const SuitsBackgroundWrapper({
    super.key,
    required this.child,
    this.backgroundColor = const Color(0xFFF0F7F0),
    this.particleCount = 200,
    this.blurSigma = 2.5,
  });

  final Widget child;
  final Color backgroundColor;

  /// Particle count at the 1080 × 1920 reference resolution.
  final int particleCount;
  final double blurSigma;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: backgroundColor,
      child: Stack(
        children: [
          FloatingSuitsBackground(referenceParticleCount: particleCount),
          Positioned.fill(
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
              child: Container(color: Colors.transparent),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Suit color mapping
// ---------------------------------------------------------------------------
const _suitBaseColors = {
  '♠': Color(0xFF1A1A1A),
  '♣': Color(0xFF1A1A1A),
  '♥': Color(0xFFCC0000),
  '♦': Color(0xFFCC0000),
};

// ---------------------------------------------------------------------------
// Pre-rasterized glyph cache (owned by the engine, lives for its lifetime)
// ---------------------------------------------------------------------------
class _GlyphCache {
  final Map<String, ({ui.Image image, double halfW, double halfH})> _cache = {};

  bool get isWarmedUp => _cache.isNotEmpty;

  Future<void> warmUp(
    List<({String suit, double fontSize, double opacity})> specs,
  ) async {
    for (final s in specs) {
      await _getOrCreate(s.suit, s.fontSize, s.opacity);
    }
  }

  ({ui.Image image, double halfW, double halfH})? get(
    String suit,
    double fontSize,
    double opacity,
  ) =>
      _cache[_key(suit, fontSize, opacity)];

  String _key(String suit, double fontSize, double opacity) =>
      '${suit}_${fontSize.round()}_${(opacity * 100).round()}';

  Future<({ui.Image image, double halfW, double halfH})> _getOrCreate(
    String suit,
    double fontSize,
    double opacity,
  ) async {
    final k = _key(suit, fontSize, opacity);
    if (_cache.containsKey(k)) return _cache[k]!;

    final baseColor = _suitBaseColors[suit] ?? const Color(0xFF1A1A1A);

    final tp = TextPainter(
      text: TextSpan(
        text: suit,
        style: TextStyle(
          fontSize: fontSize,
          color: baseColor.withValues(alpha: opacity),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final pad = fontSize * 0.2;
    final w = tp.width + pad * 2;
    final h = tp.height + pad * 2;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    tp.paint(canvas, Offset(pad, pad));
    final picture = recorder.endRecording();
    final image = await picture.toImage(w.ceil(), h.ceil());
    picture.dispose();
    tp.dispose();

    final entry = (image: image, halfW: w / 2, halfH: h / 2);
    _cache[k] = entry;
    return entry;
  }

  /// Pick a random cached entry matching [suit].
  ({ui.Image image, double halfW, double halfH}) random(
    String suit,
    List<double> sizes,
    List<double> opacities,
    Random rng,
  ) {
    final sz = sizes[rng.nextInt(sizes.length)];
    final op = opacities[rng.nextInt(opacities.length)];
    return get(suit, sz, op)!;
  }

  void dispose() {
    for (final e in _cache.values) {
      e.image.dispose();
    }
    _cache.clear();
  }
}

// ---------------------------------------------------------------------------
// Particle
// ---------------------------------------------------------------------------
class _SuitParticle {
  double x, y, vx, vy, rotation, rotationSpeed;
  ui.Image image;
  double halfW, halfH;

  _SuitParticle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.rotation,
    required this.rotationSpeed,
    required this.image,
    required this.halfW,
    required this.halfH,
  });
}

// ---------------------------------------------------------------------------
// Engine
// ---------------------------------------------------------------------------
class _SuitParticleEngine extends ChangeNotifier {
  _SuitParticleEngine({required int referenceParticleCount})
    : _referenceCount = referenceParticleCount;

  final List<_SuitParticle> particles = [];
  final Random _rng = Random();
  final _GlyphCache _cache = _GlyphCache();

  double _w = 0, _h = 0;
  final int _referenceCount;

  bool get _ready => _cache.isWarmedUp;

  static const _suits = ['♠', '♥', '♦', '♣'];
  static const _sizes = [12.0, 16.0, 20.0, 26.0, 32.0];
  static const _opacities = [0.06, 0.12, 0.18, 0.24, 0.30];

  // ── First call: warm up the glyph cache then spawn all particles ──────────
  Future<void> initialize(Size size) async {
    _w = size.width;
    _h = size.height;

    if (!_cache.isWarmedUp) {
      final specs = <({String suit, double fontSize, double opacity})>[];
      for (final suit in _suits) {
        for (final sz in _sizes) {
          for (final op in _opacities) {
            specs.add((suit: suit, fontSize: sz, opacity: op));
          }
        }
      }
      await _cache.warmUp(specs);
    }

    final target = _targetCount(size);
    particles.clear();
    for (int i = 0; i < target; i++) {
      particles.add(_makeParticle(randomY: true));
    }
  }

  // ── Called whenever the widget is laid out at a new size ─────────────────
  //
  // • Updates the boundary so the update loop wraps correctly.
  // • Scales particle count proportionally to screen area.
  // • Existing particles that are still on-screen keep their state (no pop).
  // • Off-screen particles (after shrink) are removed; new ones are added at
  //   a random position when growing.
  void resize(Size size) {
    if (!_ready) return;
    if (size.width == _w && size.height == _h) return;

    final oldW = _w;
    final oldH = _h;
    _w = size.width;
    _h = size.height;

    // Re-map existing particle positions proportionally so they stay
    // visually in the same relative location after resize.
    for (final p in particles) {
      if (oldW > 0) p.x = p.x * (_w / oldW);
      if (oldH > 0) p.y = p.y * (_h / oldH);
    }

    final target = _targetCount(size);

    if (particles.length > target) {
      // Remove excess particles from the end (arbitrary but stable).
      particles.removeRange(target, particles.length);
    } else {
      // Add new particles spread randomly across the screen.
      while (particles.length < target) {
        particles.add(_makeParticle(randomY: true));
      }
    }
  }

  int _targetCount(Size size) {
    final area = size.width * size.height;
    // Scale linearly with area; clamp to at least 1.
    return max(1, (_referenceCount * area / _kReferenceArea).round());
  }

  _SuitParticle _makeParticle({required bool randomY}) {
    final suit = _suits[_rng.nextInt(_suits.length)];
    final entry = _cache.random(suit, _sizes, _opacities, _rng);
    return _SuitParticle(
      x: _rng.nextDouble() * _w,
      y: randomY ? _rng.nextDouble() * _h : -30,
      vx: (_rng.nextDouble() - 0.5) * 6,
      vy: _rng.nextDouble() * 10 + 6,
      rotation: _rng.nextDouble() * pi * 2,
      rotationSpeed: (_rng.nextDouble() - 0.5) * 0.4,
      image: entry.image,
      halfW: entry.halfW,
      halfH: entry.halfH,
    );
  }

  void update(double dt) {
    if (!_ready) return;
    final safeDt = dt.clamp(0.0, 0.05);
    for (final p in particles) {
      p.x += p.vx * safeDt;
      p.y += p.vy * safeDt;
      p.rotation += p.rotationSpeed * safeDt;

      if (p.y > _h + 30) {
        p.x = _rng.nextDouble() * _w;
        p.y = -30;
      }
      if (p.x < -30) p.x = _w + 30;
      if (p.x > _w + 30) p.x = -30;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _cache.dispose();
    super.dispose();
  }
}

// ---------------------------------------------------------------------------
// Painter
// ---------------------------------------------------------------------------
class _SuitParticlePainter extends CustomPainter {
  final _SuitParticleEngine engine;
  final Paint _paint = Paint()..isAntiAlias = false;

  _SuitParticlePainter(this.engine) : super(repaint: engine);

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in engine.particles) {
      canvas.save();
      canvas.translate(p.x, p.y);
      canvas.rotate(p.rotation);
      canvas.drawImage(p.image, Offset(-p.halfW, -p.halfH), _paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _SuitParticlePainter old) => true;
}

// ---------------------------------------------------------------------------
// Widget (internal — use SuitsBackgroundWrapper publicly)
// ---------------------------------------------------------------------------
class FloatingSuitsBackground extends StatefulWidget {
  const FloatingSuitsBackground({
    super.key,
    this.referenceParticleCount = 200,
  });

  /// Particle count at the 1080 × 1920 reference resolution.
  final int referenceParticleCount;

  @override
  State<FloatingSuitsBackground> createState() =>
      _FloatingSuitsBackgroundState();
}

class _FloatingSuitsBackgroundState extends State<FloatingSuitsBackground>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  late final _SuitParticleEngine _engine;
  Duration _lastTime = Duration.zero;
  bool _firstTick = true;

  // Tracks the last laid-out size so we only call resize() on actual changes.
  Size _lastSize = Size.zero;

  // Future that completes once the glyph cache is warm and particles are
  // spawned for the first time.
  late Future<void> _ready;
  bool _readyCompleted = false;

  @override
  void initState() {
    super.initState();
    _engine = _SuitParticleEngine(
      referenceParticleCount: widget.referenceParticleCount,
    );
    _ticker = createTicker(_tick)..start();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_readyCompleted) {
      // Kick off the async warm-up using the current MediaQuery size as a
      // first approximation; LayoutBuilder will refine it once built.
      final size = MediaQuery.of(context).size;
      _ready = _engine.initialize(size).then((_) {
        _readyCompleted = true;
        _lastSize = size;
      });
    }
  }

  void _tick(Duration elapsed) {
    if (_firstTick) {
      _firstTick = false;
      _lastTime = elapsed;
      return;
    }
    final dt =
        (elapsed - _lastTime).inMicroseconds / Duration.microsecondsPerSecond;
    _lastTime = elapsed;
    _engine.update(dt);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _ready,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const SizedBox.expand();
        }
        return LayoutBuilder(
          builder: (context, constraints) {
            final size = constraints.biggest;

            // Notify the engine of any size change outside the paint phase.
            if (size != _lastSize) {
              _lastSize = size;
              // Schedule after layout so we don't mutate state mid-build.
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _engine.resize(size);
              });
            }

            return CustomPaint(
              size: size,
              painter: _SuitParticlePainter(_engine),
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _ticker.dispose();
    _engine.dispose();
    super.dispose();
  }
}
