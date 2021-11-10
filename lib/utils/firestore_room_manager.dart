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

  String _roomCode;
  Game _game;

  Future<bool> docExists(String collection, String docId) async {
    // Get reference to Firestore collection
    var collectionRef = FirebaseFirestore.instance.collection(collection);

    var doc = await collectionRef.doc(docId).get();
    return doc.exists;
  }

  void updateGame(Game game) {
    _game = game;
    _roomCode = CookieManager.getCookie("room");
  }

  void leaveRoom(Player player) async {
    bool wasAdmin = player.isAdmin;
    _game.players.remove(player);

    // Delete the room if empty
    if (_game.players.isEmpty) {
      FirebaseFirestore.instance.collection("games").doc(_roomCode).delete();
      return;
    }

    // Set new admin
    if (wasAdmin) {
      _game.players[0].isAdmin = true;
    }

    firestoreAdapter.updateDocument("games", _roomCode, _game.toJson(),
        merge: false);
    _roomCode = "";
    _game = null;
  }

  List<String> getPlayerNames() {
    return _game.players.map((player) => player.name).toList();
  }

  Future<bool> handleLie(String currentPlayerName, String lyingPlayerName,
      int diceType, int diceCount) async {
    List<int> allDiceCount = List.generate(6, (index) => 0);
    for (Player player in _game.players) {
      for (int dice in player.dice) {
        if (dice != 0) {
          allDiceCount[dice]++;
        } else {
          for (int i = 0; i < 6; i++) {
            allDiceCount[i]++;
          }
        }
      }
    }
    // Lie wasn't true, remove from the current player a dice.
    if (allDiceCount[diceType - 1] >= diceCount) {
      _game.players.forEach((player) {
        if (player.name == currentPlayerName) {
          if (player.diceCount > 0) {
            player.diceCount--;
          }
        }
      });
    }
    // Lie was true, remove from the lying player dice.
    else {
      _game.players.forEach((player) {
        if (player.name == lyingPlayerName) {
          if (player.diceCount > 0) {
            player.diceCount--;
          }
        }
      });
    }
    await rollPlayersDice();
    return true;
  }

  Future<Game> _getRoomData() async {
    DocumentSnapshot metadata =
        await firestoreAdapter.getDocument("games", _roomCode);
    return Game.fromJson(metadata.data());
  }

  Future<String> createRoom(String playerName) async {
    String newRoomCode;
    do {
      int newRoomCodeNumber = random.nextInt(10000);
      newRoomCode = newRoomCodeNumber.toString().padLeft(4, '0');
    } while (await docExists("games", newRoomCode));
    Game temp = Game(gameStarted: false);
    await firestoreAdapter.updateDocument("games/", newRoomCode, temp.toJson());
    await addPlayerToRoom(newRoomCode, playerName, isAdmin: true);
    return newRoomCode;
  }

  Future<void> startGame(int diceCount) async {
    _game.players.forEach((player) => player.diceCount = diceCount);
    rollPlayersDice();
    _game.diceCount = diceCount;
    _game.gameStarted = true;
    await firestoreAdapter.updateDocument("games", _roomCode, _game.toJson());
  }

  Future<AddPlayerResult> addPlayerToRoom(String newRoomCode, String playerName,
      {bool isAdmin = false}) async {
    if (!await docExists("games", newRoomCode)) {
      return AddPlayerResult.RoomDoesntExist;
    }

    _roomCode = newRoomCode;
    Game game = await _getRoomData();
    if (game.gameStarted) {
      return AddPlayerResult.GameStarted;
    }

    List<Player> players = game.players;
    for (var player in players) {
      if (player.name == playerName) {
        return AddPlayerResult.PlayerAlreadyInRoom;
      }
    }

    game.players.add(Player(playerName, isAdmin));
    print(game.toJson());

    await firestoreAdapter.updateDocument("games", _roomCode, game.toJson());
    CookieManager.addToCookie("room", newRoomCode);
    return AddPlayerResult.Success;
  }

  Future<void> rollPlayersDice() async {
    for (Player currentPlayer in _game.players) {
      currentPlayer.dice =
          List.generate(currentPlayer.diceCount, (_) => random.nextInt(6));
    }
    await firestoreAdapter.updateDocument("games", _roomCode, _game.toJson());
  }

  // Not changed to new DB design
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
