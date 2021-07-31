import 'dart:math';
import 'package:dice/screens/loading_screen.dart';
import 'package:dice/screens/room_screen.dart';
import 'package:flutter/material.dart';
import 'package:dice/utils/cookie_manager.dart';
import 'package:dice/screens/name_screen.dart';
import 'package:dice/screens/join_screen.dart';
import 'package:dice/utils/app_bar.dart';
import 'package:dice/screens/room_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dice/utils/firestore_adapter.dart';
import 'package:dice/utils/firestore_room_manager.dart';

class HomeScreen extends StatefulWidget {
  static const String route = "/home";

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  FirestoreAdapter firestoreAdapter = FirestoreAdapter();
  Random random = Random();

  Future<String> getName(BuildContext context) async {
    String name = CookieManager.getCookie("name");
    if (name.length == 0) {
      await Navigator.push(
              context, MaterialPageRoute(builder: (context) => NameScreen()))
          .then((value) => name = value);
    }
    return name;
  }

  Future<void> joinRoom(BuildContext context) async {
    await getName(context);
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => JoinScreen()));
  }

  Future<void> createRoom(BuildContext context) async {
    String name = await getName(context);
    if (name.length == 0) {
      return;
    }
    String roomCode = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                LoadingScreen(LoadingAction.CreateGame, name)));

    await Navigator.push(
        context, MaterialPageRoute(builder: (context) => RoomScreen(roomCode)));
  }

  Future<void> putPlayerInRoom(String roomCode) async {
    if (!await RoomManager.instance.docExists("games", roomCode)) {
      return;
    }

    if (!(await RoomManager.instance.getRoomData(roomCode))["gameStarted"]) {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => RoomScreen(roomCode)));
    }
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    double buttonsWidth = (screenSize.width > screenSize.height) ? 0.3 : 0.9;

    // Maybe in the future
    // String room = CookieManager.getCookie("room");
    // if (room.length == 4) {
    //   putPlayerInRoom(room);
    // }

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
