import 'package:flutter/material.dart';
import 'package:dice/screens/home_screen.dart';
import 'package:firebase_core/firebase_core.dart';

void main() {
  runApp(MyApp());
}

enum FirebaseState { Loading, Error, Done }

class FirebaseLoginWrapper extends StatelessWidget {
  FirebaseLoginWrapper();
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        // Initialize FlutterFire:
        future: _initialization,
        builder: (context, snapshot) {
          FirebaseState connectionState = snapshot.hasError
              // ignore: unnecessary_statements
              ? FirebaseState.Error
              : (snapshot.connectionState == ConnectionState.done)
                  ? FirebaseState.Done
                  : FirebaseState.Loading;

          switch (connectionState) {
            case FirebaseState.Loading:
              return Text("loading");
              break;
            case FirebaseState.Error:
              return Text("error");
              break;
            case FirebaseState.Done:
              return HomeScreen();
              break;
          }

          return Text("Unexpected");
        });
  }
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Title',
      theme: ThemeData(
        brightness: Brightness.light,
        /* light theme settings */
      ),
      darkTheme: ThemeData(brightness: Brightness.dark, fontFamily: 'Frighter'
          /* dark theme settings */
          ),
      themeMode: ThemeMode.dark,
      /* ThemeMode.system to follow system theme, 
         ThemeMode.light for light theme, 
         ThemeMode.dark for dark theme
      */
      debugShowCheckedModeBanner: false,
      home: FirebaseLoginWrapper(),
    );
  }
}
