class GameState {
  final String id;
  final List players;
  final bool isJoin;
  final bool isOver;
  final List words;

  GameState({
    required this.id,
    required this.players,
    required this.words,
    required this.isJoin,
    required this.isOver,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'players': players,
        'words': words,
        'isOver': isOver,
        'isJoin': isJoin,
      };
}
