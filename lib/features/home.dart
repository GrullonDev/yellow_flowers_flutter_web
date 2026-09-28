import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:flutter_confetti/flutter_confetti.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    // Confetti inserts into the Overlay, which can't happen during build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _startFlowerShow();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _startYellowFlowersRain() {
    Confetti.launch(
      context,
      options: const ConfettiOptions(
        particleCount: 100,
        spread: 350,
        y: 0.1,
        colors: [
          Colors.yellow,
          Colors.amber,
          Colors.amberAccent,
          Color(0xFFFFD700),
          Color(0xFFFFA000),
        ],
        scalar: 1.2,
      ),
    );
  }

  void _startFlowerShow() {
    _controller.reset();
    _controller.forward();
    _startYellowFlowersRain();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.amberAccent,
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
              ],
            ),
          ),
        ],
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
