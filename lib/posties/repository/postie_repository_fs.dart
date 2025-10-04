import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String id;
  final String authorId;
  final String authorName;
  final String username;
  final String content;
  final int createdAt;
  final int likeCount;
  final int commentCount;
  final int shareCount;
  final List<String> hashtags;

  const Post({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.username,
    required this.content,
    required this.createdAt,
    required this.likeCount,
    required this.commentCount,
    required this.shareCount,
    required this.hashtags,
  });

  factory Post.fromDoc(DocumentSnapshot<Map<String, dynamic>> d) {
    final m = d.data() ?? const {};
    return Post(
      id: d.id,
      authorId: (m['authorId'] ?? '').toString(),
      authorName: (m['authorName'] ?? '').toString(),
      username: (m['username'] ?? '').toString(),
      content: (m['content'] ?? '').toString(),
      createdAt: (m['createdAt'] ?? 0) is int ? m['createdAt'] as int : 0,
      likeCount: (m['likeCount'] ?? 0) is int ? m['likeCount'] as int : 0,
      commentCount: (m['commentCount'] ?? 0) is int
          ? m['commentCount'] as int
          : 0,
      shareCount: (m['shareCount'] ?? 0) is int ? m['shareCount'] as int : 0,
      hashtags:
          (m['hashtags'] as List?)?.map((e) => e.toString()).toList() ??
          const [],
    );
  }
}

class TrendItem {
  final String hashtag;
  final int count;
  final int updatedAt;
  const TrendItem({
    required this.hashtag,
    required this.count,
    required this.updatedAt,
  });

  factory TrendItem.fromDoc(DocumentSnapshot<Map<String, dynamic>> d) {
    final m = d.data() ?? const {};
    return TrendItem(
      hashtag: (m['hashtag'] ?? d.id).toString(),
      count: (m['count'] ?? 0) is int ? m['count'] as int : 0,
      updatedAt: (m['updatedAt'] ?? 0) is int ? m['updatedAt'] as int : 0,
    );
  }
}

class FeedRepositoryFS {
  FeedRepositoryFS({FirebaseFirestore? firestore})
    : fs = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore fs;

  CollectionReference<Map<String, dynamic>> get _users =>
      fs.collection('users');
  CollectionReference<Map<String, dynamic>> get _posts =>
      fs.collection('posts');
  CollectionReference<Map<String, dynamic>> get _trends =>
      fs.collection('trends');
  CollectionReference<Map<String, dynamic>> _following(String uid) =>
      fs.collection('follows').doc(uid).collection('following');

  // ------------------- READS -------------------

  /// Stream top trends (you can sort client-side by count desc).
  Stream<List<TrendItem>> streamTrends({int limit = 10}) {
    return _trends
        .orderBy('updatedAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((qs) => qs.docs.map(TrendItem.fromDoc).toList());
  }

  /// Stream a user's following list (just the IDs).
  Stream<List<String>> streamFollowingIds(String uid) {
    return _following(
      uid,
    ).snapshots().map((qs) => qs.docs.map((d) => d.id).toList());
  }

  /// Home feed without server fan-out:
  /// Query posts where authorId in (myUid + following) ordered by createdAt.
  /// Firestore `whereIn` supports up to 30 values; we chunk if needed.
  Stream<List<Post>> streamHomeFeedByFollowing({
    required String myUid,
    required List<String> followingIds,
    int perChunkLimit = 20,
  }) {
    final ids = [myUid, ...followingIds.toSet()];
    if (ids.isEmpty) {
      return const Stream.empty();
    }

    final chunks = _chunk(ids, 10); // keep chunks small for index efficiency
    final streams = chunks.map((chunk) {
      return _posts
          .where('authorId', whereIn: chunk)
          .orderBy('createdAt', descending: true)
          .limit(perChunkLimit)
          .snapshots()
          .map((qs) => qs.docs.map(Post.fromDoc).toList());
    }).toList();

    // merge chunks by listening to all and combining
    return Stream.multi((controller) {
      final subs = <Stream<List<Post>>>[];
      final cache = <int, List<Post>>{};
      for (var i = 0; i < streams.length; i++) {
        final idx = i;
        final sub = streams[i].listen((list) {
          cache[idx] = list;
          // flatten, sort by createdAt desc, and emit
          final flat = cache.values.expand((e) => e).toList()
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
          controller.add(flat);
        }, onError: controller.addError);
        subs.add(streams[i]);
      }
      // When stream closes, nothing to do (Stream.multi handles cancellation)
    });
  }

  /// Stream posts for a single user (profile feed).
  Stream<List<Post>> streamUserPosts(String uid, {int limit = 30}) {
    return _posts
        .where('authorId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((qs) => qs.docs.map(Post.fromDoc).toList());
  }

  // ------------------- WRITES / ACTIONS -------------------

  Future<void> createPost({
    required String authorId,
    required String authorName,
    required String username,
    required String content,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final hashtags = _extractHashtags(content);
    final ref = _posts.doc();

    await fs.runTransaction((tx) async {
      tx.set(ref, {
        'authorId': authorId,
        'authorName': authorName,
        'username': username,
        'content': content,
        'createdAt': now,
        'likeCount': 0,
        'commentCount': 0,
        'shareCount': 0,
        'hashtags': hashtags,
      });

      // naive trend bump (optional, can be done in CF)
      for (final tag in hashtags) {
        final tRef = _trends.doc(tag);
        tx.set(tRef, {
          'hashtag': tag,
          'count': FieldValue.increment(1),
          'updatedAt': now,
        }, SetOptions(merge: true));
      }
    });
  }

  Future<void> likePost({required String postId, required String uid}) async {
    final likeRef = _posts.doc(postId).collection('likes').doc(uid);
    final postRef = _posts.doc(postId);

    await fs.runTransaction((tx) async {
      final liked = await tx.get(likeRef);
      if (liked.exists) return; // already liked
      tx.set(likeRef, {'createdAt': DateTime.now().millisecondsSinceEpoch});
      tx.update(postRef, {'likeCount': FieldValue.increment(1)});
    });
  }

  Future<void> unlikePost({required String postId, required String uid}) async {
    final likeRef = _posts.doc(postId).collection('likes').doc(uid);
    final postRef = _posts.doc(postId);

    await fs.runTransaction((tx) async {
      final liked = await tx.get(likeRef);
      if (!liked.exists) return;
      tx.delete(likeRef);
      tx.update(postRef, {'likeCount': FieldValue.increment(-1)});
    });
  }

  Future<void> retweetPost({
    required String postId,
    required String uid,
  }) async {
    final rtRef = _posts.doc(postId).collection('retweets').doc(uid);
    final postRef = _posts.doc(postId);

    await fs.runTransaction((tx) async {
      final rted = await tx.get(rtRef);
      if (rted.exists) return;
      tx.set(rtRef, {'createdAt': DateTime.now().millisecondsSinceEpoch});
      tx.update(postRef, {'shareCount': FieldValue.increment(1)});
    });
  }

  Future<void> commentOnPost({
    required String postId,
    required String uid,
    required String text,
  }) async {
    final comments = _posts.doc(postId).collection('comments').doc();
    final postRef = _posts.doc(postId);

    await fs.runTransaction((tx) async {
      tx.set(comments, {
        'uid': uid,
        'text': text,
        'createdAt': DateTime.now().millisecondsSinceEpoch,
      });
      tx.update(postRef, {'commentCount': FieldValue.increment(1)});
    });
  }

  Future<void> follow({required String myUid, required String otherUid}) async {
    final myF = _following(myUid).doc(otherUid);
    final theirFollowers = fs
        .collection('follows')
        .doc(otherUid)
        .collection('followers')
        .doc(myUid);

    await fs.runTransaction((tx) async {
      tx.set(myF, {'since': DateTime.now().millisecondsSinceEpoch});
      tx.set(theirFollowers, {'since': DateTime.now().millisecondsSinceEpoch});
    });
  }

  Future<void> unfollow({
    required String myUid,
    required String otherUid,
  }) async {
    final myF = _following(myUid).doc(otherUid);
    final theirFollowers = fs
        .collection('follows')
        .doc(otherUid)
        .collection('followers')
        .doc(myUid);

    await fs.runTransaction((tx) async {
      tx.delete(myF);
      tx.delete(theirFollowers);
    });
  }

  // ------------------- utils -------------------

  List<String> _extractHashtags(String content) {
    final r = RegExp(r'(?<!\w)#\w+');
    return r.allMatches(content).map((m) => m.group(0)!).toSet().toList();
  }

  Iterable<List<T>> _chunk<T>(List<T> list, int size) sync* {
    for (var i = 0; i < list.length; i += size) {
      yield list.sublist(i, i + size > list.length ? list.length : i + size);
    }
  }
}
