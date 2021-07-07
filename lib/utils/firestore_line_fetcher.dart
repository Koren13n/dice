import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dice/utils/firestore_adapter.dart';

class FirestoreLineFetcher {
  FirestoreAdapter firestoreAdapter = FirestoreAdapter();

  Stream<List<Map<String, dynamic>>> getPlayersStreamFromFirestore(
      String roomCode) {
    return firestoreAdapter
        .getCollectionStream("games/$roomCode/players")
        .map((snapshot) {
      List<Map<String, dynamic>> names = [];

      for (DocumentSnapshot document in snapshot?.docs ?? []) {
        names.add({
          "name": document.data()["name"],
          "isAdmin": document.data()["isAdmin"]
        });
      }

      return names;
    });
  }
}
