import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class PresenceService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _rtdb = FirebaseDatabase.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  DatabaseReference? _statusRef;

  void init() {
    final user = _auth.currentUser;
    if (user == null) return;

    _statusRef = _rtdb.ref("status/${user.uid}");

    // Setup RTDB onDisconnect
    _statusRef!.onDisconnect().set({
      "state": "offline",
      "lastSeen": ServerValue.timestamp,
    });

    // Immediately set online
    setOnline(true);
  }

  Future<void> setOnline(bool online) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final data = {
      "state": online ? "online" : "offline",
      "lastSeen": ServerValue.timestamp,
    };

    // Write to RTDB
    await _statusRef?.set(data);

    // Mirror to Firestore (for queries and user docs)
    await _firestore.collection("users").doc(user.uid).update({
      "isOnline": online,
      "lastSeen": DateTime.now().millisecondsSinceEpoch,
    });
  }

  void dispose() {
    setOnline(false);
    _statusRef = null;
  }
}
