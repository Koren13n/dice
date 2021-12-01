import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dice/screens/loading_screen.dart';
import 'package:dice/utils/app_bar.dart';
import 'package:dice/utils/cookie_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dice/utils/firestore_adapter.dart';
import 'package:dice/screens/room_screen.dart';
import 'package:dice/utils/firestore_room_manager.dart';

class JoinScreen extends StatefulWidget {
  static const String route = "/join";

  @override
  _JoinScreenState createState() => _JoinScreenState();
}

class _JoinScreenState extends State<JoinScreen> {
  final myController = TextEditingController();
  FirestoreAdapter firestoreAdapter = FirestoreAdapter();
  final scaffoldKey = GlobalKey<ScaffoldState>();
  Color textColor = Colors.red;
  String name = CookieManager.getCookie("name");

  @override
  void dispose() {
    myController.dispose();
    super.dispose();
  }

  Future<String> addPlayerToRoom(String roomCode) async {
    await firestoreAdapter.updateDocument(
        "games/$roomCode/players/", name, {"name": name, "isAdmin": false});
    return name;
  }

  void showSnackbar(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        text,
        style: TextStyle(color: Colors.white),
      ),
      duration: Duration(seconds: 2),
      backgroundColor: Colors.black,
    ));
  }

  Future<void> joinRoom(String roomCode) async {
    // AddPlayerResult result = await Navigator.push(
    //     context,
    //     MaterialPageRoute(
    //         builder: (context) => LoadingScreen(
    //               LoadingAction.JoinGame,
    //               name,
    //               roomCode: roomCode,
    //             )));
    AddPlayerResult result =
        await RoomManager.instance.addPlayerToRoom(roomCode, name);
    switch (result) {
      case AddPlayerResult.RoomDoesntExist:
        showSnackbar("Room doesn't exist!");
        return;

      case AddPlayerResult.PlayerAlreadyInRoom:
        showSnackbar(
            "A player with the same name as yours is already in the room.");
        return;

      case AddPlayerResult.GameStarted:
        showSnackbar("The game in this room has already started");
        return;

      case AddPlayerResult.Success:
        Navigator.pushNamed(context, RoomScreen.route);
    }
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    double buttonsWidth = (screenSize.width > screenSize.height) ? 0.3 : 0.9;

    return Scaffold(
      appBar: DiceAppBar(),
      // endDrawer: Drawer(
      //   child: Column(
      //     children: [Text("Hi"), Text("Hello")],
      //   ),
      // ),
      body: Column(
        children: [
          SizedBox(height: screenSize.height * 0.05, width: screenSize.width),
          Text(
            "Room code",
            style: TextStyle(fontSize: 36),
          ),
          Container(
              width: screenSize.width * 0.5,
              child: TextField(
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28),
                onChanged: (text) {
                  if (text.length == 4) {
                    setState(() {
                      textColor = Colors.green;
                    });
                  } else {
                    setState(() {
                      textColor = Colors.red;
                    });
                  }
                },
                decoration: InputDecoration(
                    focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: textColor),
                )),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                controller: myController,
              )),
          Expanded(child: SizedBox()),
          Container(
            height: screenSize.height * 0.1,
            width: screenSize.width * buttonsWidth,
            child: ElevatedButton(
                style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.purple[500]),
                    padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                      EdgeInsets.fromLTRB(
                          screenSize.width * 0.07,
                          screenSize.height * 0.015,
                          screenSize.width * 0.07,
                          screenSize.height * 0.015),
                    )),
                child: Text(
                  "Join",
                  style: TextStyle(fontSize: 36, color: Colors.white),
                ),
                onPressed: () async {
                  if (myController.text.length != 4) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "Room code should be 4 digits!",
                          style: TextStyle(color: Colors.white),
                        ),
                        duration: Duration(seconds: 2),
                        backgroundColor: Colors.black,
                      ),
                    );
                    return;
                  }
                  await joinRoom(myController.text);
                }),
          ),
          SizedBox(
            height: screenSize.height * 0.02,
          )
        ],
      ),
    );
  }
}
