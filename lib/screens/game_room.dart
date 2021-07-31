import 'package:flutter/material.dart';
import 'package:dice/utils/app_bar.dart';
import 'package:dice/utils/cookie_manager.dart';

class GameRoom extends StatefulWidget {
  static const String route = "/game";

  @override
  _GameRoomState createState() => _GameRoomState();
}

class _GameRoomState extends State<GameRoom> {
  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: Center(
        child: Column(
          children: [
            SizedBox(
              height: screenSize.height * 0.05,
            ),
            Text(
              "Hello " + CookieManager.getCookie("name"),
              style: TextStyle(fontSize: 26),
            ),
            Expanded(child: SizedBox())
          ],
        ),
      ),
    );
  }
}
