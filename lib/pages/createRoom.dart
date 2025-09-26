import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class CreateRoomPage extends StatefulWidget {
  @override
  _CreateRoomPageState createState() => _CreateRoomPageState();
}

class _CreateRoomPageState extends State<CreateRoomPage> {
  int scoreLimit = 1;
  int timeLimit = 1;
  TextEditingController roomNameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    requestPermissions();
  }

  Future<void> requestPermissions() async {
    var status = await Permission.location.request();
    if (status.isGranted) {
      print('Location permission granted');
    } else {
      print('Location permission denied');
    }
  }

  // Broadcast the room data to nearby devices via Wi-Fi
  Future<void> _broadcastRoom(String roomName, int scoreLimit, int timeLimit) async {
    final info = NetworkInfo();
    final ip = await info.getWifiIP();  // Get local IP, e.g., 192.168.43.1

    if (ip != null) {
      final parts = ip.split('.');
      final subnet = "${parts[0]}.${parts[1]}.${parts[2]}";
      final broadcastIp = "$subnet.255";  // e.g., 192.168.43.255

      // Create the room data to send
      final roomData = {
        'roomName': roomName,
        'scoreLimit': scoreLimit,
        'timeLimit': timeLimit,
      };

      final socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
      socket.broadcastEnabled = true;
      final data = utf8.encode(jsonEncode(roomData));  // Convert room data to JSON and then to bytes

      // Send broadcast to nearby devices
      socket.send(data, InternetAddress(broadcastIp), 4567);
      socket.close();
      print('Room broadcasted to network');
    } else {
      print("Unable to get local IP");
    }
  }

  void incrementScore() {
    setState(() {
      scoreLimit++;
    });
  }

  void decrementScore() {
    if (scoreLimit > 1) {
      setState(() {
        scoreLimit--;
      });
    }
  }

  void incrementTime() {
    setState(() {
      timeLimit += 1;
    });
  }

  void decrementTime() {
    if (timeLimit > 1) {
      setState(() {
        timeLimit -= 1;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0A0A1B),
      body: SingleChildScrollView(  // Wrap the entire body in a SingleChildScrollView
        padding: const EdgeInsets.all(25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      "Create Room",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 100),
                SizedBox(width: 48), // Ensures balance since the back button takes space
              ],
            ),
            _buildLabel("Room Name"),
            SizedBox(height: 10),
            _buildTextField(roomNameController, "Enter room name"),
            SizedBox(height: 24),
            _buildLabel("Score Limit"),
            SizedBox(height: 10),
            _buildCounter(scoreLimit, decrementScore, incrementScore),
            SizedBox(height: 24),
            _buildLabel("Time Limit (minutes)"),
            SizedBox(height: 10),
            _buildCounter(timeLimit, decrementTime, incrementTime),
            SizedBox(height: 24),
            _buildLabel("Password (Optional)"),
            SizedBox(height: 10),
            _buildTextField(passwordController, "Enter room password"),
            SizedBox(height: 24),
            Container(
              width: double.infinity,
              height: 55,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF7AA2F7), Color(0xFF565F89)], // Dégradé bleu-violet
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Color(0xFF565F89), width: 1.5),
              ),
              child: ElevatedButton(
                onPressed: () {
                  String roomName = roomNameController.text.trim();
                  if (roomName.isNotEmpty) {
                    _broadcastRoom(roomName, scoreLimit, timeLimit);
                  } else {
                    // Handle case where room name is empty
                    print("Please enter a room name.");
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent, // Rendre le fond transparent
                  shadowColor: Colors.transparent, // Supprimer l'ombre
                ),
                child: Text(
                  "Create Room",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(color: Colors.white70, fontSize: 16),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hintText) {
    return TextField(
      controller: controller,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.white54),
        filled: true,
        fillColor: Color(0xFF24283B),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Color(0xFF565F89), width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Color(0xFF565F89), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Color(0xFF565F89), width: 2),
        ),
      ),
    );
  }

  Widget _buildCounter(int value, VoidCallback onDecrement, VoidCallback onIncrement) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildCounterButton("-", onDecrement),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 85, vertical: 6),
          decoration: BoxDecoration(
            color: Color(0xFF24283B),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Color(0xFF565F89), width: 1.5),
          ),
          child: Text(
            "$value",
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        _buildCounterButton("+", onIncrement),
      ],
    );
  }

  Widget _buildCounterButton(String symbol, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF24283B),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Text(symbol, style: TextStyle(fontSize: 20, color: Colors.white)),
    );
  }
}

