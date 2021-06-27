import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dice/utils/firestore_adapter.dart';
import 'package:dice/screens/room_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final myController = TextEditingController();
  FirestoreAdapter firestoreAdapter = FirestoreAdapter();

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
    QuerySnapshot gamesData = await firestoreAdapter.getCollection("games");
    for (int i = 0; i < gamesData.docs.length; i++) {
      if (gamesData.docs[i].id == roomCode) {
        return addPlayerToRoom(roomCode);
      }
    }
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
            "DICE",
            style: TextStyle(fontSize: 48),
          ),
          Container(
              height: screenSize.height * 0.5,
              child: Image.asset("assets/photos/dice2.png")),
          Text(
            "Room code",
            style: TextStyle(fontSize: 36),
          ),
          Container(
              width: screenSize.width * 0.8,
              child: TextField(
                style: TextStyle(fontSize: 36),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                controller: myController,
              )),
          SizedBox(
            height: screenSize.height * 0.05,
          ),
          TextButton(
              child: Text(
                "Join Room",
                style: TextStyle(fontSize: 36),
              ),
              onPressed: () async {
                if (myController.text.length != 4)
                {
                  
                }
                String userId = await joinRoom(myController.text);
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => RoomScreen()));
              })
        ],
      ),
    );
  }
}
