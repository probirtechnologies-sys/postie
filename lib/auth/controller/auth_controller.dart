// lib/auth/controller/auth_controller.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:postie/auth/repository/auth_repository.dart';
import 'package:postie/models/user_model.dart';

/// DI for the controller
final authControllerProvider = Provider<AuthController>((ref) {
  final repo = ref.watch(AuthRepositoryProvider);
  return AuthController(authRepository: repo, ref: ref);
});

/// Reactive current-user stream (null when signed out)
/// Uses Firestore user doc, which mirrors presence fields (isOnline/lastSeen).
final userDataAuthProvider = StreamProvider<UserModel?>((ref) {
  final repo = ref.watch(AuthRepositoryProvider);
  final uid = repo.auth.currentUser?.uid;
  if (uid == null) return Stream<UserModel?>.value(null);
  return repo.userData(uid).map((u) => u); // UserModel
});

class AuthController {
  final AuthRepository authRepository;
  final Ref ref;
  AuthController({required this.authRepository, required this.ref});

  // ---------- Reads ----------

  /// One-shot fetch of the current user's data (nullable).
  Future<UserModel?> getUserData() => authRepository.getCurrentUserData();

  /// Stream user by id (for viewing other profiles).
  Stream<UserModel> userDataById(String userId) =>
      authRepository.userData(userId);

  // ---------- Auth flows ----------

  Future<void> signInWithPhone(BuildContext context, String phoneNumber) async {
    await authRepository.signInWithPhone(context, phoneNumber);
  }

  Future<void> verifyOTP(
    BuildContext context,
    String verificationId,
    String userOTP,
    String phoneNumber,
  ) async {
    await authRepository.verifyOTP(
      context: context,
      verificationId: verificationId,
      userOTP: userOTP,
      phoneNumber: phoneNumber,
    );
  }

  // ---------- Profile creation / update ----------

  /// Called after OTP flow from your User Information screen.
  Future<void> saveUserDataToFirebase(
    BuildContext context,
    String name,
    String bio,
    File? profilePic,
  ) async {
    await authRepository.saveUserDataToFirestore(
      name: name,
      bio: bio,
      profilePic: profilePic,
      ref: ref,
      context: context,
    );
  }

  // ---------- Presence (RTDB as source of truth) ----------

  /// Flip presence (updates RTDB instantly & mirrors Firestore isOnline/lastSeen).
  Future<void> setUserState(bool isOnline) async {
    await authRepository.setUserState(isOnline);
  }
}
