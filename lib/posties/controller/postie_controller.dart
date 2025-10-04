import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:postie/posties/repository/postie_repository_fs.dart';

// Override in main.dart with the signed-in user's uid
final myUidProvider = Provider<String>(
  (_) => throw UnimplementedError('override me'),
);

// Repo
final feedRepositoryProvider = Provider<FeedRepositoryFS>((ref) {
  return FeedRepositoryFS();
});

// Following IDs for current user
final followingIdsProvider = StreamProvider.autoDispose<List<String>>((ref) {
  final repo = ref.watch(feedRepositoryProvider);
  final uid = ref.watch(myUidProvider);
  return repo.streamFollowingIds(uid);
});

// Trends
final trendsProvider = StreamProvider.autoDispose((ref) {
  final repo = ref.watch(feedRepositoryProvider);
  return repo.streamTrends(limit: 10);
});

// Home feed (merge-chunked by following)
final homeFeedProvider = StreamProvider.autoDispose<List<Post>>((ref) {
  final repo = ref.watch(feedRepositoryProvider);
  final uid = ref.watch(myUidProvider);
  final following = ref.watch(followingIdsProvider);

  return following.when(
    data: (ids) => repo.streamHomeFeedByFollowing(
      myUid: uid,
      followingIds: ids,
      perChunkLimit: 20,
    ),
    loading: () => const Stream<List<Post>>.empty(),
    error: (_, __) => const Stream<List<Post>>.empty(),
  );
});

// Profile feed
final userPostsProvider = StreamProvider.autoDispose.family<List<Post>, String>(
  (ref, userId) {
    final repo = ref.watch(feedRepositoryProvider);
    return repo.streamUserPosts(userId, limit: 30);
  },
);

// Actions facade for the UI
class FeedActionsController {
  FeedActionsController(this._repo, this._myUid);
  final FeedRepositoryFS _repo;
  final String _myUid;

  Future<void> create(
    String content, {
    required String authorName,
    required String username,
  }) {
    return _repo.createPost(
      authorId: _myUid,
      authorName: authorName,
      username: username,
      content: content,
    );
  }

  Future<void> like(String postId) =>
      _repo.likePost(postId: postId, uid: _myUid);
  Future<void> unlike(String postId) =>
      _repo.unlikePost(postId: postId, uid: _myUid);
  Future<void> retweet(String postId) =>
      _repo.retweetPost(postId: postId, uid: _myUid);
  Future<void> comment(String postId, String text) =>
      _repo.commentOnPost(postId: postId, uid: _myUid, text: text);

  Future<void> follow(String otherUid) =>
      _repo.follow(myUid: _myUid, otherUid: otherUid);

  Future<void> unfollow(String otherUid) =>
      _repo.unfollow(myUid: _myUid, otherUid: otherUid);
}

final feedActionsProvider = Provider<FeedActionsController>((ref) {
  final repo = ref.watch(feedRepositoryProvider);
  final uid = ref.watch(myUidProvider);
  return FeedActionsController(repo, uid);
});
