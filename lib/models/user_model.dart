class UserModel {
  final String uid;
  final String name;
  final String phoneNumber;
  final String profilePic;
  final bool isOnline;
  final String bio;
  final List<String> groupId;
  final List<String> requestList;
  final List<String> friendList;

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
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      profilePic: map['profilePic'] ?? '',
      isOnline: map['isOnline'] ?? false,
      bio: map['bio'] ?? 'I am using Postie',
      groupId: List<String>.from(map['groupId'] ?? []),
      requestList: List<String>.from(map['requestList'] ?? []),
      friendList: List<String>.from(map['friendList'] ?? []),
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
    };
  }
}
