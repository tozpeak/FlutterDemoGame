import 'package:audioplayers/audioplayers.dart';
import 'package:demo_bricks/custom_physics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class GameplayPage extends StatelessWidget {
  const GameplayPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
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

  bool debugPhysics = false;
  
  late AnimationController _controller;
  bool _isGameOver = false;

  Rect _paddle = Rect.fromCenter(
    center: const Offset(
      GameplayContent.gameWidth / 2, 
      GameplayContent.gameHeight * 0.85
    ),
    width: 60,
    height: 20,
  );

  Rect ball = Rect.fromCircle(
    center: const Offset(GameplayContent.gameWidth / 2, GameplayContent.gameHeight * 0.8),
    radius: 10,
  );
  Offset ballSpeed = Offset.fromDirection(-1, 280);
    
  final walls = [
    Rect.fromPoints(const Offset(-100, -100), const Offset(0, GameplayContent.gameHeight)),
    Rect.fromPoints(const Offset(-100, -100), const Offset(GameplayContent.gameWidth, 0)),
    Rect.fromPoints(
      const Offset(GameplayContent.gameWidth, -100), 
      const Offset(GameplayContent.gameWidth+100, GameplayContent.gameHeight)
    ),
    
  ];

  Rect gameOverCollider = Rect.fromPoints(
    const Offset(-1000, GameplayContent.gameHeight * 0.95), 
    const Offset(GameplayContent.gameWidth+1000, GameplayContent.gameHeight)
  );

  final targets = <Rect>[];

  final audioCache = (AudioCache(prefix: "assets/audio/")
  ..loadAll([
    "game_finished.wav",
    "game_over.wav",
    "hit_target.wav",
    "hit_wall.wav"
  ])
  );

  final audioPlayers = List.generate(
    4, 
    (index) => AudioPlayer()
      ..setPlayerMode(PlayerMode.lowLatency)
      ..setReleaseMode(ReleaseMode.release)
  );
  int audioPlayerIndex = 0;

  _playSound(String soundName) {
    final audioPlayer = audioPlayers[audioPlayerIndex++];
    if(audioPlayerIndex >= audioPlayers.length) audioPlayerIndex = 0;
    audioPlayer.audioCache = audioCache;

    if(audioPlayer.state != PlayerState.playing) {
      audioPlayer.setSourceAsset("$soundName.wav");
      audioPlayer.resume();
    }
  }
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);

    _controller.addListener(() {
      setState(() {
        if(!debugPhysics) _physicsUpdate(0.02);
      });
    });
    _resetLevel();
  }

  void _resetLevel() {
    _isGameOver = false;
    targets.clear();
    ballSpeed = Offset.fromDirection(-1, 280);
    ball = ball.shift(-ball.center);
    ball = ball.shift(const Offset(GameplayContent.gameWidth / 2, GameplayContent.gameHeight * 0.8));

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

    //ball = ball.shift(-ball.center);
    //ball = ball.translate(0, _paddle.center.dy - 5);

    //targets.removeRange(1, targets.length);
  }

  void _startAnimation() {
    _controller.repeat(min: 0, max: 1, period: const Duration(milliseconds: 50));
  }

  @override 
  void dispose() {
    for (var element in audioPlayers) {
      element.dispose();
    }
    audioCache.clearAll();
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
      _collideBallWith(wall, hitSound: "hit_wall");
    }
    _collideBallWith(_paddle, hitSound: "hit_wall");
    //_collideBallWithPaddle();

    if(_collideBallWith(gameOverCollider, hitSound: "game_over")) {
      ballSpeed = Offset.zero;
      _isGameOver = true;
    }

    for (var i = 0; i < targets.length; i++) {
      if(_collideBallWith(targets[i], hitSound: "hit_target")) {
        targets.removeAt(i);
        i--;
      }
    }

    if(targets.isEmpty) { 
      _isGameOver = true;
      _playSound("game_finished");
    }
  }

  bool _collideBallWith(Rect rect, {debug = false, String? hitSound}) {
    var normals = CustomPhysics.collisionSphereToBox(ball, rect, debug: debug);
    if(normals.isEmpty) return false;

    var normal = normals.fold(
      Offset.zero, 
      (previousValue, element) =>
        CustomPhysics.dotProduct(element, ballSpeed) < 0 
        ? previousValue + element
        : previousValue
    );

    normal = Offset.fromDirection(normal.direction);

    ballSpeed = CustomPhysics.reflectSpeed(ballSpeed, normal);
    if(hitSound != null) _playSound(hitSound);

    return true;
  }

  @override
  Widget build(BuildContext context) {

    return Container(
      constraints: const BoxConstraints.expand(),
      child: Stack(
        children: [
          LayoutBuilder(
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
                }),
                child: Container(
                  color: Colors.white24,
                  child: Stack(
                    fit: StackFit.expand,
                    //TODO: use CustomMultiChildLayout instead
                    children: [
                      Align(
                          alignment: _getViewportOffset(_paddle.center, _paddle.size),
                          child: SizedBox.fromSize(
                            size: _paddle.size * ratio,
                            child: const DecoratedBox(
                              decoration: BoxDecoration(
                                color: Colors.green,
                              ),
                              child: Center(
                                child: SizedBox(
                                  width: 2,
                                  height: double.infinity,
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      Align(
                          alignment: _getViewportOffset(ball.center, ball.size),
                          child: SizedBox.fromSize(
                            size: ball.size * ratio,
                            child: const DecoratedBox(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      ...targets.map<Widget>((target) => 
                        Align(
                            alignment: _getViewportOffset(target.center, target.size),
                            child: SizedBox.fromSize(
                              size: target.size * ratio,
                              child: const DecoratedBox(
                                decoration: BoxDecoration(
                                  color: Color.fromRGBO(144, 202, 249, 1),
                                ),
                              ),
                            ),
                          ),
                        ),
                      if(_isGameOver) Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "GAME OVER",
                              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                color: targets.isEmpty ? Colors.green : Colors.red
                              ),
                            ),
                            TextButton(
                              onPressed: () => setState(() {
                                _resetLevel();
                              }),
                              style: const ButtonStyle(
                                backgroundColor: MaterialStatePropertyAll(Colors.white60)
                              ),
                              child: const Text("Restart"),
                            ),
                          ],
                      ),
                    ],
                  ),
                ),
              );
            }
          ),

          Align(
            alignment: Alignment.topRight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: () => setState(() => debugPhysics = !debugPhysics), 
                  icon: Icon(debugPhysics ? CupertinoIcons.play : CupertinoIcons.pause),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.white60),
                  ),
                ),
                if(debugPhysics) IconButton(
                  onPressed: () => setState(() => _physicsUpdate(0.02)), 
                  icon: const Icon(CupertinoIcons.forward_end),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.white60),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _updatePaddlePos(double targetX, double ratio) {
    _paddle = _paddle.translate(targetX / ratio - _paddle.center.dx, 0);

    if(debugPhysics) _physicsUpdate(0.02);
  }
} 