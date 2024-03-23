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
            //width: 360,
            //height: 800,
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
  double _paddleCenterPosition = GameplayContent.gameWidth / 2;

  final _paddleSize = Size(60, 10);


  @override
  Widget build(BuildContext context) {

    return LayoutBuilder(
      builder: (context, constrains) {
        final size = constrains.biggest;
        final ratio = size.width / GameplayContent.gameWidth;
        return GestureDetector(
          onPanUpdate: (details) => setState(() {
            _paddleCenterPosition = details.localPosition.dx / ratio;
          }),
          child: Container(
            color: Colors.white24,
            child: Stack(
              //TODO: use CustomMultiChildLayout instead
              children: [
                SizedBox.expand(
                  child: Align(
                    alignment: Alignment(
                      (
                        2 * _paddleCenterPosition
                        / (GameplayContent.gameWidth-_paddleSize.width)
                      ) 
                      - 1
                      - _paddleSize.width / (GameplayContent.gameWidth - _paddleSize.width), 
                      0.8
                    ),
                    child: SizedBox.fromSize(
                      size: _paddleSize * ratio,
                      child: Container(color: Colors.green,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: _paddleSize.width * ratio / 2 - 1),
                          child: Container(
                            color: Colors.black
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    );
  }
}