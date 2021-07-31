import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dice/utils/firestore_adapter.dart';
import 'package:dice/utils/player.dart';
import 'package:flutter/material.dart';

class FirestorePlayersFetcher {
  FirestoreAdapter firestoreAdapter = FirestoreAdapter();

  Stream<Map<String, dynamic>> getPlayersStreamFromFirestore(String roomCode) {
    return firestoreAdapter
        .getCollectionStream("games/$roomCode/players")
        .map((snapshot) {
      List<Player> players = [];

      for (DocumentSnapshot document in snapshot?.docs ?? []) {
        players.add(Player.fromJson(document.data()));
      }

      Map<String, dynamic> roomData = {"players": players};

      return roomData;
    });
  }
}
