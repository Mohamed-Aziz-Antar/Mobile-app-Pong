import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';

class PongGamePage extends StatefulWidget {
  final String roomName;
  final String hostIp;
  final bool isHost;

  PongGamePage({required this.roomName, required this.hostIp, required this.isHost});

  @override
  _PongGamePageState createState() => _PongGamePageState();
}

class _PongGamePageState extends State<PongGamePage> {
  late RawDatagramSocket _socket;
  late String _hostIp;
  int _port = 4567;

  @override
  void initState() {
    super.initState();
    _hostIp = widget.hostIp;
    _connectToHost();
  }

  Future<void> _connectToHost() async {
    _socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, _port);

    // Listen for incoming game data (e.g., paddle positions, ball positions)
    _socket.listen((event) {
      if (event == RawSocketEvent.read) {
        final datagram = _socket.receive();
        if (datagram != null) {
          final data = utf8.decode(datagram.data);
          final gameData = jsonDecode(data);
          print("Received game data: $gameData");
          // Handle game state update (e.g., ball position, paddle position)
        }
      }
    });

    // Send join request to the host
    final joinMessage = jsonEncode({
      'roomName': widget.roomName,
      'player': 'Guest',
    });

    _socket.send(utf8.encode(joinMessage), InternetAddress(_hostIp), _port);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Pong Game - ${widget.roomName}"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Text(
          'Playing Pong as a Guest!',
          style: TextStyle(fontSize: 24, color: Colors.white),
        ),
      ),
    );
  }
}
