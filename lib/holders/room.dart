class Room {
  final String name;
  final String host;
  final int numberOfPlayers;
  final List<String> playersId;
  final String status;
  final String? password; // Optional password for the room

  Room({
    required this.name,
    required this.host,
    required this.numberOfPlayers,
    required this.playersId,
    required this.status,
    this.password,
  });
}