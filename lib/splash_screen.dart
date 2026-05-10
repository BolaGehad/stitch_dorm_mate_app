import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'theme.dart';
import 'auth_gate.dart';

class BlueprintPainter extends CustomPainter {
  const BlueprintPainter({this.brightness = Brightness.light});

  final Brightness brightness;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = brightness == Brightness.dark
          ? AppTheme.primaryContainer.withValues(alpha: 0.07)
          : AppTheme.primaryContainerOpacity3
      ..strokeWidth = 1.0;

    const double spacing = 40.0;

    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Wait for splash animation, then delegate routing to AuthGate.
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AuthGate()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Level 1: Blueprint Background Grid
          Positioned.fill(
            child: CustomPaint(
              painter: BlueprintPainter(
                  brightness: Theme.of(context).brightness),
            ),
          ),

          // Decorative Blueprint Overlay Image
          Positioned.fill(
            child: IgnorePointer(
              child: Image.network(
                'https://lh3.googleusercontent.com/aida-public/AB6AXuAa-0y0YsntWeAjvN0Y0Znt8Vw4st-Xbq-njzDwML7teEXw2rU7H1MXCygppHosZmi2JdzFuRemXrb06OHkRpLHlUEc3FFwvS99Qk39UCmo17Zpj174SYCzEGqMxbCWC7PAp1Pg51A_7i6JY3Z5ZZKbcbnv2b_6aGw9_HoM2o04GpZMYOXfvXrn2kTRlJxj0iO1xE_3XhxCD2L9ZBPPM5EzC2mNPPQLn12TMkJ5P1spue5gvHlduH8l7QsElW5DMiTXYuHHddEIDOs',
                fit: BoxFit.cover,
                color: Colors.white.withOpacity(0.05),
                colorBlendMode: BlendMode.dstIn,
              ),
            ),
          ),

          // Level 1.5: Watermarks
          // Top Watermark: Drafting Compass
          Positioned(
            top: -size.height * 0.1,
            left: -size.width * 0.05,
            child: Transform.rotate(
              angle: 12 * math.pi / 180,
              child: const Icon(
                Icons.architecture,
                size: 320,
                color: AppTheme.primaryOpacity4,
              ),
            ),
          ),

          // Bottom Watermark: Gear
          Positioned(
            bottom: -size.height * 0.05,
            right: -size.width * 0.1,
            child: Transform.rotate(
              angle: -12 * math.pi / 180,
              child: const Icon(
                Icons.settings_suggest,
                size: 280,
                color: AppTheme.primaryOpacity3,
              ),
            ),
          ),

          Positioned(
            top: size.height * 0.2,
            right: size.width * 0.1,
            child: const Icon(
              Icons.foundation,
              size: 120,
              color: AppTheme.primaryOpacity2,
            ),
          ),

          // Level 2: Centered Brand Identity
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Brand Icon with Ambient Shadow
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.all(Radius.circular(28)),
                    border:
                        Border.all(color: AppTheme.primaryContainerOpacity20),
                    boxShadow: const [
                      BoxShadow(
                        color: AppTheme
                            .primaryContainerOpacity12, // Ambient Shadow
                        blurRadius: 20,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(
                      color: AppTheme.primaryContainer,
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                    alignment: Alignment.center,
                    child: Image.asset(
                      'assets/home_app_logo.png',
                      width: 48,
                      height: 48,
                    ),
                  ),
                ),
                const SizedBox(height: 24), // stack-gap-lg

                // Title
                Text(
                  'Dorm Mate',
                  style: textTheme.headlineLarge?.copyWith(
                    fontSize: 32,
                    letterSpacing: -1.0,
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 8), // base rhythm

                // Subtitle
                Text(
                  'STRUCTURAL SERENITY',
                  style: textTheme.labelMedium?.copyWith(
                    fontSize: 10,
                    letterSpacing: 2.0,
                    color: AppTheme.onSurfaceVariantOpacity60,
                  ),
                ),
              ],
            ),
          ),

          // Level 2: Loading Indicator Cluster
          Positioned(
            bottom: 64,
            left: 0,
            right: 0,
            child: Column(
              children: [
                // Progress Bar Background
                Container(
                  width: 48,
                  height: 4,
                  decoration: const BoxDecoration(
                    color: AppTheme.surfaceContainer,
                    borderRadius: BorderRadius.all(Radius.circular(9999)),
                  ),
                  alignment: Alignment.centerLeft,
                  // Progress Bar Active Fill
                  child: Container(
                    width: 16,
                    height: 4,
                    decoration: const BoxDecoration(
                      color: AppTheme.primaryContainer,
                      borderRadius: BorderRadius.all(Radius.circular(9999)),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryContainerOpacity40,
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Initializing workspace...',
                  style: textTheme.labelSmall?.copyWith(
                    color: AppTheme.onSurfaceVariantOpacity40,
                  ),
                ),
              ],
            ),
          ),

          // Level 3: Floating Dormy AI Base
          Positioned(
            bottom: 24,
            right: 24,
            child: Opacity(
              opacity: 0.2,
              child: Transform.scale(
                scale: 0.75,
                child: const ColorFiltered(
                  colorFilter: ColorFilter.matrix([
                    0.2126,
                    0.7152,
                    0.0722,
                    0,
                    0,
                    0.2126,
                    0.7152,
                    0.0722,
                    0,
                    0,
                    0.2126,
                    0.7152,
                    0.0722,
                    0,
                    0,
                    0,
                    0,
                    0,
                    1,
                    0,
                  ]),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppTheme.primaryContainer,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 15,
                          offset: Offset(0, 10),
                        )
                      ],
                    ),
                    child: SizedBox(
                      width: 56,
                      height: 56,
                      child: Icon(
                        Icons.smart_toy,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
