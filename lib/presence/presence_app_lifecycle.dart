import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'presence_controller.dart';

final presenceServiceProvider = Provider<PresenceService>((ref) {
  final service = PresenceService();
  service.init();
  ref.onDispose(() => service.dispose());
  return service;
});

/// Keeps presence tied to lifecycle
final presenceLifecycleProvider = Provider((ref) {
  final service = ref.watch(presenceServiceProvider);
  return service;
});

class PresenceLifecycleWatcher extends ConsumerStatefulWidget {
  final Widget child;
  const PresenceLifecycleWatcher({super.key, required this.child});

  @override
  ConsumerState<PresenceLifecycleWatcher> createState() =>
      _PresenceLifecycleWatcherState();
}

class _PresenceLifecycleWatcherState
    extends ConsumerState<PresenceLifecycleWatcher>
    with WidgetsBindingObserver {
  PresenceService? _presence;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // ✅ now works because ref.read() is available
    _presence = ref.read(presenceServiceProvider);
    _presence!.setOnline(true);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_presence == null) return;

    if (state == AppLifecycleState.resumed) {
      _presence!.setOnline(true);
    } else if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _presence!.setOnline(false);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _presence?.setOnline(false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
