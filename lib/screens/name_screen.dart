import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dice/utils/cookie_manager.dart';
import 'package:dice/utils/app_bar.dart';

class NameScreen extends StatefulWidget {
  @override
  State<NameScreen> createState() => _NameScreenState();
}

class _NameScreenState extends State<NameScreen> {
  final myController = TextEditingController();
  Color lineColor = Colors.red;

  void saveUserName(BuildContext context, String username) {
    CookieManager.addToCookie("name", username);
    Navigator.pop(context);
  }

  @override
  void dispose() {
    myController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    bool wideScreen = (screenSize.width > screenSize.height);
    double buttonsWidth = wideScreen ? 0.3 : 0.9;
    double textFieldWidth = wideScreen ? 0.5 : 0.7;

    return Scaffold(
      appBar: DiceAppBar(),
      body: Center(
        child: Column(
          children: [
            SizedBox(
              height: screenSize.height * 0.05,
            ),
            Text("Please enter your name",
                style: TextStyle(fontSize: 26), textAlign: TextAlign.center),
            Container(
              width: screenSize.width * textFieldWidth,
              child: TextField(
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28),
                enabled: true,
                autofocus: true,
                onChanged: (text) {
                  print(text);
                  if (text.length >= 4) {
                    setState(() {
                      lineColor = Colors.green;
                    });
                  } else {
                    setState(() {
                      lineColor = Colors.red;
                    });
                  }
                },
                keyboardType: TextInputType.name,
                decoration: InputDecoration(
                    focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: lineColor),
                )),
                controller: myController,
              ),
            ),
            Expanded(child: SizedBox()),
            Container(
              height: screenSize.height * 0.1,
              width: screenSize.width * buttonsWidth,
              child: ElevatedButton(
                onPressed: () {
                  if (myController.text.length < 4) {
                    return;
                  }
                  CookieManager.addToCookie("name", myController.text);
                  Navigator.pop(context, myController.text);
                },
                child: Text(
                  "Continue",
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
