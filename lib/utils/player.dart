class Player {
  String name;
  bool isAdmin;

  Player(this.name, this.isAdmin);

  Player.fromJson(Map<String, dynamic> json)
      : name = json["name"],
        isAdmin = json["isAdmin"];

  Map<String, dynamic> toJson() => {"name": this.name, "isAdmin": this.isAdmin};
}
