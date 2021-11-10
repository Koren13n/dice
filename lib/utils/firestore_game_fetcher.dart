import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dice/utils/firestore_adapter.dart';
import 'package:dice/utils/player.dart';

Stream<Map<String, dynamic>> getGameStreamFromFirestore(String roomCode) {
  FirestoreAdapter firestoreAdapter = FirestoreAdapter();
  return firestoreAdapter.getDocumentStream("games", roomCode).asBroadcastStream().map((snapshot) {
    return snapshot?.data() ?? {};
  });
}
