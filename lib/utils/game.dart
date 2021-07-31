class Game {
  bool gameStarted;

  Game({this.gameStarted});

  Game.fromJson(Map<String, dynamic> json) : gameStarted = json["gameStarted"];

  Map<String, dynamic> toJson() => {"gameStarted": this.gameStarted};
}
