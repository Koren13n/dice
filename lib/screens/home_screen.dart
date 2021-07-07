import 'dart:math';
import 'package:dice/screens/room_screen.dart';
import 'package:flutter/material.dart';
import 'package:dice/utils/cookie_manager.dart';
import 'package:dice/screens/name_screen.dart';
import 'package:dice/screens/join_screen.dart';
import 'package:dice/utils/app_bar.dart';
import 'package:dice/screens/game_room.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dice/utils/firestore_adapter.dart';

class HomeScreen extends StatefulWidget {
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
    print("Joining room");
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => JoinScreen()));
  }

  Future<void> createRoom(BuildContext context) async {
    String name = await getName(context);
    int roomCodeNumber = random.nextInt(10000);
    String roomCode = roomCodeNumber.toString().padLeft(4, '0');
    await firestoreAdapter.addDocument(
        "games/$roomCode/players", {"name": name, "isAdmin": true});
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => RoomScreen(roomCode)));
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
