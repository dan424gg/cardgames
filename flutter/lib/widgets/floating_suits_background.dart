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
//     particleCount: 150,
//     child: Scaffold(...),
//   )
// ---------------------------------------------------------------------------

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
  final int particleCount;
  final double blurSigma;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: backgroundColor,
      child: Stack(
        children: [
          FloatingSuitsBackground(particleCount: particleCount),
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
// Pre-rasterized glyph cache
// ---------------------------------------------------------------------------
class _GlyphCache {
  final Map<String, ({ui.Image image, double halfW, double halfH})> _cache = {};

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
  ) => _cache[_key(suit, fontSize, opacity)];

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
  final List<_SuitParticle> particles = [];
  final Random _rng = Random();
  double _w = 0, _h = 0;
  bool _initialized = false;

  static const _suits = ['♠', '♥', '♦', '♣'];
  static const _sizes = [12.0, 16.0, 20.0, 26.0, 32.0];
  static const _opacities = [0.06, 0.12, 0.18, 0.24, 0.30];

  Future<void> initialize(Size size, int count) async {
    if (_initialized) return;
    _initialized = true;
    _w = size.width;
    _h = size.height;

    final cache = _GlyphCache();
    final specs = <({String suit, double fontSize, double opacity})>[];
    for (final suit in _suits) {
      for (final sz in _sizes) {
        for (final op in _opacities) {
          specs.add((suit: suit, fontSize: sz, opacity: op));
        }
      }
    }
    await cache.warmUp(specs);

    for (int i = 0; i < count; i++) {
      final suit = _suits[_rng.nextInt(_suits.length)];
      final sz = _sizes[_rng.nextInt(_sizes.length)];
      final op = _opacities[_rng.nextInt(_opacities.length)];
      final entry = cache.get(suit, sz, op)!;

      particles.add(
        _SuitParticle(
          x: _rng.nextDouble() * _w,
          y: _rng.nextDouble() * _h,
          vx: (_rng.nextDouble() - 0.5) * 6,
          vy: _rng.nextDouble() * 10 + 6,
          rotation: _rng.nextDouble() * pi * 2,
          rotationSpeed: (_rng.nextDouble() - 0.5) * 0.4,
          image: entry.image,
          halfW: entry.halfW,
          halfH: entry.halfH,
        ),
      );
    }
  }

  void update(double dt) {
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
  const FloatingSuitsBackground({super.key, this.particleCount = 200});
  final int particleCount;

  @override
  State<FloatingSuitsBackground> createState() =>
      _FloatingSuitsBackgroundState();
}

class _FloatingSuitsBackgroundState extends State<FloatingSuitsBackground>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  final _engine = _SuitParticleEngine();
  Duration _lastTime = Duration.zero;
  bool _firstTick = true;
  late final Future<void> _ready;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_tick)..start();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final size = MediaQuery.of(context).size;
    _ready = _engine.initialize(size, widget.particleCount);
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
            return CustomPaint(
              size: constraints.biggest,
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
    super.dispose();
  }
}
