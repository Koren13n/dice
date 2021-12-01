import 'package:dice/screens/game_room.dart';
import 'package:dice/utils/cookie_manager.dart';
import 'package:flutter/material.dart';
import 'package:dice/screens/home_screen.dart';
import 'package:dice/screens/join_screen.dart';
import 'package:dice/screens/name_screen.dart';
import 'package:dice/screens/room_screen.dart';
import 'package:firebase_core/firebase_core.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
      title: 'Dice',
      theme: ThemeData(
        brightness: Brightness.light,
        /* light theme settings */
      ),
      darkTheme: ThemeData(brightness: Brightness.dark, fontFamily: 'Roboto'
          /* dark theme settings */
          ),
      themeMode: ThemeMode.dark,
      /* ThemeMode.system to follow system theme, 
         ThemeMode.light for light theme, 
         ThemeMode.dark for dark theme
      */
      debugShowCheckedModeBanner: false,
      // home: FirebaseLoginWrapper(),
      initialRoute: '/',
      routes: {
        '/': (context) => FirebaseLoginWrapper(),
        HomeScreen.route: (context) => HomeScreen(),
        NameScreen.route: (context) => NameScreen(),
        JoinScreen.route: (context) => JoinScreen(),
        RoomScreen.route: (context) =>
            RoomScreen(CookieManager.getCookie("room")),
        GameRoom.route: (context) => GameRoom(CookieManager.getCookie("room"))
      },
      onGenerateRoute: (settings) {
        final settingsUri = Uri.parse(settings.name);

        if (settingsUri.pathSegments.length == 0) {
          return MaterialPageRoute(builder: (context) => HomeScreen());
        }

        switch ("/" + settingsUri.pathSegments[0]) {
          case HomeScreen.route:
            return MaterialPageRoute(builder: (context) => HomeScreen());
          case NameScreen.route:
            return MaterialPageRoute(builder: (context) => NameScreen());
          case JoinScreen.route:
            return MaterialPageRoute(builder: (context) => JoinScreen());
          case RoomScreen.route:
            try {
              return MaterialPageRoute(
                  builder: (context) =>
                      RoomScreen(settingsUri.pathSegments[1]));
            } on RangeError {
              return MaterialPageRoute(builder: (context) => HomeScreen());
            }
        }

        return MaterialPageRoute(builder: (context) => HomeScreen());
      },
    );
  }
}
