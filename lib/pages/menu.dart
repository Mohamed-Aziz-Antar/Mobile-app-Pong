import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:pong/pages/joinRoom.dart';
import 'package:pong/pages/multiplier.dart';
import 'package:pong/pages/parameters.dart';
import 'package:pong/pages/practiseMode.dart';
import 'package:pong/pages/profile.dart';
import 'package:pong/pages/timeAttackMode.dart'; // Added import for LeaderboardScreen

import 'LeaderBoardScreeen.dart';
import 'classicMode.dart';

class PongScreen extends StatefulWidget {
  final String email;

  const PongScreen({Key? key, required this.email}) : super(key: key);
  @override
  _PongScreenState createState() => _PongScreenState();
}

class _PongScreenState extends State<PongScreen> {
  double ballX = 0, ballY = 0;
  double ballDX = 0.01, ballDY = 0.01;
  double paddleY1 = 0, paddleY2 = 0;
  final double paddleHeight = 100, paddleWidth = 10;
  int player1Score = 0, player2Score = 0;
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    Timer.periodic(Duration(milliseconds: 16), (timer) {
      setState(() {
        // Move the ball
        ballX += ballDX;
        ballY += ballDY;

        // Bounce off top and bottom walls
        if (ballY.abs() > 1) ballDY = -ballDY;

        // Paddle collision detection
        if (ballX < -0.9 && ballY > paddleY1 - 0.2 && ballY < paddleY1 + 0.2) {
          ballDX = -ballDX;
        } else if (ballX > 0.9 && ballY > paddleY2 - 0.2 && ballY < paddleY2 + 0.2) {
          ballDX = -ballDX;
        }

        // Scoring conditions
        if (ballX < -1) {
          player2Score++;
          resetBall();
        } else if (ballX > 1) {
          player1Score++;
          resetBall();
        }

        // AI paddle movement with a slower, imperfect reaction
        double reactionTime = Random().nextDouble() * 0.05 + 0.03; // Random speed between 0.03 and 0.08
        paddleY1 += (ballY - paddleY1) * reactionTime;
        paddleY2 += (ballY - paddleY2) * reactionTime;
      });
    });
  }

  void resetBall() {
    ballX = 0;
    ballY = 0;
    ballDX = Random().nextBool() ? 0.01 : -0.01;
    ballDY = Random().nextBool() ? 0.01 : -0.01;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0A0A1B),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 4,
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 16.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Color(0xFF9CA3AF), width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment(0, -0.9),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$player1Score  -  $player2Score',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 2),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Player1',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              SizedBox(width: 16),
                              Text(
                                'Player2',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => SettingsPage()),
                          );
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Color(0xFF565F89),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 4,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.settings_outlined,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                    // Ball
                    Align(
                      alignment: Alignment(ballX, ballY),
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),

                    // Left paddle
                    Align(
                      alignment: Alignment(-1, paddleY1),
                      child: Container(
                        width: paddleWidth,
                        height: paddleHeight,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),

                    // Right paddle
                    Align(
                      alignment: Alignment(1, paddleY2),
                      child: Container(
                        width: paddleWidth,
                        height: paddleHeight,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),

                    // Vertical center line
                    Align(
                      alignment: Alignment(0, 0),
                      child: Container(
                        width: 1,
                        height: double.infinity,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Container(
              margin: EdgeInsets.only(left: 16.0, top: 16.0),
              alignment: Alignment.centerLeft,
              child: Text(
                "Game Modes",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontFamily: "Inter",
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),

            Expanded(
              flex: 4,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: GridView.count(
                  crossAxisCount: 2,
                  childAspectRatio: 1.2,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  children: [
                    gameModeButton(
                      Icons.sports_esports_outlined,
                      'Classic',
                      'Original Pong',
                      ClassicMode(),
                    ),
                    gameModeButton(
                      Icons.timer_outlined,
                      'Time Attack',
                      'Race against time',
                      TimeAttackMode(),
                    ),
                    gameModeButton(
                      Icons.people_outline_outlined,
                      'Multiplayer',
                      'Play with friends',
                      HomeScreen(),
                    ),
                    gameModeButton(
                      Icons.school_outlined,
                      'Practice',
                      'Train your skills',
                      PractiseMode(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            selectedIndex = index;
          });

          // Navigate based on the selected tab
          if (index == 1) {  // Ranks tab
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) =>LeaderboardScreen()),
            );
          } else if (index == 2) {
            // Handle Profile tab navigation
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) =>ProfileScreen(email: widget.email)),
            );
            // Add your navigation code for Profile screen here
          } else if (index == 3) {
            // Navigate to Settings
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SettingsPage()),
            );
          }
        },
        currentIndex: selectedIndex,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.leaderboard),
            label: 'Ranks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget gameModeButton(IconData icon, String title, String subtitle, Widget screenToNavigate) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => screenToNavigate),
        );
      },
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.blueGrey.shade900,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blue, width: 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Color(0xFF007AFF), size: 40),
            SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(color: Colors.white, fontFamily: "Inter", fontSize: 20, fontWeight: FontWeight.w400),
            ),
            SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(color: Colors.white54, fontFamily: "Inter", fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}