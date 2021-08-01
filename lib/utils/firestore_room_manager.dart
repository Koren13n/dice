import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dice/utils/firestore_adapter.dart';
import 'package:dice/utils/cookie_manager.dart';
import 'package:dice/utils/game.dart';
import 'package:dice/utils/player.dart';

enum AddPlayerResult {
  Success,
  RoomDoesntExist,
  PlayerAlreadyInRoom,
  GameStarted
}

class RoomManager {
  FirestoreAdapter firestoreAdapter = FirestoreAdapter();
  Random random = Random();
  static final RoomManager _singleton = RoomManager._();

  static RoomManager get instance => _singleton;

  RoomManager._();

  Future<bool> docExists(String collection, String docId) async {
    // Get reference to Firestore collection
    var collectionRef = FirebaseFirestore.instance.collection(collection);

    var doc = await collectionRef.doc(docId).get();
    return doc.exists;
  }

  void leaveRoom(String roomCode, String name) async {
    List<Player> roomPlayers = await getRoomPlayers(roomCode);
    roomPlayers.removeWhere((player) => player.name == name);
    FirebaseFirestore.instance
        .collection("games/$roomCode/players")
        .doc(name)
        .delete();
    // Delete the room if empty
    if (roomPlayers.isEmpty) {
      FirebaseFirestore.instance.collection("games").doc(roomCode).delete();
      return;
    }

    Player newAdmin = roomPlayers[0];
    newAdmin.isAdmin = true;
    firestoreAdapter.updateDocument(
        "games/$roomCode/players", newAdmin.name, newAdmin.toJson());
  }

  Future<List<Player>> getRoomPlayers(String roomCode) async {
    List<Player> players = [];
    QuerySnapshot query =
        await firestoreAdapter.getCollection("games/$roomCode/players");
    for (var player in query.docs) {
      players.add(Player.fromJson(player.data()));
    }
    return players;
  }

  Future<Map<String, dynamic>> getRoomData(String roomCode) async {
    DocumentSnapshot metadata =
        await firestoreAdapter.getDocument("games", roomCode);
    return metadata.data();
  }

  Future<String> createRoom(String playerName) async {
    String roomCode;
    do {
      int roomCodeNumber = random.nextInt(10000);
      roomCode = roomCodeNumber.toString().padLeft(4, '0');
    } while (await docExists("games", roomCode));

    await firestoreAdapter.updateDocument(
        "games", roomCode, Game(gameStarted: false).toJson());
    await addPlayerToRoom(roomCode, playerName, isAdmin: true);
    return roomCode;
  }

  Future<void> startGame(String roomCode, int diceCount) async {
    await firestoreAdapter.updateDocument(
        "games", roomCode, {"gameStarted": true, "diceCount": diceCount});
  }

  Future<AddPlayerResult> addPlayerToRoom(String roomCode, String playerName,
      {bool isAdmin = false}) async {
    if (!await docExists("games", roomCode)) {
      return AddPlayerResult.RoomDoesntExist;
    }
    List<Player> players = await getRoomPlayers(roomCode);
    for (var player in players) {
      if (player.name == playerName) {
        return AddPlayerResult.PlayerAlreadyInRoom;
      }
    }

    Game game = Game.fromJson(await getRoomData(roomCode));
    if (game.gameStarted) {
      return AddPlayerResult.GameStarted;
    }

    await firestoreAdapter.updateDocument("games/$roomCode/players", playerName,
        {"name": playerName, "isAdmin": isAdmin});
    CookieManager.addToCookie("room", roomCode);
    return AddPlayerResult.Success;
  }

  Future<bool> removePlayerFromRoom(String roomCode, String playerName) async {
    if (!await docExists("games", roomCode) ||
        !await docExists("games/$roomCode/players", playerName)) {
      return false;
    }

    FirebaseFirestore.instance
        .collection("games/$roomCode/players")
        .doc(playerName)
        .delete();

    CookieManager.addToCookie("room", "");
    return true;
  }
}
