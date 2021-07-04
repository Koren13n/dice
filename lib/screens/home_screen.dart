import 'package:flutter/material.dart';
import 'package:dice/utils/cookie_manager.dart';
import 'package:dice/screens/name_screen.dart';
import 'package:dice/screens/join_screen.dart';
import 'package:dice/utils/app_bar.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String getName(BuildContext context) {
    String name = CookieManager.getCookie("name");
    if (name.length == 0) {
      Navigator.push(
              context, MaterialPageRoute(builder: (context) => NameScreen()))
          .then((value) => name = value);
    }
    return name;
  }

  void joinRoom(BuildContext context) {
    print(getName(context));
    print("Joining room");
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => JoinScreen()));
  }

  void createRoom(BuildContext context) {
    getName(context);
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    double buttonsWidth = (screenSize.width > screenSize.height) ? 0.3 : 0.9;

    return Scaffold(
      appBar: DiceAppBar(),
      body: Center(
        child: Column(
          children: [
            SizedBox(
              height: screenSize.height * 0.05,
            ),
            Container(
              width: screenSize.width * 0.9,
              child: Text(
                "A fun game to play with friends!",
                style: TextStyle(fontSize: 26),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              child: SizedBox(),
            ),
            Container(
              height: screenSize.height * 0.1,
              width: screenSize.width * buttonsWidth,
              child: ElevatedButton(
                onPressed: () => createRoom(context),
                child: Text(
                  "New Game",
                  style: TextStyle(fontSize: 36),
                ),
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.purple[500]),
                ),
              ),
            ),
            SizedBox(
              height: screenSize.height * 0.02,
            ),
            Container(
              height: screenSize.height * 0.1,
              width: screenSize.width * buttonsWidth,
              child: ElevatedButton(
                onPressed: () => joinRoom(context),
                child: Text(
                  "Join Game",
                  style: TextStyle(fontSize: 36),
                ),
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.purple[500]),
                ),
              ),
            ),
            SizedBox(
              height: screenSize.height * 0.02,
            )
          ],
        ),
      ),
    );
  }
}
