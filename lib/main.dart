import 'package:flutter/material.dart';
import 'package:multiplayer_game/provider/client_state_provider.dart';
import 'package:multiplayer_game/provider/game_state_provider.dart';
import 'package:multiplayer_game/screens/create_room_screen.dart';
import 'package:multiplayer_game/screens/game_screen.dart';
import 'package:multiplayer_game/screens/home_screen.dart';
import 'package:multiplayer_game/screens/join_room_screen.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (ctx) => GameStateProvider(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => ClientStateProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const HomeScreen(),
        routes: {
          CreateRoomScreen.routeName: (ctx) => const CreateRoomScreen(),
          JoinRoomScreen.routeName: (ctx) => const JoinRoomScreen(),
          GameScreen.routeName: (ctx) => const GameScreen(),
        },
      ),
    );
  }
}
