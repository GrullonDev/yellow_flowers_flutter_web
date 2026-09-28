import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _rainController;
  List<FallingFlower> _fallingFlowers = [];
  final _random = math.Random();
  late String _nombreDestinatario;

  late Timer _timer;
  Duration _tiempoRestante = Duration.zero;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _rainController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    );

    _nombreDestinatario = obtenerNombrePersonalizado();

    _calcularTiempoRestante();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _calcularTiempoRestante();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _startFlowerShow();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _rainController.dispose();
    _timer.cancel();
    super.dispose();
  }

  void _calcularTiempoRestante() {
    final ahora = DateTime.now();
    var objetivo = DateTime(ahora.year, 9, 21);

    if (ahora.isAfter(objetivo)) {
      objetivo = DateTime(ahora.year + 1, 9, 21);
    }

    setState(() {
      _tiempoRestante = objetivo.difference(ahora);
    });
  }

  void _startYellowFlowersRain() {
    setState(() {
      _fallingFlowers = List.generate(
        30,
        (_) => FallingFlower(
          x: _random.nextDouble(),
          size: 20 + _random.nextDouble() * 20,
          delay: _random.nextDouble() * 0.5,
          spin: (_random.nextDouble() - 0.5) * 4 * math.pi,
          sway: 20 + _random.nextDouble() * 40,
          symbol: _random.nextBool() ? '🌻' : '💛',
        ),
      );
    });
    _rainController.forward(from: 0);
  }

  Widget _buildFlowersRain() {
    return Positioned.fill(
      child: IgnorePointer(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return AnimatedBuilder(
              animation: _rainController,
              builder: (context, _) {
                final t = _rainController.value;
                return Stack(
                  children: _fallingFlowers.map((flower) {
                    // Progreso propio de cada flor según su retraso
                    final p = ((t - flower.delay) / (1 - flower.delay)).clamp(
                      0.0,
                      1.0,
                    );
                    if (p <= 0 || p >= 1) return const SizedBox.shrink();

                    final top =
                        -flower.size +
                        p * (constraints.maxHeight + flower.size * 2);
                    final left =
                        flower.x * constraints.maxWidth +
                        math.sin(p * 2 * math.pi) * flower.sway;

                    return Positioned(
                      top: top,
                      left: left,
                      child: Opacity(
                        opacity: p > 0.85 ? (1 - p) / 0.15 : 1,
                        child: Transform.rotate(
                          angle: p * flower.spin,
                          child: Transform.scale(
                            scale: 0.5 + (p * 1.2).clamp(0.0, 0.5),
                            child: Text(
                              flower.symbol,
                              style: TextStyle(fontSize: flower.size),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _startFlowerShow() {
    _controller.reset();
    _controller.forward();
    _startYellowFlowersRain();
  }

  String obtenerNombrePersonalizado() {
    try {
      final uri = Uri.base;
      final para = uri.queryParameters['para'];
      if (para != null && para.isNotEmpty) {
        return Uri.decodeComponent(para.replaceAll('_', ' '));
      }
    } catch (e) {
      return 'Para mi amor!';
    }
    return 'Para ti';
  }

  Future<void> _compartirPorWhatsApp() async {
    final String urlGif =
        'https://media.giphy.com/media/3oKIPnAiaMCws8nOsE/giphy.gif';
    final String urlImagenFlores =
        'https://images.unsplash.com/photo-1597848212624-a19eb35e2651?auto=format&fit=crop&w=1000&q=80';

    final String urlWebActual = Uri.base.toString();

    final String mensaje =
        '¡Hola! Te comparto esta sorpresa especial de Lluvia de Flores Amarillas 🌻💛\n\n$urlWebActual';

    final urlWhatsApp = Uri.parse(
      'https://api.whatsapp.com/send?text=${Uri.encodeComponent(mensaje)}',
    );

    // 5. Lanzar WhatsApp
    if (await canLaunchUrl(urlWhatsApp)) {
      await launchUrl(urlWhatsApp, mode: LaunchMode.externalApplication);
    } else {
      debugPrint('No se pudo abrir WhatsApp');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Formatear los días, horas, minutos y segundos restantes
    final dias = _tiempoRestante.inDays;
    final horas = _tiempoRestante.inHours % 24;
    final minutos = _tiempoRestante.inMinutes % 60;
    final segundos = _tiempoRestante.inSeconds % 60;

    return InteractiveClickEffect(
      child: Scaffold(
        backgroundColor: const Color(0xFF212121),
        body: Stack(
          children: [
            _buildFlowersRain(),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 180,
                    height: 180,
                    child: AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        return CustomPaint(
                          painter: FlowerPainter(progress: _controller.value),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Lluvia de Flores Amarillas',
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      color: Colors.amberAccent,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _nombreDestinatario,
                    style: const TextStyle(
                      fontSize: 26,
                      fontStyle: FontStyle.italic,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 20,
                      ),
                    ),
                    onPressed: () {
                      _startFlowerShow();
                    },
                    child: const Text(
                      '¡Admirar la flor!',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Haz clic o toca en cualquier parte ✨',
                    style: TextStyle(color: Colors.white38, fontSize: 13),
                  ),
                ],
              ),
            ),

            // 🌻 Cuenta regresiva posicionada en la esquina superior derecha
            Positioned(
              top: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.amber.withValues(alpha: 0.4),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      '🌻 Faltan para el 21 de Septiembre:',
                      style: TextStyle(
                        color: Colors.amberAccent,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$dias días, ${horas}h ${minutos}m ${segundos}s',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _compartirPorWhatsApp,
          backgroundColor: Colors.green,
          icon: Icon(Icons.share, color: Colors.white),
          label: Text(
            'Compartir GIF por WhatsApp',
            style: GoogleFonts.gabarito(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

class FlowerPainter extends CustomPainter {
  final double progress;
  FlowerPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    // Escala relativa al tamaño de diseño original (180x180)
    final scale = size.shortestSide / 180;
    final paintPetal = Paint()
      ..color = Colors.amberAccent
      ..style = PaintingStyle.fill;

    final paintCenter = Paint()
      ..color = const Color(0xFF8D5524)
      ..style = PaintingStyle.fill;

    const int totalPetals = 12;
    final petalProgress = (progress / 0.7).clamp(0.0, 1.0);
    final centerProgress = ((progress - 0.7) / 0.3).clamp(0.0, 1.0);

    int petalsToDraw = (totalPetals * petalProgress).floor();
    for (int i = 0; i < petalsToDraw; i++) {
      final double angle = (i * 2 * math.pi) / totalPetals;
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(angle);
      final path = Path();
      path.addOval(
        Rect.fromCenter(
          center: Offset(0, -45 * scale),
          width: 25 * scale,
          height: 55 * scale,
        ),
      );
      canvas.drawPath(path, paintPetal);
      canvas.restore();
    }

    if (centerProgress > 0) {
      canvas.drawCircle(center, 22 * scale * centerProgress, paintCenter);
    }
  }

  @override
  bool shouldRepaint(covariant FlowerPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class InteractiveClickEffect extends StatefulWidget {
  final Widget child;
  const InteractiveClickEffect({super.key, required this.child});

  @override
  InteractiveClickEffectState createState() => InteractiveClickEffectState();
}

class InteractiveClickEffectState extends State<InteractiveClickEffect> {
  final List<Particle> _particles = [];

  void _addParticle(TapDownDetails details) {
    setState(() {
      _particles.add(
        Particle(
          position: details.localPosition,
          symbol: math.Random().nextBool() ? '🌻' : '💛',
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTapDown: _addParticle,
      child: Stack(
        children: [
          widget.child,
          ..._particles.map(
            (particle) => Positioned(
              left: particle.position.dx - 20,
              top: particle.position.dy - 20,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 1000),
                onEnd: () {
                  setState(() {
                    _particles.remove(particle);
                  });
                },
                builder: (context, value, child) {
                  return Opacity(
                    opacity: 1.0 - value,
                    child: Transform.translate(
                      offset: Offset(0, -value * 80),
                      child: Transform.scale(
                        scale: 0.5 + (value * 1.2),
                        child: Text(
                          particle.symbol,
                          style: const TextStyle(fontSize: 28),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FallingFlower {
  final double x; // posición horizontal relativa (0..1)
  final double size;
  final double delay; // retraso relativo (0..1) dentro de la animación
  final double spin; // rotación total durante la caída
  final double sway; // amplitud del balanceo horizontal
  final String symbol;
  FallingFlower({
    required this.x,
    required this.size,
    required this.delay,
    required this.spin,
    required this.sway,
    required this.symbol,
  });
}

class Particle {
  final Offset position;
  final String symbol;
  Particle({required this.position, required this.symbol});
}
