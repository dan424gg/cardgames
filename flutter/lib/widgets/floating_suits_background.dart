import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';
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
//
// Platform notes:
//   - All platforms (Web/Chrome, macOS, iOS, Android) use the same
//     CupertinoIcons-based rasterization path via PictureRecorder.
//     This avoids any unicode glyph rendering inconsistencies across
//     platforms and renderers (Skia, Impeller, CanvasKit, HTML).
//   - Icons are pre-rasterized into ui.Image snapshots during initialization
//     and reused every frame for maximum performance.
//   - BackdropFilter is only inserted when blurSigma > 0 to avoid unnecessary
//     compositing layers on Android and web.
// ---------------------------------------------------------------------------

// ---------------------------------------------------------------------------
// Suit definitions — CupertinoIcons + colors
// ---------------------------------------------------------------------------
class _SuitDef {
  final IconData icon;
  final Color color;
  const _SuitDef(this.icon, this.color);
}

const _suitDefs = [
  _SuitDef(CupertinoIcons.suit_spade_fill, Color(0xFF1A1A1A)),
  _SuitDef(CupertinoIcons.suit_club_fill, Color(0xFF1A1A1A)),
  _SuitDef(CupertinoIcons.suit_heart_fill, Color(0xFFCC0000)),
  _SuitDef(CupertinoIcons.suit_diamond_fill, Color(0xFFCC0000)),
];

// ---------------------------------------------------------------------------
// Public wrapper widget
// ---------------------------------------------------------------------------
class SuitsBackgroundWrapper extends StatelessWidget {
  const SuitsBackgroundWrapper({
    super.key,
    required this.child,
    this.backgroundColor = const Color(0xFFF0F7F0),
    this.particleCount = 200,
    this.blurSigma = 1.5,
  });

  final Widget child;
  final Color backgroundColor;
  final int particleCount;
  final double blurSigma;

  @override
  Widget build(BuildContext context) {
    final bool applyBlur = blurSigma > 0.0;

    return ColoredBox(
      color: backgroundColor,
      child: Stack(
        children: [
          FloatingSuitsBackground(particleCount: particleCount),
          if (applyBlur)
            Positioned.fill(
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(
                  sigmaX: blurSigma,
                  sigmaY: blurSigma,
                ),
                child: const ColoredBox(color: Colors.transparent),
              ),
            ),
          child,
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Glyph cache — rasterizes CupertinoIcons via PictureRecorder on all
// platforms (web + native).  No unicode TextPainter involved.
// ---------------------------------------------------------------------------
class _GlyphCache {
  final Map<String, ({ui.Image image, double halfW, double halfH})> _cache = {};

  /// Warm up the cache for every combination of suit × size × opacity.
  Future<void> warmUp(
    List<({_SuitDef def, double iconSize, double opacity})> specs,
  ) async {
    for (final s in specs) {
      await _getOrCreate(s.def, s.iconSize, s.opacity);
    }
  }

  ({ui.Image image, double halfW, double halfH})? get(
    _SuitDef def,
    double iconSize,
    double opacity,
  ) => _cache[_key(def, iconSize, opacity)];

  String _key(_SuitDef def, double iconSize, double opacity) =>
      '${def.icon.codePoint}_${iconSize.round()}_${(opacity * 100).round()}';

  Future<({ui.Image image, double halfW, double halfH})> _getOrCreate(
    _SuitDef def,
    double iconSize,
    double opacity,
  ) async {
    final k = _key(def, iconSize, opacity);
    if (_cache.containsKey(k)) return _cache[k]!;

    // Add padding so rotation doesn't clip corners.
    final pad = iconSize * 0.25;
    final size = iconSize + pad * 2;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    // Draw via a TextPainter using the CupertinoIcons font family.
    // This is a font-glyph lookup by codePoint — not unicode text rendering —
    // so it is fully consistent across all Flutter platforms and renderers
    // (Skia, Impeller, CanvasKit, HTML renderer).
    final tp = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(def.icon.codePoint),
        style: TextStyle(
          fontFamily: def.icon.fontFamily,
          package: def.icon.fontPackage,
          fontSize: iconSize,
          color: def.color.withValues(alpha: opacity),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    // Center the glyph within the padded canvas.
    final dx = (size - tp.width) / 2;
    final dy = (size - tp.height) / 2;
    tp.paint(canvas, Offset(dx, dy));
    tp.dispose();

    final picture = recorder.endRecording();
    final image = await picture.toImage(size.ceil(), size.ceil());
    picture.dispose();

    final entry = (image: image, halfW: size / 2, halfH: size / 2);
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
  double _boundX = 0, _boundY = 0;
  bool _initialized = false;
  _GlyphCache? _cache;

  static const _sizes = [12.0, 16.0, 20.0, 26.0, 32.0];
  static const _opacities = [0.06, 0.12, 0.18, 0.24, 0.30];
  static const double _virtualPad = 2.0;
  static const int _maxVirtualParticles = 4000;

  Future<void> initialize(Size size, int count) async {
    if (_initialized) return;
    _initialized = true;
    _w = size.width;
    _h = size.height;
    _boundX = _w * _virtualPad;
    _boundY = _h * _virtualPad;

    // Build and warm up the glyph cache.
    final cache = _GlyphCache();
    _cache = cache;

    final specs = <({_SuitDef def, double iconSize, double opacity})>[];
    for (final def in _suitDefs) {
      for (final sz in _sizes) {
        for (final op in _opacities) {
          specs.add((def: def, iconSize: sz, opacity: op));
        }
      }
    }
    await cache.warmUp(specs);

    // Spawn particles across the virtual space.
    final vw = _w * _virtualPad * 2;
    final vh = _h * _virtualPad * 2;
    final ox = _w * _virtualPad;
    final oy = _h * _virtualPad;

    final virtualCount = (count * _virtualPad * _virtualPad * 4).round().clamp(
      0,
      _maxVirtualParticles,
    );

    for (int i = 0; i < virtualCount; i++) {
      final def = _suitDefs[_rng.nextInt(_suitDefs.length)];
      final sz = _sizes[_rng.nextInt(_sizes.length)];
      final op = _opacities[_rng.nextInt(_opacities.length)];

      final entry = cache.get(def, sz, op);
      if (entry == null) continue; // shouldn't happen after warmUp

      particles.add(
        _SuitParticle(
          x: _rng.nextDouble() * vw - ox,
          y: _rng.nextDouble() * vh - oy,
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

  void resize(Size size) {
    _w = size.width;
    _h = size.height;
  }

  void update(double dt) {
    final safeDt = dt.clamp(0.0, 0.05);
    for (final p in particles) {
      p.x += p.vx * safeDt;
      p.y += p.vy * safeDt;
      p.rotation += p.rotationSpeed * safeDt;

      if (p.y > _boundY + 30) {
        p.x = (_rng.nextDouble() * 2 - 1) * _boundX;
        p.y = -_boundY - 30;
      }
      if (p.x < -_boundX - 30) p.x = _boundX + 30;
      if (p.x > _boundX + 30) p.x = -_boundX - 30;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _cache?.dispose();
    super.dispose();
  }
}

// ---------------------------------------------------------------------------
// Painter — single unified path for all platforms (pre-rasterized ui.Image)
// ---------------------------------------------------------------------------
class _SuitParticlePainter extends CustomPainter {
  final _SuitParticleEngine engine;
  final Paint _imgPaint = Paint()..isAntiAlias = true;

  _SuitParticlePainter(this.engine) : super(repaint: engine);

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in engine.particles) {
      canvas.save();
      canvas.translate(p.x, p.y);
      canvas.rotate(p.rotation);
      canvas.drawImage(p.image, Offset(-p.halfW, -p.halfH), _imgPaint);
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
  Future<void>? _ready;
  bool _engineInitialized = false;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_tick)..start();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final size = MediaQuery.of(context).size;
    if (!_engineInitialized) {
      _engineInitialized = true;
      _ready = _engine.initialize(size, widget.particleCount);
    } else {
      _engine.resize(size);
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
    _engine.dispose();
    super.dispose();
  }
}
