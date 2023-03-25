import 'package:flutter/material.dart';
import 'package:multiplayer_game/provider/game_state_provider.dart';
import 'package:multiplayer_game/util/socket_client.dart';
import 'package:multiplayer_game/util/socket_methods.dart';
import 'package:multiplayer_game/widgets/custom_button.dart';
import 'package:provider/provider.dart';

class GameTextField extends StatefulWidget {
  const GameTextField({super.key});

  @override
  State<GameTextField> createState() => _GameTextFieldState();
}

class _GameTextFieldState extends State<GameTextField> {
  final SocketMethods _socketMethods = SocketMethods();
  late GameStateProvider? game;
  var playerMe = null;
  bool isBtn = true;
  final TextEditingController _wordsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    game = Provider.of<GameStateProvider>(context, listen: false);
    findPlayerMe(game!);
  }

  handleTextChange(String value, String gameId) {
    var lastChar = value[value.length - 1];

    if (lastChar == ' ') {
      _socketMethods.sendUserInput(value, gameId);
      setState(() {
        _wordsController.text = "";
      });
    }
  }

  findPlayerMe(GameStateProvider game) {
    game.gameState['players'].forEach((player) {
      if (player['socketId'] == SocketClient.instance.socket?.id) {
        playerMe = player;
      }
    });
  }

  handleStart(GameStateProvider game) {
    _socketMethods.startTime(playerMe['_id'], game.gameState['id']);
    setState(() {
      isBtn = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final gameData = Provider.of<GameStateProvider>(context);

    return playerMe['isPartyLeader'] && isBtn
        ? CustomButton(
            onTap: () => handleStart(gameData),
            text: 'START',
          )
        : TextFormField(
            readOnly: gameData.gameState['isJoin'],
            controller: _wordsController,
            onChanged: (val) => handleTextChange(val, gameData.gameState['id']),
            decoration: InputDecoration(
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.transparent)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.transparent)),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 14,
                horizontal: 16,
              ),
              fillColor: const Color(0xffF5F5FA),
              hintText: 'Type Here',
              hintStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          );
  }
}
