class Player {
  String name;
  bool isAdmin;
  int diceCount;
  List<dynamic> dice;

  Player(this.name, this.isAdmin, {this.diceCount = 0, this.dice = const []});

  Player.fromJson(Map<String, dynamic> json)
      : name = json["name"],
        isAdmin = json["isAdmin"],
        diceCount = json["diceCount"],
        dice = json["dice"];

  Map<String, dynamic> toJson() => {
        "name": this.name,
        "isAdmin": this.isAdmin,
        "diceCount": diceCount,
        "dice": this.dice
      };
}
