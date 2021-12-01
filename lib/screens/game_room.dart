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

final String noLieUser = "Choose Lier";

class _GameRoomState extends State<GameRoom> {
  int lieDiceNum = 1;
  int lieDiceCount = 1;
  int totalDiceCount = 0;
  String lieUser = "";
  bool liePressed = false;
  Game previousGameState = null;
  final myController = TextEditingController();

  Future<void> _displayPreviousDiceNums(
      BuildContext context, Game previousGame) async {
    Size screenSize = MediaQuery.of(context).size;
    List<Widget> playersDiceNums = [];

    for (Player player in previousGame.players) {
      List<Text> playerDiceNumsStrings = [];
      playerDiceNumsStrings.add(Text(player.name));
      player.dice.forEach((diceNum) =>
          playerDiceNumsStrings.add(Text((diceNum + 1).toString())));
      playersDiceNums.add(Container(
        child: Column(children: playerDiceNumsStrings),
        width: screenSize.width * 0.2,
        height: screenSize.height * 0.35,
      ));
    }

    GridView playersDiceGrid =
        GridView.count(crossAxisCount: 3, children: playersDiceNums);
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Players\' Dice'),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: screenSize.height * 0.7,
                  width: screenSize.width * 0.7,
                  child: playersDiceGrid,
                )
              ],
            ),
            actions: <Widget>[
              TextButton(
                style: ButtonStyle(),
                child: Text('OK'),
                onPressed: () {
                  Navigator.pop(context);
                },
              )
            ],
          );
        });
  }

  Future<void> _displayLieDialog(
      BuildContext context, Player currentPlayer) async {
    Size screenSize = MediaQuery.of(context).size;
    // Get a list of dropdown menu items with the player names
    List<String> playerNames = RoomManager.instance.getActivePlayerNames();
    playerNames.remove(currentPlayer.name);
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
    playerNamesDropdowns.add(DropdownMenuItem<String>(
        value: noLieUser,
        child: Text(
          noLieUser,
          style: TextStyle(color: Colors.white),
        )));
    lieUser = noLieUser;

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
                      lieUser = noLieUser;
                      Navigator.pop(context);
                    });
                  },
                ),
                TextButton(
                  style: ButtonStyle(),
                  child: Text('OK'),
                  onPressed: () {
                    setState(() async {
                      if (lieUser == noLieUser) {
                        await showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                content: Text("Please choose lier"),
                                actions: [
                                  TextButton(
                                      child: Text("OK"),
                                      onPressed: () {
                                        Navigator.pop(context);
                                      })
                                ],
                              );
                            });
                      } else {
                        liePressed = true;
                        Navigator.pop(context);
                      }
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

                int newTotalDiceCount = 0;
                for (Player player in game.players) {
                  if (player.name == name) {
                    currentPlayer = player;
                  }
                  newTotalDiceCount += player.dice.length;
                }

                // On the first run we just initialize
                if (newTotalDiceCount != totalDiceCount &&
                    previousGameState == null) {
                  previousGameState = Game.fromJson(game.toJson());
                  totalDiceCount = newTotalDiceCount;
                }
                // a dice was removed
                else if (newTotalDiceCount != totalDiceCount) {
                  // TODO: Show the prevoius counts
                  // Future.delayed(
                  //     Duration.zero,
                  //     () async => await _displayPreviousDiceNums(
                  //         context, previousGameState));
                  previousGameState = Game.fromJson(game.toJson());
                  totalDiceCount = newTotalDiceCount;
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
                            onPressed: currentPlayer.diceCount == 0
                                ? null
                                : () async {
                                    await _displayLieDialog(
                                        context, currentPlayer);
                                    if (liePressed && lieUser != noLieUser) {
                                      liePressed = false;
                                      await RoomManager.instance.handleLie(
                                          currentPlayer.name,
                                          lieUser,
                                          lieDiceNum,
                                          lieDiceCount);
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
                            onPressed: () async {
                              RoomManager.instance.leaveRoom(currentPlayer);
                              Navigator.popAndPushNamed(context, '/');
                            },
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
