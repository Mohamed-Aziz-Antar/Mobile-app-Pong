import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pong/colors.dart'; // Keep if you're using custom color constants

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  _LeaderboardScreenState createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final String defaultAvatar = "https://i.pravatar.cc/150?img=12";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A1B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A1B),
        elevation: 0,
        title: const Text(
          "Leaderboard",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3.0,
          indicatorSize: TabBarIndicatorSize.label,
          labelStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontSize: 18),
          tabs: const [
            Tab(child: Text("Global", style: TextStyle(color: Colors.white))),
            Tab(child: Text("Friends", style: TextStyle(color: Colors.white))),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildLeaderboardView(),
          _buildLeaderboardView(), // You can customize "Friends" tab later
        ],
      ),
    );
  }

  Widget _buildLeaderboardView() {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .orderBy('wins', descending: true)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text("No players found.", style: TextStyle(color: Colors.white70)),
          );
        }

        final users = snapshot.data!.docs;

        return ListView.separated(
          itemCount: users.length,
          separatorBuilder: (context, index) => const Divider(
            color: Colors.white24,
            thickness: 1,
            indent: 16,
            endIndent: 16,
          ),
          itemBuilder: (context, index) {
            final user = users[index];
            final name = user['name'] ?? 'Unknown';
            final wins = user['wins'] ?? 0;

            IconData? icon;
            Color? iconColor;
            if (index == 0) {
              icon = Icons.emoji_events;
              iconColor = Colors.amber;
            } else if (index == 1) {
              icon = Icons.emoji_events;
              iconColor = Colors.grey;
            } else if (index == 2) {
              icon = Icons.emoji_events;
              iconColor = Colors.brown;
            }

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
              child: Row(
                children: [
                  Text(
                    "${index + 1}",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white60,
                    ),
                  ),
                  const SizedBox(width: 16),
                  CircleAvatar(
                    backgroundImage: NetworkImage(defaultAvatar),
                    radius: 24,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      name,
                      style: const TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                  if (icon != null)
                    Icon(
                      icon,
                      color: iconColor,
                      size: 20,
                    ),
                  const SizedBox(width: 16),
                  Text(
                    "$wins pts",
                    style: const TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
