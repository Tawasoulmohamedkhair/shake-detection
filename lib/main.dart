import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';

void main() {
  runApp(const ShakeApp());
}

class ShakeApp extends StatefulWidget {
  const ShakeApp({super.key});
  @override
  State<ShakeApp> createState() => _ShakeAppState();
}

class _ShakeAppState extends State<ShakeApp> with TickerProviderStateMixin {
  static const eventChannel = EventChannel('com.example.shake_channel');

  final List<String> quotes = [
    "Believe in yourself!",
    "Never give up!",
    "Focus on progress, not perfection!",
    "Stay positive and strong!",
    "Success starts with discipline!",
    "Keep moving forward!",
    "Dream big, start small, act now!",
    "Courage is stronger than fear!",
    "You’re closer than you think!",
    "Make today count!",
  ];

  String? currentQuote;

  late AnimationController _scaleController;
  late AnimationController _glowController;
  late AnimationController _smokeController;

  bool showSmoke = false;

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
      lowerBound: 0.0,
      upperBound: 1.0,
    );

    _smokeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    eventChannel.receiveBroadcastStream().listen((event) {
      if (event == "SHAKE") {
        _triggerFireAnimation();
        _showRandomQuote();
      }
    });
  }

  void _triggerFireAnimation() {
    _scaleController.forward(from: 0);
    _glowController.repeat(reverse: true);

    setState(() => showSmoke = true);
    _smokeController.forward(from: 0);

    Future.delayed(const Duration(milliseconds: 1500), () {
      _glowController.stop();
      setState(() => showSmoke = false);
    });
  }

  void _showRandomQuote() {
    final random = Random();
    setState(() {
      currentQuote = quotes[random.nextInt(quotes.length)];
    });
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _glowController.dispose();
    _smokeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (showSmoke)
                Lottie.asset(
                  'assets/animations/smoke.json',
                  controller: _smokeController,
                  onLoaded: (composition) {
                    _smokeController.duration = composition.duration;
                    _smokeController.forward(from: 0);
                  },
                  width: 200,
                ),
              AnimatedBuilder(
                animation: Listenable.merge([
                  _scaleController,
                  _glowController,
                ]),
                builder: (context, child) {
                  final scale = 1 + (_scaleController.value * 0.4);
                  final glowIntensity = _glowController.value;

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.orange.withValues(
                                alpha: 0.7 * glowIntensity,
                              ),
                              blurRadius: 40 * glowIntensity,
                              spreadRadius: 10 * glowIntensity,
                            ),
                          ],
                        ),
                        child: Transform.scale(
                          scale: scale,
                          child: const Icon(
                            Icons.local_fire_department,
                            color: Colors.orangeAccent,
                            size: 120,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (currentQuote != null)
                        Transform.scale(
                          scale: scale,
                          child: Text(
                            currentQuote!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Sen',
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
