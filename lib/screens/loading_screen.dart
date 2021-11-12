import 'package:dice/utils/firestore_room_manager.dart';
import 'package:flutter/material.dart';

enum LoadingAction { JoinGame, CreateGame }

class LoadingScreen extends StatefulWidget {
  final LoadingAction action;
  final String name;
  final String roomCode;

  LoadingScreen(this.action, this.name, {this.roomCode});

  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  Future<void> createRoom(String name) async {
    String roomCode = await RoomManager.instance.createRoom(name);
  }

  @override
  Widget build(BuildContext context) {
    String screenText = "";

    switch (widget.action) {
      case LoadingAction.CreateGame:
        RoomManager.instance
            .createRoom(this.widget.name)
            .then((value) => Navigator.pop(context, value));
        screenText = "Creating room...";
        break;
      case LoadingAction.JoinGame:
        RoomManager.instance
            .addPlayerToRoom(widget.roomCode, widget.name)
            .then((value) => Navigator.pop(context, value));
        screenText = "Joining room...";
        break;
    }

    Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
        body: Center(
      child: Column(
        children: [
          SizedBox(
            height: screenSize.height * 0.1,
          ),
          Text(screenText,
              style: TextStyle(fontSize: 32), textAlign: TextAlign.center),
          SizedBox(height: screenSize.height * 0.1),
          CircularProgressIndicator(
            strokeWidth: 5,
          ),
        ],
      ),
    ));
  }
}
