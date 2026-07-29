import 'dart:async';
import 'package:flutter/material.dart';
import '../l10n/l10n.dart';
import 'auth_gate.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(_controller);

    _controller.forward();

    _navigationTimer = Timer(const Duration(seconds: 3), () {
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 700),
          pageBuilder: (context, animation, secondaryAnimation) =>
              const AuthGate(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    });
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xffFCE4EC), Color(0xffF8BBD0), Colors.white],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(),

              FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    width: 230,
                    height: 230,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.pink.withOpacity(0.25),
                          blurRadius: 25,
                          spreadRadius: 5,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        "assets/images/logo.png",
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              FadeTransition(
                opacity: _fadeAnimation,
                child: Text(
                  context.l10n.appName,
                  style: const TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    color: Color(0xffC2185B),
                    letterSpacing: 1,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              FadeTransition(
                opacity: _fadeAnimation,
                child: Text(
                  context.l10n.careTagline,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                    height: 1.5,
                  ),
                ),
              ),

              const SizedBox(height: 15),

              const Icon(Icons.favorite, color: Colors.pink, size: 30),

              const Spacer(),

              const CircularProgressIndicator(
                color: Color(0xffE91E63),
                strokeWidth: 3,
              ),

              const SizedBox(height: 20),

              Text(
                context.l10n.versionShort,
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
