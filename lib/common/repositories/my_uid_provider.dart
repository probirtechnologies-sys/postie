import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Global provider for current user's UID.
/// Must be overridden in main.dart.
final myUidProvider = Provider<String>(
  (_) => throw UnimplementedError('Override me!'),
);
