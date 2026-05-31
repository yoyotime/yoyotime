import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const YoyotimeApp());
}

class YoyotimeApp extends StatelessWidget {
  const YoyotimeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Yoyotime',
      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _rotateAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _scaleAnim = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _rotateAnim = Tween<double>(begin: -0.02, end: 0.02).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1A1A2E), Color(0xFF16213E), Color(0xFF0F3460)],
          ),
        ),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnim.value,
              child: Transform.rotate(
                angle: _rotateAnim.value,
                child: child,
              ),
            );
          },
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Color(0xFF00D2FF), Color(0xFF3A7BD5), Color(0xFF00D2FF)],
                  ).createShader(bounds),
                  child: const Text(
                    'Yoyotime',
                    style: TextStyle(
                      fontSize: 72,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 6,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  '悠悠好时光!',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withOpacity(0.85),
                    letterSpacing: 4,
                  ),
                ),
                const SizedBox(height: 60),
                _buildParticleDots(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildParticleDots() {
    return SizedBox(
      width: 200,
      height: 40,
      child: Stack(
        children: List.generate(12, (i) {
          final delay = i * 0.15;
          return AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final progress = (_controller.value + delay) % 1.0;
              final opacity = (sin(progress * pi * 2) + 1) / 2;
              return Positioned(
                left: i * 16.0,
                top: 10 + sin(progress * pi * 2) * 10,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.cyan.withOpacity(opacity * 0.8),
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
