import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:postie/models/friend_request_model.dart';
import 'package:postie/models/user_model.dart';

class FriendRepositoryFS {
  FriendRepositoryFS({FirebaseFirestore? firestore})
    : fs = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore fs;

  // Collections
  CollectionReference<Map<String, dynamic>> get _users =>
      fs.collection('users');
  CollectionReference<Map<String, dynamic>> get _userPhones =>
      fs.collection('userPhones');
  CollectionReference<Map<String, dynamic>> get _friendRequests =>
      fs.collection('friendRequests');
  CollectionReference<Map<String, dynamic>> _friends(String uid) =>
      fs.collection('friends').doc(uid).collection('edges');

  // ----------------------- Streams -----------------------

  /// Pending requests where I am the receiver
  Stream<List<FriendRequestItem>> streamIncoming(String myUid) {
    return _friendRequests
        .where('toUid', isEqualTo: myUid)
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (qs) =>
              qs.docs.map((d) => FriendRequestItem.fromMap(d.data())).toList(),
        );
  }

  /// Pending requests I have sent
  Stream<List<FriendRequestItem>> streamOutgoing(String myUid) {
    return _friendRequests
        .where('fromUid', isEqualTo: myUid)
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (qs) =>
              qs.docs.map((d) => FriendRequestItem.fromMap(d.data())).toList(),
        );
  }

  /// My friends list -> resolve to user cards
  Stream<List<UserModel>> streamFriends(String myUid) {
    return _friends(
      myUid,
    ).orderBy('since', descending: true).snapshots().asyncMap((qs) async {
      final ids = qs.docs.map((d) => d.id).toList();
      if (ids.isEmpty) return <UserModel>[];

      final List<UserModel> out = [];
      for (var i = 0; i < ids.length; i += 10) {
        final chunk = ids.sublist(i, i + 10 > ids.length ? ids.length : i + 10);
        final snap = await _users
            .where(FieldPath.documentId, whereIn: chunk)
            .get();
        out.addAll(
          snap.docs.map((d) => UserModel.fromMap({'uid': d.id, ...d.data()})),
        );
      }
      return out;
    });
  }

  // ----------------------- Lookups -----------------------

  Future<String?> uidFromPhone(String phoneE164) async {
    final d = await _userPhones.doc(phoneE164).get();
    if (!d.exists) return null;
    final data = d.data();
    return data?['uid']?.toString();
  }

  Future<UserModel?> getUser(String uid) async {
    final d = await _users.doc(uid).get();
    if (!d.exists) return null;
    return UserModel.fromMap({'uid': d.id, ...d.data()!});
  }

  // ----------------------- Actions -----------------------

  /// Create pending friend request.
  /// - Accepts phone ("+91...") or uid
  /// - Writes friendRequests doc (pending)
  /// - Adds `fromUid` into receiver's `requestList`
  Future<void> sendRequest({
    required String fromUid,
    required String toPhoneOrUid,
  }) async {
    final toUid = toPhoneOrUid.startsWith('+')
        ? await uidFromPhone(toPhoneOrUid)
        : toPhoneOrUid;

    if (toUid == null) {
      throw Exception('User not found for $toPhoneOrUid');
    }
    if (toUid == fromUid) {
      throw Exception('Cannot request yourself');
    }

    final now = DateTime.now().millisecondsSinceEpoch;
    final reqRef = _friendRequests.doc();

    await fs.runTransaction((tx) async {
      // already friends?
      final a = await tx.get(_friends(fromUid).doc(toUid));
      final b = await tx.get(_friends(toUid).doc(fromUid));
      if (a.exists || b.exists) {
        throw Exception('Already friends');
      }

      // duplicate pending?
      final dup = await _friendRequests
          .where('fromUid', isEqualTo: fromUid)
          .where('toUid', isEqualTo: toUid)
          .where('status', isEqualTo: 'pending')
          .limit(1)
          .get();
      if (dup.docs.isNotEmpty) return;

      // write request
      tx.set(reqRef, {
        'fromUid': fromUid,
        'toUid': toUid,
        'createdAt': now,
        'status': 'pending',
      });

      // add to receiver's requestList
      tx.update(_users.doc(toUid), {
        'requestList': FieldValue.arrayUnion([fromUid]),
      });
    });
  }

  /// Sender withdraws their pending request
  /// - Marks request as declined (or delete)
  /// - Removes `fromUid` from receiver's requestList
  Future<void> withdrawRequest({
    required String fromUid,
    required String toUid,
  }) async {
    final qs = await _friendRequests
        .where('fromUid', isEqualTo: fromUid)
        .where('toUid', isEqualTo: toUid)
        .where('status', isEqualTo: 'pending')
        .limit(1)
        .get();
    if (qs.docs.isEmpty) return;
    final reqRef = qs.docs.first.reference;

    await fs.runTransaction((tx) async {
      tx.update(reqRef, {'status': 'declined'});
      tx.update(_users.doc(toUid), {
        'requestList': FieldValue.arrayRemove([fromUid]),
      });
    });
  }

  /// Receiver declines a pending request
  /// - Marks request declined
  /// - Removes `fromUid` from my requestList
  Future<void> declineRequest({
    required String myUid,
    required String fromUid,
  }) async {
    final qs = await _friendRequests
        .where('fromUid', isEqualTo: fromUid)
        .where('toUid', isEqualTo: myUid)
        .where('status', isEqualTo: 'pending')
        .limit(1)
        .get();
    if (qs.docs.isEmpty) return;
    final reqRef = qs.docs.first.reference;

    await fs.runTransaction((tx) async {
      tx.update(reqRef, {'status': 'declined'});
      tx.update(_users.doc(myUid), {
        'requestList': FieldValue.arrayRemove([fromUid]),
      });
    });
  }

  /// Receiver accepts a pending request
  /// - Adds friend edges both sides
  /// - Updates both users' `friendList`
  /// - Removes `fromUid` from my `requestList`
  /// - Marks request as accepted
  Future<void> acceptRequest({
    required String myUid,
    required String fromUid,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;

    final qs = await _friendRequests
        .where('fromUid', isEqualTo: fromUid)
        .where('toUid', isEqualTo: myUid)
        .where('status', isEqualTo: 'pending')
        .limit(1)
        .get();
    if (qs.docs.isEmpty) {
      throw Exception('No pending request');
    }
    final reqRef = qs.docs.first.reference;

    final meEdge = _friends(myUid).doc(fromUid);
    final otherEdge = _friends(fromUid).doc(myUid);

    await fs.runTransaction((tx) async {
      tx.set(meEdge, {'since': now});
      tx.set(otherEdge, {'since': now});

      // update both users' friendList
      tx.update(_users.doc(myUid), {
        'friendList': FieldValue.arrayUnion([fromUid]),
        'requestList': FieldValue.arrayRemove([fromUid]),
      });
      tx.update(_users.doc(fromUid), {
        'friendList': FieldValue.arrayUnion([myUid]),
      });

      tx.update(reqRef, {'status': 'accepted'});
    });
  }

  /// Optional: unfriend (removes edges + friendList both sides)
  Future<void> removeFriend({
    required String uidA,
    required String uidB,
  }) async {
    await fs.runTransaction((tx) async {
      tx.delete(_friends(uidA).doc(uidB));
      tx.delete(_friends(uidB).doc(uidA));
      tx.update(_users.doc(uidA), {
        'friendList': FieldValue.arrayRemove([uidB]),
      });
      tx.update(_users.doc(uidB), {
        'friendList': FieldValue.arrayRemove([uidA]),
      });
    });
  }
}
