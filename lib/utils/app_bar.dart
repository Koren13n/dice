import 'package:dice/main.dart';
import 'package:flutter/material.dart';

class DiceAppBar extends AppBar {
  DiceAppBar({Key key, Widget title})
      : super(
          key: key,
          centerTitle: true,
          title: Text(
            "Dice",
            style: TextStyle(fontSize: 48),
          ),
          backgroundColor: Colors.purple[700],
          shadowColor: Colors.purple[900],
        );
}
