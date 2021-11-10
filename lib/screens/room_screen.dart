import 'dart:html';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dice/utils/firestore_game_fetcher.dart';
import 'package:dice/utils/firestore_room_manager.dart';
import 'package:dice/utils/game.dart';
import 'package:dice/utils/player.dart';
import 'package:flutter/material.dart';
import 'package:dice/screens/game_room.dart';
import 'package:dice/utils/cookie_manager.dart';
import 'package:dice/utils/firestore_players_fetcher.dart';
import 'package:dice/utils/firestore_adapter.dart';

class RoomScreen extends StatefulWidget {
  static const String route = "/room";
  RoomScreen(this.roomCode);
  final String roomCode;
  @override
  _RoomScreenState createState() => _RoomScreenState();
}

class _RoomScreenState extends State<RoomScreen> {
  FirestoreAdapter firestoreAdapter = FirestoreAdapter();
  String diceCount = "6";
  bool gameStarted = false;

  Future<void> _displayTextInputDialog(
      BuildContext context, Player currentPlayer) async {
    return showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              title: Text('Choose the dice count'),
              content: DropdownButton<String>(
                value: diceCount,
                icon: const Icon(Icons.arrow_downward),
                iconSize: 24,
                elevation: 16,
                style: const TextStyle(color: Colors.deepPurple),
                underline: Container(
                  height: 2,
                ),
                onChanged: (String newValue) {
                  setState(() {
                    diceCount = newValue;
                  });
                },
                items: List<int>.generate(10, (i) => i + 1)
                    .map<DropdownMenuItem<String>>((int value) {
                  return DropdownMenuItem<String>(
                    value: value.toString(),
                    child: Text(value.toString()),
                  );
                }).toList(),
              ),
              actions: <Widget>[
                TextButton(
                  style: ButtonStyle(),
                  child: Text('CANCEL'),
                  onPressed: () {
                    setState(() {
                      Navigator.pop(context);
                    });
                  },
                ),
                TextButton(
                  child: Text('OK'),
                  onPressed: () {
                    setState(() {
                      RoomManager.instance.rollPlayersDice();
                      RoomManager.instance.startGame(int.parse(diceCount));
                      Navigator.pushNamed(context, GameRoom.route);
                    });
                  },
                ),
              ],
            );
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    double buttonsWidth = (screenSize.width > screenSize.height) ? 0.3 : 0.9;

    String name = CookieManager.getCookie("name");
    final String roomCode = this.widget.roomCode;
    List<Player> players = [];

    return Scaffold(
        body: Center(
      child: Column(children: [
        SizedBox(
          height: screenSize.height * 0.05,
        ),
        Container(
          width: screenSize.width * 0.9,
          child: Text("Hi $name, You are in room $roomCode",
              style: TextStyle(fontSize: 32), textAlign: TextAlign.center),
        ),
        SizedBox(
          height: screenSize.height * 0.03,
        ),
        Container(
          child: StreamBuilder(
              stream: getGameStreamFromFirestore(roomCode),
              builder: (context, roomSnapshot) {
                if (roomSnapshot.data == null) {
                  return SizedBox(
                    height: screenSize.height * 0.1,
                    child: CircularProgressIndicator(
                      strokeWidth: 5,
                    ),
                  );
                }
                Game game = Game.fromJson(roomSnapshot.data);
                RoomManager.instance.updateGame(game);
                List<Widget> columnWidgets = [];
                Player currentPlayer;

                // Create a list of texts with all of the players names
                for (var player in game.players) {
                  columnWidgets.add(Text(
                    player.name,
                    style: TextStyle(fontSize: 26),
                  ));
                  columnWidgets
                      .add(SizedBox(height: screenSize.height * 0.005));

                  if (player.name == name) {
                    currentPlayer = player;
                  }
                }

                columnWidgets.add(Expanded(child: SizedBox()));

                // Add the start game button for the admin
                if (currentPlayer?.isAdmin ?? false) {
                  columnWidgets.add(Container(
                    height: screenSize.height * 0.1,
                    width: screenSize.width * buttonsWidth,
                    child: ElevatedButton(
                      onPressed: () =>
                          _displayTextInputDialog(context, currentPlayer),
                      child: Text(
                        "Start Game",
                        style: TextStyle(fontSize: 36),
                      ),
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                            Colors.purple[500]),
                      ),
                    ),
                  ));
                }

                columnWidgets.add(SizedBox(
                  height: screenSize.height * 0.02,
                ));

                // Add the leave room button
                columnWidgets.add(Container(
                  height: screenSize.height * 0.1,
                  width: screenSize.width * buttonsWidth,
                  child: ElevatedButton(
                    onPressed: () {
                      RoomManager.instance.leaveRoom(currentPlayer);
                      Navigator.pop(context);
                    },
                    child: Text(
                      "Leave Room",
                      style: TextStyle(fontSize: 36),
                    ),
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.purple[500]),
                    ),
                  ),
                ));

                // Add some spacing before the end of the screen
                columnWidgets.add(SizedBox(
                  height: screenSize.height * 0.02,
                ));

                if (game.gameStarted && !gameStarted) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    Navigator.pushNamed(context, GameRoom.route);
                  });
                  gameStarted = true;
                }

                return Expanded(child: Column(children: columnWidgets));
              }),
        )
      ]),
    ));
  }
}
