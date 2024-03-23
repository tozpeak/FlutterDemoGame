import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class GameplayPage extends StatelessWidget {
  const GameplayPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Stack(
        alignment: Alignment.center,
        children: [
          const SizedBox.expand(
            child: Image(
              image: AssetImage("assets/images/game_back.png"),
              alignment: Alignment.center,
              fit: BoxFit.cover,
            ),
          ),
          const AspectRatio(
            aspectRatio: GameplayContent.gameWidth / GameplayContent.gameHeight,
            child: GameplayContent(),
          ),
          Align(
            alignment: Alignment.topLeft,
            child: IconButton(
              onPressed: () => Navigator.pop(context), 
              icon: const Icon(CupertinoIcons.back),
              alignment: Alignment.topLeft,
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.white60),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class GameplayContent extends StatefulWidget {
  const GameplayContent({super.key});
  static const double gameWidth = 360;
  static const double gameHeight = 800;

  @override
  State<GameplayContent> createState() => _GameplayContentState();
}

class _GameplayContentState extends State<GameplayContent> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}