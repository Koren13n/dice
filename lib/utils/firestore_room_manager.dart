import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dice/utils/firestore_adapter.dart';
import 'package:dice/utils/cookie_manager.dart';

class RoomManager {
  FirestoreAdapter firestoreAdapter = FirestoreAdapter();
  Random random = Random();

  Future<bool> docExists(String collection, String docId) async {
    try {
      // Get reference to Firestore collection
      var collectionRef = FirebaseFirestore.instance.collection(collection);

      var doc = await collectionRef.doc(docId).get();
      return doc.exists;
    } catch (e) {
      throw e;
    }
  }

  Future<List<QueryDocumentSnapshot>> getRoomPlayers(String roomCode) async {
    QuerySnapshot query =
        await firestoreAdapter.getCollection("games/$roomCode/players");
    return query.docs;
  }

  Future<Map<String, dynamic>> getRoomData(String roomCode) async {
    print(roomCode);
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

    await firestoreAdapter
        .updateDocument("games", roomCode, {"gameStarted": false});
    await addPlayerToRoom(roomCode, playerName, isAdmin: true);
    return roomCode;
  }

  Future<void> startGame(String roomCode, int diceCount) async {
    await firestoreAdapter.updateDocument(
        "games", roomCode, {"gameStarted": true, "diceCount": diceCount});
  }

  Future<bool> addPlayerToRoom(String roomCode, String playerName,
      {bool isAdmin = false}) async {
    if (!await docExists("games", roomCode)) {
      return false;
    }
    await firestoreAdapter.updateDocument("games/$roomCode/players", playerName,
        {"name": playerName, "isAdmin": isAdmin});
    CookieManager.addToCookie("room", roomCode);
    return true;
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
