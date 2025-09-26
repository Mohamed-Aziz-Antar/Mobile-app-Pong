import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:pong/pages/LeaderBoardScreeen.dart';
import 'package:pong/pages/avatarSelection.dart';
import 'package:pong/pages/classicMode.dart';
import 'package:pong/pages/joinRoom.dart';
import 'package:pong/pages/menu.dart';
import 'package:pong/pages/parameters.dart';
import 'package:pong/pages/practiseMode.dart';
import 'package:pong/pages/signupLogin.dart';

import 'handlers/musicController.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // Start music on app launch
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<String> loadingTexts;
  int loadingIndex = 0;

  @override
  void initState() {
    super.initState();

    loadingTexts = ["Loading", "Loading.", "Loading.."];

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..addListener(() {
      setState(() {});
    });

    _controller.forward();

    _startDotAnimation();

    _controller.addStatusListener((status) async {
      if (status == AnimationStatus.completed) {
        User? user = FirebaseAuth.instance.currentUser;

        // Add a null check for 'user' before accessing 'email'
        String email = user?.email ?? 'unknown@example.com';

        if (user != null) {
          // User is logged in, go to PongScreen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => PongScreen(email: email)),
          );
        } else {
          // No user, go to AuthPage
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => AuthPage()),
          );
        }
      }
    });

  }


  void _startDotAnimation() {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          loadingIndex = (loadingIndex + 1) % loadingTexts.length;
        });
        _startDotAnimation(); // Loop the animation
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double progressValue = _controller.value;

    return Scaffold(
      body: Container(
        color: const Color(0xFF0B0C1C),
        child: Stack(
          children: [
            // Background Grid
            CustomPaint(
              size: MediaQuery.of(context).size,
              painter: GridPainter(),
            ),
            SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(height: 50),
                  // Center Content
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Title
                      Text(
                        '| PONG |•',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 72,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Animated Progress Bar
                      Container(
                        width: 200,
                        height: 2,
                        color: Colors.white.withOpacity(0.3),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            width: 200 * progressValue,
                            height: 2,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Animated Loading Text
                      Text(
                        loadingTexts[loadingIndex], // Changes dynamically
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  // Footer: GameStudio + version
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.videogame_asset, color: Colors.white),
                          const SizedBox(width: 8),
                          Text(
                            'GameStudio',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'v1.0.0',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..strokeWidth = 1;
    const double step = 40;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
