import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dice/utils/firestore_adapter.dart';
import 'package:dice/screens/room_screen.dart';

class JoinScreen extends StatefulWidget {
  @override
  _JoinScreenState createState() => _JoinScreenState();
}

class _JoinScreenState extends State<JoinScreen> {
  final myController = TextEditingController();
  FirestoreAdapter firestoreAdapter = FirestoreAdapter();
  final scaffoldKey = GlobalKey<ScaffoldState>();
  Color textColor = Colors.red;

  @override
  void dispose() {
    myController.dispose();
    super.dispose();
  }

  Future<String> addPlayerToRoom(String roomCode) async {
    DocumentReference playerDoc = await firestoreAdapter
        .addDocument("games/" + roomCode + "/players", {"name": "Koren"});
    return playerDoc.id;
  }

  Future<String> joinRoom(String roomCode) async {
    return addPlayerToRoom(roomCode);
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
      body: Column(
        children: [
          SizedBox(height: screenSize.height * 0.05, width: screenSize.width),
          Text(
            "Dice",
            style: TextStyle(fontSize: 48),
          ),
          Text(
            "Room code",
            style: TextStyle(fontSize: 36),
          ),
          Container(
              width: screenSize.width * 0.5,
              child: TextField(
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
          SizedBox(
            height: screenSize.height * 0.04,
          ),
          ElevatedButton(
              style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.deepOrangeAccent),
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
                String userId = await joinRoom(myController.text);
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => RoomScreen()));
              }),
          Container(
              height: screenSize.height * 0.5,
              child: Image.asset("assets/photos/dice2.png")),
        ],
      ),
    );
  }
}
