import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:postie/auth/controller/auth_controller.dart';
import 'package:postie/common/utils/utils.dart';

class UserInfoScreen extends ConsumerStatefulWidget {
  static const String routeName = '/user-information';

  /// Passed from OTP screen
  final String phoneNumber;

  const UserInfoScreen({super.key, required this.phoneNumber});

  @override
  ConsumerState<UserInfoScreen> createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends ConsumerState<UserInfoScreen> {
  final _nameCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  File? _image;
  bool _submitting = false;

  // Palette
  static const kBg = Color(0xFF0E0F12);
  static const kCard = Color(0xFF17191E);
  static const kHint = Color(0xFF8E94A3);
  static const kText = Color(0xFFF5F7FB);
  static const kYellow = Color(0xFFFFC107);
  static const kYellowDeep = Color(0xFFFFB300);
  static const kStroke = Color(0xFF2A2E36);

  @override
  void initState() {
    super.initState();
    _phoneCtrl.text = widget.phoneNumber; // read-only display
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _bioCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final img = await pickImageFromGallery(context);
    if (img != null) setState(() => _image = img);
  }

  Future<void> _save() async {
    if (_submitting) return; // prevent double taps
    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);
    try {
      final name = _nameCtrl.text.trim();
      final bio = _bioCtrl.text.trim();

      await ref
          .read(authControllerProvider)
          .saveUserDataToFirebase(context, name, bio, _image);
      // Navigation to MobileScreenLayout happens inside the repository
      // after successful write (as in your existing code).
    } catch (e) {
      // showSnackBar is used inside repository on errors,
      // but we also guard here for any unexpected error.
      showSnackBar(context: context, content: e.toString());
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  InputDecoration _fieldDecoration({
    required String hint,
    Widget? prefixIcon,
    Widget? suffixIcon,
    int lines = 1,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: kHint, fontWeight: FontWeight.w500),
      filled: true,
      fillColor: kCard,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      contentPadding: EdgeInsets.symmetric(
        horizontal: 16,
        vertical: lines > 1 ? 14 : 12,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: kStroke),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: kYellowDeep, width: 1.4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: Column(
          children: [
            // App bar row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: _submitting
                        ? null
                        : () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: kText,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Your Profile',
                    style: TextStyle(
                      color: kText,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Avatar
                      const SizedBox(height: 4),
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          CircleAvatar(
                            radius: 56,
                            backgroundColor: kCard,
                            backgroundImage: _image != null
                                ? FileImage(_image!)
                                : null,
                            child: _image == null
                                ? const Icon(
                                    Icons.person_rounded,
                                    size: 54,
                                    color: kHint,
                                  )
                                : null,
                          ),
                          GestureDetector(
                            onTap: _submitting ? null : _pickImage,
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: const BoxDecoration(
                                color: kYellow,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt_rounded,
                                size: 18,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'Add a profile photo',
                        style: TextStyle(
                          color: kText,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'This will be visible to other users',
                        style: TextStyle(
                          color: kHint,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 22),

                      // Name
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Name',
                          style: TextStyle(
                            color: kText,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _nameCtrl,
                        enabled: !_submitting,
                        style: const TextStyle(color: kText, fontSize: 15),
                        cursorColor: kYellow,
                        decoration: _fieldDecoration(
                          hint: 'Enter your name',
                          prefixIcon: const Icon(
                            Icons.person_outline_rounded,
                            color: kHint,
                          ),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Please enter your name'
                            : null,
                      ),
                      const SizedBox(height: 16),

                      // Bio
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Bio',
                          style: TextStyle(
                            color: kText,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _bioCtrl,
                        enabled: !_submitting,
                        maxLines: 4,
                        style: const TextStyle(color: kText, fontSize: 15),
                        cursorColor: kYellow,
                        decoration: _fieldDecoration(
                          hint: 'Tell us a little about yourself…',
                          prefixIcon: const Padding(
                            padding: EdgeInsets.only(bottom: 36.0),
                            child: Icon(Icons.notes_rounded, color: kHint),
                          ),
                          lines: 4,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Phone (read-only)
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Phone Number",
                          style: TextStyle(
                            color: kText,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _phoneCtrl,
                        readOnly: true,
                        style: const TextStyle(color: kText, fontSize: 15),
                        cursorColor: kYellow,
                        decoration: _fieldDecoration(
                          hint: widget.phoneNumber,
                          prefixIcon: const Icon(
                            Icons.phone_rounded,
                            color: kHint,
                          ),
                          suffixIcon: const Padding(
                            padding: EdgeInsets.only(right: 8.0),
                            child: Icon(
                              Icons.lock_rounded,
                              color: kHint,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Continue button
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: _submitting ? null : _save,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kYellow,
                            foregroundColor: Colors.black,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          child: _submitting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation(
                                      Colors.black,
                                    ),
                                  ),
                                )
                              : const Text('Continue'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
