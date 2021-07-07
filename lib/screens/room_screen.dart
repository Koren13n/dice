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
  List<Map<String, dynamic>> names = [];
  List<Text> textWidgets = [];

  Future<QuerySnapshot> getRoomPlayers(String roomCode) async {
    QuerySnapshot players =
        await firestoreAdapter.getCollection("games/$roomCode/players");
    return players;
  }

  bool isAdmin = true;
  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    String name = CookieManager.getCookie("name");
    final String roomCode = this.widget.roomCode;

    return Scaffold(
        body: Center(
      child: Column(children: [
        Text(
          "Hi $name, You are in room $roomCode",
          style: TextStyle(fontSize: 36),
        ),
        StreamBuilder(
            stream: firestoreLineFetcher
                .getPlayersStreamFromFirestore(this.widget.roomCode),
            builder: (context, snapshot) {
              names = snapshot?.data ?? [];
              textWidgets = [];
              for (int i = 0; i < names.length; i++) {
                textWidgets.add(Text(names[i]["name"]));
                if (names.length != 1) {
                  isAdmin = false;
                }
                if (names[i]["name"] == name) {
                  isAdmin = names[i]["isAdmin"];
                }
              }

              print(names.length);
              print(names);
              print(isAdmin);
              return Column(children: textWidgets);
            }),
        Expanded(child: SizedBox()),
        isAdmin
            ? ElevatedButton(
                onPressed: () => print("Hi"),
                child: Text(
                  "Start Game",
                  style: TextStyle(fontSize: 36),
                ),
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.purple[500]),
                ),
              )
            : Text("Not Admin")
      ]),
    ));
  }
}
