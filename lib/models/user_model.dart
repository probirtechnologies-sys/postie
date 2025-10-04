// lib/models/user_model.dart

class UserModel {
  // ---- Core profile (chat/auth) ----
  final String uid;
  final String name;
  final String phoneNumber;
  final String profilePic; // base/profile avatar
  final bool isOnline; // mirrored from RTDB for convenient queries
  final String bio;

  // Relationships
  final List<String> groupId;
  final List<String> requestList;
  final List<String> friendList;

  // Core extras
  final int? lastSeen; // epoch ms (mirror from presence)
  final List<String> fcmTokens; // push tokens

  // ---- Optional Twitter-like subtree ----
  final SocialData? social; // null until user opts into "social"

  const UserModel({
    required this.uid,
    required this.name,
    required this.phoneNumber,
    required this.profilePic,
    required this.isOnline,
    required this.bio,
    required this.groupId,
    required this.requestList,
    required this.friendList,
    this.lastSeen,
    this.fcmTokens = const [],
    this.social,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    final socialMap = map['social'];
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      profilePic: map['profilePic'] ?? '',
      isOnline: map['isOnline'] ?? false,
      bio: map['bio'] ?? 'I am using Postie',
      groupId: List<String>.from(map['groupId'] ?? const []),
      requestList: List<String>.from(map['requestList'] ?? const []),
      friendList: List<String>.from(map['friendList'] ?? const []),
      lastSeen: _asIntOrNull(map['lastSeen']),
      fcmTokens: List<String>.from(map['fcmTokens'] ?? const []),
      social: (socialMap is Map<String, dynamic>)
          ? SocialData.fromMap(socialMap)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'phoneNumber': phoneNumber,
      'profilePic': profilePic,
      'isOnline': isOnline,
      'bio': bio,
      'groupId': groupId,
      'requestList': requestList,
      'friendList': friendList,
      if (lastSeen != null) 'lastSeen': lastSeen,
      if (fcmTokens.isNotEmpty) 'fcmTokens': fcmTokens,
      if (social != null) 'social': social!.toMap(),
    };
  }

  UserModel copyWith({
    String? uid,
    String? name,
    String? phoneNumber,
    String? profilePic,
    bool? isOnline,
    String? bio,
    List<String>? groupId,
    List<String>? requestList,
    List<String>? friendList,
    int? lastSeen,
    List<String>? fcmTokens,
    SocialData? social, // pass null explicitly to clear
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profilePic: profilePic ?? this.profilePic,
      isOnline: isOnline ?? this.isOnline,
      bio: bio ?? this.bio,
      groupId: groupId ?? this.groupId,
      requestList: requestList ?? this.requestList,
      friendList: friendList ?? this.friendList,
      lastSeen: lastSeen ?? this.lastSeen,
      fcmTokens: fcmTokens ?? this.fcmTokens,
      social: social ?? this.social,
    );
  }

  // Convenience: enable the social subtree
  UserModel enableSocial({
    required String handle, // "@alice" or "alice"
    String? displayName,
    String? email,
    String? profileImageUrl,
    String? socialBio,
  }) {
    final sd = SocialData(
      enabled: true,
      handle: _normalizeHandle(handle),
      displayName: displayName ?? name,
      email: email,
      profileImageUrl: profileImageUrl,
      bio: socialBio ?? bio,
      stories: const [],
      joinedAt: DateTime.now().millisecondsSinceEpoch,
      verified: false,
    );
    return copyWith(social: sd);
  }

  UserModel disableSocial() => copyWith(social: null);
}

class SocialData {
  final bool enabled; // opted into social
  final String handle; // unique handle (lowercase, no @ stored)
  final String displayName; // social display name
  final String? profileImageUrl;
  final String? bio;
  final String? email;
  final List<String> stories; // story IDs
  final int? joinedAt; // epoch ms
  final bool verified;

  const SocialData({
    required this.enabled,
    required this.handle,
    required this.displayName,
    this.profileImageUrl,
    this.bio,
    this.email,
    this.stories = const [],
    this.joinedAt,
    this.verified = false,
  });

  factory SocialData.fromMap(Map<String, dynamic> map) => SocialData(
    enabled: map['enabled'] ?? false,
    handle: (map['handle'] ?? '').toString(),
    displayName: (map['displayName'] ?? '').toString(),
    profileImageUrl: _asStringOrNull(map['profileImageUrl']),
    bio: _asStringOrNull(map['bio']),
    email: _asStringOrNull(map['email']),
    stories: List<String>.from(map['stories'] ?? const []),
    joinedAt: _asIntOrNull(map['joinedAt']),
    verified: map['verified'] ?? false,
  );

  Map<String, dynamic> toMap() => {
    'enabled': enabled,
    'handle': handle,
    'displayName': displayName,
    if (profileImageUrl != null) 'profileImageUrl': profileImageUrl,
    if (bio != null) 'bio': bio,
    if (email != null) 'email': email,
    'stories': stories,
    if (joinedAt != null) 'joinedAt': joinedAt,
    'verified': verified,
  };

  SocialData copyWith({
    bool? enabled,
    String? handle,
    String? displayName,
    String? profileImageUrl,
    String? bio,
    String? email,
    List<String>? stories,
    int? joinedAt,
    bool? verified,
  }) {
    return SocialData(
      enabled: enabled ?? this.enabled,
      handle: handle ?? this.handle,
      displayName: displayName ?? this.displayName,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      bio: bio ?? this.bio,
      email: email ?? this.email,
      stories: stories ?? this.stories,
      joinedAt: joinedAt ?? this.joinedAt,
      verified: verified ?? this.verified,
    );
  }
}

// helpers
int? _asIntOrNull(Object? v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is String) return int.tryParse(v);
  return null;
}

String? _asStringOrNull(Object? v) => v == null ? null : v.toString();

String _normalizeHandle(String h) {
  var s = h.trim();
  if (s.startsWith('@')) s = s.substring(1);
  return s.toLowerCase();
}
