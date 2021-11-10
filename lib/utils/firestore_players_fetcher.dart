import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dice/utils/firestore_adapter.dart';
import 'package:dice/utils/player.dart';
import 'package:flutter/material.dart';

Stream<Map<String, dynamic>> getPlayersStreamFromFirestore(String roomCode) {
  FirestoreAdapter firestoreAdapter = FirestoreAdapter();
  return firestoreAdapter
      .getCollectionStream("games/$roomCode/players")
      .asBroadcastStream()
      .map((snapshot) {
    List<Player> players = [];

    for (DocumentSnapshot document in snapshot?.docs ?? []) {
      players.add(Player.fromJson(document.data()));
    }

    Map<String, dynamic> roomData = {"players": players};

    return roomData;
  });
}
