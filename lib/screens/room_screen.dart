import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:dice/utils/cookie_manager.dart';
import 'package:dice/utils/firestore_line_fetcher.dart';
import 'package:dice/utils/firestore_adapter.dart';

class RoomScreen extends StatefulWidget {
  RoomScreen(this.roomCode);
  final String roomCode;
  @override
  _RoomScreenState createState() => _RoomScreenState();
}

class _RoomScreenState extends State<RoomScreen> {
  FirestoreAdapter firestoreAdapter = FirestoreAdapter();
  final FirestoreLineFetcher firestoreLineFetcher = FirestoreLineFetcher();
  Map<String, dynamic> names;
  List<Widget> textWidgets = [];

  void leaveRoom(String roomCode, String name) async {
    FirebaseFirestore.instance
        .collection("games/$roomCode/players")
        .doc(name)
        .delete();
    Navigator.pop(context);
  }

  bool isAdmin = true;
  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    double buttonsWidth = (screenSize.width > screenSize.height) ? 0.3 : 0.9;

    String name = CookieManager.getCookie("name");
    final String roomCode = this.widget.roomCode;

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
          height: screenSize.height * 0.5,
          child: StreamBuilder(
              stream: firestoreLineFetcher
                  .getPlayersStreamFromFirestore(this.widget.roomCode),
              builder: (context, snapshot) {
                names = snapshot?.data ?? [];
                textWidgets = [];
                print(names["players"].length);
                print(names["players"]);
                print(isAdmin);
                for (int i = 0; i < names["players"].length; i++) {
                  textWidgets.add(Text(
                    names["players"][i]["name"],
                    style: TextStyle(fontSize: 26),
                  ));
                  textWidgets.add(SizedBox(height: screenSize.height * 0.005));
                  if (names["players"].length != 1) {
                    isAdmin = false;
                  }
                  if (names["players"][i]["name"] == name) {
                    isAdmin = names["players"][i]["isAdmin"];
                  }
                }

                return Column(children: textWidgets);
              }),
        ),
        Expanded(child: SizedBox()),
        isAdmin
            ? Container(
                height: screenSize.height * 0.1,
                width: screenSize.width * buttonsWidth,
                child: ElevatedButton(
                  onPressed: () => print("Hi"),
                  child: Text(
                    "Start Game",
                    style: TextStyle(fontSize: 36),
                  ),
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.purple[500]),
                  ),
                ),
              )
            : Text("Not Admin"),
        SizedBox(
          height: screenSize.height * 0.02,
        ),
        Container(
          height: screenSize.height * 0.1,
          width: screenSize.width * buttonsWidth,
          child: ElevatedButton(
            onPressed: () => leaveRoom(roomCode, name),
            child: Text(
              "Leave Room",
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
      ]),
    ));
  }
}
