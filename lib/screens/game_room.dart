import 'package:flutter/material.dart';
import 'package:dice/utils/app_bar.dart';
import 'package:dice/utils/cookie_manager.dart';

class GameRoomScreen extends StatefulWidget {
  @override
  _GameRoomScreenState createState() => _GameRoomScreenState();
}

class _GameRoomScreenState extends State<GameRoomScreen> {
  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: DiceAppBar(),
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
