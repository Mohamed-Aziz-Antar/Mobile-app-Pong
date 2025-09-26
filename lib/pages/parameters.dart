import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pong/pages/signupLogin.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  double _masterVolume = 0.8;
  bool _soundEffects = true;
  bool _backgroundMusic = true;
  bool _vibration = false;

  void _resetSettings() {
    setState(() {
      _masterVolume = 0.8;
      _soundEffects = true;
      _backgroundMusic = true;
      _vibration = false;
    });
  }

  // Function to disconnect the user
  void _disconnectUser() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => AuthPage()), // Navigate to login or your preferred screen
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A1B),
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          'Settings',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _resetSettings,
            child: const Text(
              'Reset',
              style: TextStyle(
                color: Colors.blue,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        children: [
          // SOUND Section Title
          Text(
            'SOUND',
            style: TextStyle(
              color: Colors.grey.shade400,
              fontWeight: FontWeight.bold,
              fontSize: 12,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 16),

          // Master Volume + Slider
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.volume_up, color: Colors.white),
                  const SizedBox(width: 8),
                  const Text(
                    'Master Volume',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
              Text(
                '${(_masterVolume * 100).round()}%',
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
          Slider(
            value: _masterVolume,
            min: 0,
            max: 1,
            divisions: 100,
            onChanged: (value) {
              setState(() {
                _masterVolume = value;
              });
            },
            activeColor: Colors.blue,
            inactiveColor: Colors.grey,
          ),
          const SizedBox(height: 16),

          // Sound Effects Switch
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.notifications_none, color: Colors.white),
                  const SizedBox(width: 8),
                  const Text(
                    'Sound Effects',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
              Switch(
                value: _soundEffects,
                onChanged: (value) {
                  setState(() {
                    _soundEffects = value;
                  });
                },
                activeColor: Colors.blue,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Background Music Switch
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.music_note, color: Colors.white),
                  const SizedBox(width: 8),
                  const Text(
                    'Background Music',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
              Switch(
                value: _backgroundMusic,
                onChanged: (value) {
                  setState(() {
                    _backgroundMusic = value;
                  });
                },
                activeColor: Colors.blue,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ADDITIONAL Section Title
          Text(
            'ADDITIONAL',
            style: TextStyle(
              color: Colors.grey.shade400,
              fontWeight: FontWeight.bold,
              fontSize: 12,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 16),

          // Vibration Switch
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.vibration, color: Colors.white),
                  const SizedBox(width: 8),
                  const Text(
                    'Vibration',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
              Switch(
                value: _vibration,
                onChanged: (value) {
                  setState(() {
                    _vibration = value;
                  });
                },
                activeColor: Colors.blue,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Info Text
          const Text(
            'Sound settings will be automatically saved',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),

          // Add Disconnect Button at the bottom
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _disconnectUser,
            child: const Text('Disconnect'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red, // Updated property for background color
              padding: const EdgeInsets.symmetric(vertical: 12),
              textStyle: const TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }
}
