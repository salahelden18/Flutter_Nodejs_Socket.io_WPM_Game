import 'package:flutter/material.dart';
import 'package:multiplayer_game/screens/create_room_screen.dart';
import 'package:multiplayer_game/screens/join_room_screen.dart';
import 'package:multiplayer_game/widgets/custom_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 600,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Create/Join a room to play!',
                style: TextStyle(fontSize: 24),
              ),
              SizedBox(
                height: size.height * 0.1,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  CustomButton(
                    isHome: true,
                    onTap: () {
                      Navigator.of(context)
                          .pushNamed(CreateRoomScreen.routeName);
                    },
                    text: 'Create',
                  ),
                  CustomButton(
                    isHome: true,
                    onTap: () {
                      Navigator.of(context).pushNamed(JoinRoomScreen.routeName);
                    },
                    text: 'Join',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
