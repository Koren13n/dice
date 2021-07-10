import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dice/utils/app_bar.dart';
import 'package:dice/utils/cookie_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dice/utils/firestore_adapter.dart';
import 'package:dice/screens/room_screen.dart';
import 'package:dice/utils/firestore_room_manager.dart';

class JoinScreen extends StatefulWidget {
  @override
  _JoinScreenState createState() => _JoinScreenState();
}

class _JoinScreenState extends State<JoinScreen> {
  final myController = TextEditingController();
  FirestoreAdapter firestoreAdapter = FirestoreAdapter();
  final scaffoldKey = GlobalKey<ScaffoldState>();
  Color textColor = Colors.red;
  RoomManager roomManager = RoomManager();
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

  Future<bool> joinRoom(String roomCode) async {
    return await roomManager.addPlayerToRoom(roomCode, name);
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    double buttonsWidth = (screenSize.width > screenSize.height) ? 0.3 : 0.9;

    return Scaffold(
      appBar: DiceAppBar(),
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
                  if (!await joinRoom(myController.text)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "Room doesn't exist!",
                          style: TextStyle(color: Colors.white),
                        ),
                        duration: Duration(seconds: 2),
                        backgroundColor: Colors.black,
                      ),
                    );
                    return;
                  }
                  await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => RoomScreen(myController.text)));
                  Navigator.pop(context);
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
