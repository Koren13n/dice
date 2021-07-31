import 'package:dice/utils/firestore_room_manager.dart';
import 'package:flutter/material.dart';

enum LoadingAction { JoinGame, CreateGame }

class LoadingScreen extends StatefulWidget {
  final LoadingAction action;
  final String name;

  LoadingScreen(this.action, this.name);

  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  Future<void> createRoom(String name) async {
    String roomCode = await RoomManager.instance.createRoom(name);
  }

  @override
  Widget build(BuildContext context) {
    RoomManager.instance
        .createRoom(this.widget.name)
        .then((value) => Navigator.pop(context, value));

    Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
        body: Center(
      child: Column(
        children: [
          SizedBox(
            height: screenSize.height * 0.1,
          ),
          Text("Creating room...",
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
