import 'package:flutter/material.dart';
import 'dart:math';
import 'createRoom.dart';
import 'joinRoom.dart';
void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: HomeScreen(),
  ));
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0A0A1B),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  Icons.sports_esports_outlined,
                  size: 80,
                  color: Color(0xFFFF4D4D),
                ),
                Positioned(
                  right: -13,
                  top: -15, // Slightly move upward
                  child: Transform.rotate(
                    angle: pi / 6,
                    child: Icon(
                      Icons.wifi,
                      size: 35,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              "PONG MULTIPLAYER",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Challenge your friends in real-time",
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () {
                // Navigate to Create Room Screen when pressed.
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) =>CreateRoomPage()),
                );
              },
              icon: const Icon(Icons.person_add_outlined, color: Colors.white),
              label: const Text(
                "Create Room",
                style: TextStyle(fontSize: 15),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[800],
                foregroundColor: Colors.white,
                minimumSize: const Size(300, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                // Navigate to Join Room Screen when pressed.
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => JoinRoomPage()),
                );
              },
              icon: const Icon(Icons.wifi, color: Colors.white),
              label: const Text(
                "Join Room",
                style: TextStyle(fontSize: 15),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[800],
                foregroundColor: Colors.white,
                minimumSize: const Size(300, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 30),
            Container(
              width: 100,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white70,
                borderRadius: BorderRadius.circular(10),
              ),
            )
          ],
        ),
      ),
    );
  }
}



