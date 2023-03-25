import 'package:flutter/material.dart';
import 'package:multiplayer_game/provider/client_state_provider.dart';
import 'package:multiplayer_game/provider/game_state_provider.dart';
import 'package:multiplayer_game/screens/game_screen.dart';
import 'package:multiplayer_game/util/socket_client.dart';
import 'package:provider/provider.dart';

class SocketMethods {
  final _socketClient = SocketClient.instance.socket;
  var _isPlaying = false;

  // create game
  createGame(String nickname) {
    if (nickname.isNotEmpty) {
      _socketClient?.emit('create-game', {
        'nickname': nickname,
      });
    }
  }

  // join game
  joinGame(String gameId, String nickname) {
    if (nickname.isNotEmpty && gameId.isNotEmpty) {
      _socketClient?.emit('join-game', {
        'nickname': nickname,
        'gameId': gameId,
      });
    }
  }

  // listeners
  updateGameListener(BuildContext context) {
    _socketClient?.on('updateGame', (data) {
      print(data);
      final gameStateProvider =
          Provider.of<GameStateProvider>(context, listen: false)
              .updateGameState(
        id: data['_id'],
        players: data['players'],
        words: data['words'],
        isJoin: data['isJoin'],
        isOver: data['isOver'],
      );
      if (data['_id'].isNotEmpty && !_isPlaying) {
        Navigator.pushNamed(context, GameScreen.routeName);
        _isPlaying = true;
      }
    });
  }

  notCorrectGameListener(BuildContext context) {
    _socketClient!.on(
      'notCorrectGame',
      (data) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(data),
        ),
      ),
    );
  }

  startTime(playerId, gameId) {
    _socketClient?.emit('timer', {
      'playerId': playerId,
      'gameId': gameId,
    });
  }

  updateTimer(BuildContext context) {
    final clientStateProvider =
        Provider.of<ClientStateProvider>(context, listen: false);
    _socketClient!.on('timer', (data) {
      clientStateProvider.setClientState(data);
    });
  }

  updateGame(BuildContext context) {
    _socketClient?.on('updateGame', (data) {
      print(data);
      final gameStateProvider =
          Provider.of<GameStateProvider>(context, listen: false)
              .updateGameState(
        id: data['_id'],
        players: data['players'],
        words: data['words'],
        isJoin: data['isJoin'],
        isOver: data['isOver'],
      );
    });
  }

  sendUserInput(String value, String gameId) {
    _socketClient!.emit('userInput', {
      'userInput': value,
      'gameId': gameId,
    });
  }

  gameFinishedListener() {
    _socketClient!.on('done', (data) => _socketClient!.off('timer'));
  }
}
