import 'package:flutter/material.dart';
import 'package:multiplayer_game/models/game_state.dart';

class GameStateProvider extends ChangeNotifier {
  GameState _gameState =
      GameState(id: '', players: [], words: [], isJoin: true, isOver: false);

  Map<String, dynamic> get gameState => _gameState.toJson();

  void updateGameState({
    required String id,
    required List players,
    required List words,
    required bool isJoin,
    required bool isOver,
  }) {
    _gameState = GameState(
      id: id,
      players: players,
      words: words,
      isJoin: isJoin,
      isOver: isOver,
    );
    notifyListeners();
  }
}
