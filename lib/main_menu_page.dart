import 'package:flutter/material.dart';

class MainMenuPage extends StatelessWidget {
  const MainMenuPage
({super.key});

  @override
  Widget build(BuildContext context) {
    final style = TextButton.styleFrom(
      backgroundColor: Colors.white60,
      textStyle: const TextStyle(fontSize: 50),
      padding: const EdgeInsets.all(20.0),
    );
    return Expanded(
      child: Stack(
        alignment: Alignment.center,
        children: [
          const SizedBox.expand(
            child: Image(
              image: AssetImage("assets/images/main_menu_back.png"),
              fit: BoxFit.cover,
            ),
          ),
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            direction: Axis.vertical,
            spacing: 25,
            children: [
              TextButton(
                onPressed: () => Navigator.pushNamed(context, "/game"), 
                style: style,
                child: const Text("Game"),
              ),
              TextButton(
                onPressed: null, //() => Navigator.pushNamed(context, "/gameplay"), 
                style: style,
                child: const Text("Credits"),
              ),
            ],
          ),
        ],
      ),
    ); 
  }
}
