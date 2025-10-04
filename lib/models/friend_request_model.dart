class FriendRequestItem {
  final String fromUid;
  final String toUid;
  final int createdAt;
  final String status; // pending | accepted | declined

  const FriendRequestItem({
    required this.fromUid,
    required this.toUid,
    required this.createdAt,
    required this.status,
  });

  factory FriendRequestItem.fromMap(Map<String, dynamic> map) {
    return FriendRequestItem(
      fromUid: map['fromUid'] ?? '',
      toUid: map['toUid'] ?? '',
      createdAt: map['createdAt'] ?? 0,
      status: map['status'] ?? 'pending',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fromUid': fromUid,
      'toUid': toUid,
      'createdAt': createdAt,
      'status': status,
    };
  }
}
