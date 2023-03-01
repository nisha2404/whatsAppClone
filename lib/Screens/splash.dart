import 'package:chatting_app/controllers/firebase_controller.dart';
import 'package:chatting_app/helpers/icons_and_images.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    initializeAnimation();
  }

  initializeAnimation() {
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1100));

    _animation =
        CurvedAnimation(parent: _animationController, curve: Curves.easeOut);

    _animation.addListener(() {
      setState(() {});
    });

    _animationController.forward();

    Future.delayed(const Duration(milliseconds: 1600),
        () => FirebaseController().isCurrentUser(context));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset(AppLogos.splashLogo,
            height: _animation.value * 250, width: _animation.value * 250),
      ),
    );
  }
}
