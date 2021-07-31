import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dice/utils/firestore_adapter.dart';
import 'package:dice/utils/player.dart';

class FirestoreGameFetcher {
  FirestoreAdapter firestoreAdapter = FirestoreAdapter();
  static final FirestoreGameFetcher _singleton = FirestoreGameFetcher._();

  static FirestoreGameFetcher get instance => _singleton;

  FirestoreGameFetcher._();

  Stream<Map<String, dynamic>> getGameStreamFromFirestore(String roomCode) {
    return firestoreAdapter
        .getDocumentStream("games", roomCode)
        .map((snapshot) {
      return snapshot?.data() ?? {};
    });
  }
}
