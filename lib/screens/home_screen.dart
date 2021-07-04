import 'package:dice/screens/join_screen.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text("Dice")),
        backgroundColor: Colors.purple[700],
        shadowColor: Colors.purple[900],
      ),
      body: Center(
        child: Column(
          children: [
            SizedBox(
              height: screenSize.height * 0.05,
            ),
            // Container(
            //   width: screenSize.width * 0.9,
            //   child: Text(
            //     "A fun game to play with friends!",
            //     style: TextStyle(fontSize: 26),
            //     textAlign: TextAlign.center,
            //   ),
            // ),
            Expanded(
              child: SizedBox(),
            ),
            Container(
              height: screenSize.height * 0.1,
              width: screenSize.width * 0.3,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => JoinScreen()));
                },
                child: Text(
                  "New Game",
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
            ),
            Container(
              height: screenSize.height * 0.1,
              width: screenSize.width * 0.3,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => JoinScreen()));
                },
                child: Text(
                  "Join Game",
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
          ],
        ),
      ),
    );
  }
}
