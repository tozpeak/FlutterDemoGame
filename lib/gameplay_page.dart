import 'package:demo_bricks/custom_physics.dart';
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

class _GameplayContentState extends State<GameplayContent> 
    with SingleTickerProviderStateMixin {
  
  late AnimationController _controller;
  bool _isGameOver = false;

  Offset _paddleCenterPosition = const Offset(
    GameplayContent.gameWidth / 2, 
    GameplayContent.gameHeight * 0.85
  );

  final _paddleSize = const Size(60, 20);

  Rect ball = Rect.fromCircle(
    center: const Offset(GameplayContent.gameWidth / 2, GameplayContent.gameHeight * 0.8),
    radius: 10,
  );
  Offset ballSpeed = Offset.fromDirection(-1, 280);
    
  final walls = [
    Rect.fromPoints(const Offset(-10, -10), const Offset(0, GameplayContent.gameHeight)),
    Rect.fromPoints(const Offset(-10, -10), const Offset(GameplayContent.gameWidth, 0)),
    Rect.fromPoints(
      const Offset(GameplayContent.gameWidth, -10), 
      const Offset(GameplayContent.gameWidth, GameplayContent.gameHeight)
    ),
    
  ];

  Rect gameOverCollider = Rect.fromPoints(
    const Offset(-10, GameplayContent.gameHeight * 0.95), 
    const Offset(GameplayContent.gameWidth+10, GameplayContent.gameHeight)
  );

  final targets = <Rect>[];
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);

    _controller.addListener(() {
      setState(() {
        _physicsUpdate(0.02);
      });
    });

    const rows = 10;
    const colums = 5;
    const margin = 10.0;
    const blockSize = Size(60, 20);
    const startPos = Offset(40.0, GameplayContent.gameHeight * 0.1);
    final dx = Offset(blockSize.width + margin, 0);
    final dy = Offset(0, blockSize.height + margin);

    for (var i = 0; i < rows; i++) {
      for (var j = 0; j < colums; j++) {
        targets.add(Rect.fromCenter(
          center: startPos + dx * (j * 1.0) + dy * (i * 1.0), 
          width: blockSize.width, 
          height: blockSize.height
        ));
      }
    }
  }

  void _startAnimation() {
    _controller.repeat(min: 0, max: 1, period: Durations.short1);
  }

  @override 
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  FractionalOffset _getViewportOffset(Offset ingameCenter, Size size) {
    return FractionalOffset(
      (ingameCenter.dx - size.width / 2) 
      / 
      (GameplayContent.gameWidth - size.width)
      , 
      (ingameCenter.dy - size.height / 2) 
      / 
      (GameplayContent.gameHeight - size.height)
    );
  }

  _physicsUpdate(double dTime) {
    if(_isGameOver) return;

    ball = ball.translate(ballSpeed.dx * dTime, ballSpeed.dy * dTime);
    //print(ball.center);

    for (var wall in walls) {
      _collideBallWith(wall);
    }
    _collideBallWith(Rect.fromCenter(
      center: _paddleCenterPosition, 
      width: _paddleSize.width, 
      height: _paddleSize.height,
    ));

    if(_collideBallWith(gameOverCollider)) {
      print("Game Over");
      ballSpeed = Offset.zero;
      _isGameOver = true;
    }

    for (var i = 0; i < targets.length; i++) {
      if(_collideBallWith(targets[i])) {
        targets.removeAt(i);
        i--;
      }
    }

    if(targets.isEmpty) _isGameOver = true;
  }

  bool _collideBallWith(Rect rect) {
    var normal = CustomPhysics.collisionSphereToBox(ball, rect);
    if(normal == null) return false;
    ballSpeed = CustomPhysics.reflectSpeed(ballSpeed, normal);
    return true;
  }

  @override
  Widget build(BuildContext context) {

    return LayoutBuilder(
      builder: (context, constrains) {
        final size = constrains.biggest;
        final ratio = size.width / GameplayContent.gameWidth;
        return GestureDetector(
          onPanDown: (details) {
            if(!_controller.isAnimating) {
              _startAnimation();
            }
            _updatePaddlePos(details.localPosition.dx, ratio);
          },
          onPanUpdate: (details) => setState(() {
            _updatePaddlePos(details.localPosition.dx, ratio);
            //_physicsUpdate(0.3);
          }),
          child: Container(
            color: Colors.white24,
            child: Stack(
              //TODO: use CustomMultiChildLayout instead
              children: [
                SizedBox.expand(
                  child: Align(
                    alignment: _getViewportOffset(_paddleCenterPosition, _paddleSize),
                    child: SizedBox.fromSize(
                      size: _paddleSize * ratio,
                      child: Container(color: Colors.green,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: _paddleSize.width * ratio / 2 - 1),
                          child: Container(
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox.expand(
                  child: Align(
                    alignment: _getViewportOffset(ball.center, ball.size),
                    child: SizedBox.fromSize(
                      size: ball.size * ratio,
                      child: Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                ...targets.map<Widget>((target) => 
                  SizedBox.expand(
                    child: Align(
                      alignment: _getViewportOffset(target.center, target.size),
                      child: SizedBox.fromSize(
                        size: target.size * ratio,
                        child: Container(color: Colors.blue[200]),
                      ),
                    ),
                  ),
                ),
                if(_isGameOver) SizedBox.expand(
                  child: Center(
                    child: Text(
                      "GAME OVER",
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        color: targets.isEmpty ? Colors.green : Colors.red
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

  void _updatePaddlePos(double dx, double ratio) {
    _paddleCenterPosition = Offset(
      dx / ratio, 
      _paddleCenterPosition.dy
    );
  }
} 