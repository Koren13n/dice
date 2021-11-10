import 'package:dice/utils/player.dart';

class Game {
  bool gameStarted;
  int diceCount;
  List<Player> players;

  Game({this.gameStarted}) {
    diceCount = 0;
    players = [];
  }

  Game.fromJson(Map<String, dynamic> json) {
    gameStarted = json["gameStarted"];
    diceCount = json["diceCount"];
    players = [];
    for (Map<String, dynamic> playerJson in json["players"]) {
      players.add(Player.fromJson(playerJson));
    }
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> gameJson = {
      "gameStarted": this.gameStarted,
      "diceCount": this.diceCount
    };
    if (players.isEmpty) {
      gameJson["players"] = [];
      return gameJson;
    }
    List<Map<String, dynamic>> jsonPlayers = [];
    for (Player player in players) {
      Map<String, dynamic> playerJson = player.toJson();
      jsonPlayers.add(playerJson);
    }
    gameJson["players"] = jsonPlayers;
    return gameJson;
  }
}
