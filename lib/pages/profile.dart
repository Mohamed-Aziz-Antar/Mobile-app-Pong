import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'databaseHandler.dart';

class ProfileScreen extends StatefulWidget {
  final String email;

  const ProfileScreen({Key? key, required this.email}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: DatabaseHelper().getUserData(widget.email),
      builder: (context, snapshot) {
        String userName = 'Guest';
        ImageProvider avatarImage = const AssetImage('assets/images/default_avatar.png');
        int userWins =0;
        int game_played =0;
        int loses =0;
        int draws =0;
        int level =0;



        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(color: Color(0xFF6C63FF)),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Failed to load profile',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          );
        }

        if (snapshot.hasData) {
          final user = snapshot.data!;
          userName = user['name']?.toString() ?? 'Guest';
          userWins = user['wins'] as int? ?? 0;
          game_played = user['game_played'] as int? ?? 0;
          int loses =user['loses'] as int? ?? 0;;
          int draws =user['draws'] as int? ?? 0;
          int level =user['level'] as int? ?? 0;








          if (user['avatar'] != null) {
            avatarImage = MemoryImage(user['avatar'] as Uint8List);
          }
        }

        return Scaffold(
          backgroundColor: const Color(0xFF0A0A1B),
          body: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                const SizedBox(height: 40),
                CircleAvatar(
                  radius: 50,
                  backgroundImage: avatarImage,
                ),
                const SizedBox(height: 10),
                Text(
                  userName,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Level ${level} Player',
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatCard('Games Played', game_played, Icons.videogame_asset),
                    _buildStatCard('Wins', userWins, Icons.emoji_events),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatCard('Draws', draws, Icons.handshake),
                    _buildStatCard('Loses', loses, Icons.local_fire_department),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  width: 350,
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Achievements',
                        style: GoogleFonts.poppins(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: List.generate(4, (index) => _buildAchievement(index + 1)),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: List.generate(4, (index) => _buildAchievement(index + 5)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String title, int value, IconData icon) {
    return Container(
      width: 170,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.black, size: 28),
          const SizedBox(height: 5),
          Text(
            title,
            style: GoogleFonts.poppins(
              color: Colors.black,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value.toString(),
            style: GoogleFonts.poppins(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievement(int level) {
    return Column(
      children: [
        CircleAvatar(
          radius: 25,
          backgroundColor: Color(0xFFE5E7EB),
        ),
        const SizedBox(height: 5),
        Text(
          'Level $level',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}