import 'package:flutter/material.dart';
import 'package:multiplayer_game/provider/game_state_provider.dart';
import 'package:multiplayer_game/util/socket_methods.dart';
import 'package:multiplayer_game/widgets/scoreboard.dart';
import 'package:provider/provider.dart';

import '../util/socket_client.dart';

class SentenceGame extends StatefulWidget {
  const SentenceGame({super.key});

  @override
  State<SentenceGame> createState() => _SentenceGameState();
}

class _SentenceGameState extends State<SentenceGame> {
  var playerMe = null;
  final SocketMethods _socketMethods = SocketMethods();

  @override
  void initState() {
    super.initState();
    _socketMethods.updateGame(context);
  }

  findPlayerMe(GameStateProvider game) {
    game.gameState['players'].forEach((player) {
      if (player['socketId'] == SocketClient.instance.socket?.id) {
        playerMe = player;
      }
    });
  }

  Widget getTypedWords(words, player) {
    var tempWords = words.subList(0, player['currentWordIndex']);
    String typedWords = tempWords.join(' ');
    return Text(
      typedWords,
      style: const TextStyle(
        color: Color.fromRGBO(52, 235, 119, 1),
        fontSize: 30,
      ),
    );
  }

  Widget getCurrentWord(words, player) {
    return Text(
      words[player['currentWordIndex']],
      style: const TextStyle(
        decoration: TextDecoration.underline,
        fontSize: 30,
      ),
    );
  }

  Widget getWordsToBeTyped(words, player) {
    var tempWords = words.subList(player['currentWordIndex'] + 1, words.length);
    String wordsToBeTyped = tempWords.join(' ');
    return Text(
      wordsToBeTyped,
      style: const TextStyle(
        fontSize: 30,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final game = Provider.of<GameStateProvider>(context);
    findPlayerMe(game);

    if (game.gameState['words'].length > playerMe['currentWordIndex']) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Wrap(
          textDirection: TextDirection.ltr,
          children: [
            getTypedWords(game.gameState['words'], playerMe),
            getCurrentWord(game.gameState['words'], playerMe),
            getWordsToBeTyped(game.gameState['words'], playerMe),
          ],
        ),
      );
    }
    return const Scoreboard();
  }
}
