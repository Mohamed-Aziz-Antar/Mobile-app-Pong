import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:network_info_plus/network_info_plus.dart';

class JoinRoomPage extends StatefulWidget {
  @override
  _JoinRoomPageState createState() => _JoinRoomPageState();
}

class _JoinRoomPageState extends State<JoinRoomPage> {
  List<Map<String, dynamic>> availableRooms = [];

  @override
  void initState() {
    super.initState();
    _listenForRooms();
  }

  Future<void> _listenForRooms() async {
    final info = NetworkInfo();
    final ip = await info.getWifiIP();  // Get local IP, e.g., 192.168.43.1
    if (ip != null) {
      final parts = ip.split('.');
      final subnet = "${parts[0]}.${parts[1]}.${parts[2]}";
      final broadcastIp = "$subnet.255";  // e.g., 192.168.43.255

      final socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 4567);
      socket.broadcastEnabled = true;

      socket.listen((event) async {
        if (event == RawSocketEvent.read) {
          final datagram = await socket.receive();
          if (datagram != null) {
            final data = utf8.decode(datagram.data);
            final roomData = jsonDecode(data);
            setState(() {
              availableRooms.add(roomData);
            });
          }
        }
      });

      print('Listening for rooms...');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0A0A1B),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                'Available Rooms',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: availableRooms.length,
                  itemBuilder: (context, index) {
                    final room = availableRooms[index];
                    return Card(
                      color: Color(0xFF24283B),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(color: Color(0xFF565F89), width: 1.5),
                      ),
                      child: ListTile(
                        title: Text(room['roomName'], style: TextStyle(color: Colors.white)),
                        subtitle: Text('Score Limit: ${room['scoreLimit']}, Time Limit: ${room['timeLimit']} min', style: TextStyle(color: Colors.white70)),
                        trailing: IconButton(
                          icon: Icon(Icons.check, color: Colors.green),
                          onPressed: () {
                            // Implement join logic here
                            print("Joining room: ${room['roomName']}");
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
