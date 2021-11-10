import 'dart:html';

import 'package:dice/utils/firestore_game_fetcher.dart';
import 'package:dice/utils/firestore_players_fetcher.dart';
import 'package:dice/utils/firestore_room_manager.dart';
import 'package:dice/utils/game.dart';
import 'package:dice/utils/player.dart';
import 'package:flutter/material.dart';
import 'package:dice/utils/app_bar.dart';
import 'package:dice/utils/cookie_manager.dart';
import 'package:flutter/services.dart';
import 'package:numberpicker/numberpicker.dart';

const Map<int, String> dicePictures = {
  0: "assets/dice_numbers/dice-1.png",
  1: "assets/dice_numbers/dice-2.png",
  2: "assets/dice_numbers/dice-3.png",
  3: "assets/dice_numbers/dice-4.png",
  4: "assets/dice_numbers/dice-5.png",
  5: "assets/dice_numbers/dice-6.png"
};

class GameRoom extends StatefulWidget {
  static const String route = "/game";
  GameRoom(this.roomCode);
  final String roomCode;
  @override
  _GameRoomState createState() => _GameRoomState();
}

class _GameRoomState extends State<GameRoom> {
  int lieDiceNum = 1;
  int lieDiceCount = 1;
  int totalDiceCount = 0;
  String lieUser = "";
  final myController = TextEditingController();

  Future<void> _displayLieDialog(
      BuildContext context, Player currentPlayer) async {
    Size screenSize = MediaQuery.of(context).size;
    // Get a list of dropdown menu items with the player names
    List<String> playerNames = RoomManager.instance.getPlayerNames();
    playerNames.remove(currentPlayer);
    List<DropdownMenuItem<String>> playerNamesDropdowns =
        playerNames.map((name) {
      return DropdownMenuItem<String>(
        value: name,
        child: Text(
          name,
          style: TextStyle(color: Colors.white),
        ),
      );
    }).toList();
    lieUser = currentPlayer.name;

    List<DropdownMenuItem<String>> diceIcons =
        List<int>.generate(6, (i) => i + 1)
            .map<DropdownMenuItem<String>>((int value) {
      return DropdownMenuItem<String>(
        value: value.toString(),
        child: Text(value.toString()),
      );
    }).toList();

    int a = 5;

    return showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              title: Text('Who lied?'),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Player Select
                  DropdownButton<String>(
                    value: lieUser,
                    icon: const Icon(Icons.arrow_downward),
                    iconSize: 20,
                    elevation: 10,
                    style: const TextStyle(color: Colors.deepPurple),
                    underline: Container(
                      height: 2,
                    ),
                    onChanged: (String newValue) {
                      setState(() {
                        lieUser = newValue;
                      });
                    },
                    items: playerNamesDropdowns,
                  ),
                  SizedBox(height: screenSize.height * 0.04),
                  Text("Dice type"),
                  NumberPicker(
                    value: lieDiceNum,
                    axis: Axis.horizontal,
                    minValue: 1,
                    maxValue: 6,
                    step: 1,
                    haptics: true,
                    onChanged: (value) => setState(() => lieDiceNum = value),
                  ),
                  SizedBox(height: screenSize.height * 0.04),
                  Text("Dice count"),
                  NumberPicker(
                    value: lieDiceCount,
                    axis: Axis.horizontal,
                    minValue: 1,
                    maxValue: totalDiceCount,
                    step: 1,
                    haptics: true,
                    onChanged: (value) => setState(() => lieDiceCount = value),
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  style: ButtonStyle(),
                  child: Text('CANCEL'),
                  onPressed: () {
                    setState(() {
                      lieUser = "";
                      Navigator.pop(context);
                    });
                  },
                ),
                TextButton(
                  style: ButtonStyle(),
                  child: Text('OK'),
                  onPressed: () {
                    setState(() {
                      Navigator.pop(context);
                    });
                  },
                )
              ],
            );
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    double buttonsWidth = (screenSize.width > screenSize.height) ? 0.3 : 0.9;

    List<Player> players = [];
    String roomCode = this.widget.roomCode;
    String name = CookieManager.getCookie("name");
    lieUser = "";

    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Expanded(
                child: StreamBuilder(
              stream: getGameStreamFromFirestore(roomCode),
              builder: (context, gameSnapshot) {
                if (gameSnapshot.data == null) {
                  return CircularProgressIndicator();
                }
                Game game = Game.fromJson(gameSnapshot.data);
                RoomManager.instance.updateGame(game);
                Player currentPlayer;
                players = game.players;
                List<Widget> playersText = [];

                for (Player player in game.players) {
                  if (player.name == name) {
                    currentPlayer = player;
                  }
                  totalDiceCount += player.dice.length;
                }

                List<Widget> dicePicturs = currentPlayer.dice.map((diceNum) {
                  return SizedBox(
                    height: screenSize.height * 0.2,
                    child: Image.asset(
                      dicePictures[diceNum],
                      width: screenSize.width * 0.1,
                    ),
                  );
                }).toList();

                // Create a list of all of the players dice
                for (Player player in players) {
                  playersText.add(Text(
                    player.name + "   -   " + player.dice?.length.toString() ??
                        0,
                    textAlign: TextAlign.center,
                  ));
                }

                return Column(
                  children: [
                    SizedBox(
                      height: screenSize.height * 0.02,
                    ),
                    Text(
                      "Player's dice count",
                      style: TextStyle(fontSize: 28),
                    ),
                    SizedBox(
                      height: screenSize.height * 0.02,
                    ),
                    SizedBox(
                      height: (playersText.length / 3 + 1) *
                          screenSize.height *
                          0.03,
                      child: GridView.count(
                          crossAxisCount: 3,
                          childAspectRatio: 8 / 1,
                          mainAxisSpacing: screenSize.height * 0.02,
                          crossAxisSpacing: screenSize.width * 0.02,
                          children: playersText),
                    ),
                    SizedBox(height: screenSize.height * 0.05),
                    Text(
                      "Total: " + totalDiceCount.toString(),
                      style: TextStyle(fontSize: 22),
                    ),
                    SizedBox(height: screenSize.height * 0.05),
                    Expanded(
                      child: Row(
                        children: [
                          SizedBox(width: screenSize.width * 0.1),
                          Expanded(
                              child: GridView.count(
                            crossAxisCount: 3,
                            children: dicePicturs,
                            crossAxisSpacing: screenSize.width * 0.10,
                            mainAxisSpacing: screenSize.height * 0.02,
                          )),
                          SizedBox(width: screenSize.width * 0.1)
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        SizedBox(width: screenSize.width * 0.01),
                        Container(
                          height: screenSize.height * 0.1,
                          width: screenSize.width * 0.48,
                          child: ElevatedButton(
                            onPressed: () async {
                              await _displayLieDialog(context, currentPlayer);
                              if (lieUser != "") {
                                if (await RoomManager.instance.handleLie(
                                    currentPlayer.name,
                                    lieUser,
                                    lieDiceNum,
                                    lieDiceCount)) {
                                  print("You were right!");
                                } else {
                                  print("You were wrong!");
                                }
                              }
                            },
                            child: Text(
                              "Lie!",
                              style: TextStyle(fontSize: 36),
                            ),
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  Colors.purple[500]),
                            ),
                          ),
                        ),
                        SizedBox(width: screenSize.width * 0.02),
                        Container(
                          height: screenSize.height * 0.1,
                          width: screenSize.width * 0.48,
                          child: ElevatedButton(
                            onPressed: () {},
                            child: Text(
                              "Leave Room",
                              style: TextStyle(fontSize: 36),
                            ),
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  Colors.purple[500]),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: screenSize.height * 0.02,
                    ),
                    SizedBox(
                      height: screenSize.height * 0.02,
                    )
                  ],
                );
              },
            ))
          ],
        ),
      ),
    );
  }
}
