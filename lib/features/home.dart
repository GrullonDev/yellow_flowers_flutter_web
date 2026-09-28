import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
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
    _timer
        .cancel(); // Importante cancelar el timer para evitar fugas de memoria
    super.dispose();
  }

  void _calcularTiempoRestante() {
    final ahora = DateTime.now();
    // Definimos el 21 de septiembre del año actual
    var objetivo = DateTime(ahora.year, 9, 21);

    // Si ya pasó el 21 de septiembre este año, apuntamos al próximo año
    if (ahora.isAfter(objetivo)) {
      objetivo = DateTime(ahora.year + 1, 9, 21);
    }

    setState(() {
      _tiempoRestante = objetivo.difference(ahora);
    });
  }

  void _startYellowFlowersRain() {
    // Configuración de tu confetti si lo usas
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
        Rect.fromCenter(center: const Offset(0, -45), width: 25, height: 55),
      );
      canvas.drawPath(path, paintPetal);
      canvas.restore();
    }

    if (centerProgress > 0) {
      canvas.drawCircle(center, 22 * centerProgress, paintCenter);
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

class Particle {
  final Offset position;
  final String symbol;
  Particle({required this.position, required this.symbol});
}
