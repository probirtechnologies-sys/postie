import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:postie/auth/controller/auth_controller.dart';
import 'package:postie/screens/home_screen.dart';
import 'package:postie/widgets/posties.dart';
import 'package:postie/widgets/status_list.dart';
import 'package:postie/widgets/utility_list.dart';
import 'package:postie/select_contacts/screens/select_contacts_screen.dart';
// <-- Import FeedBody here

class MobileScreenLayout extends ConsumerStatefulWidget {
  const MobileScreenLayout({super.key});

  @override
  ConsumerState<MobileScreenLayout> createState() => _MobileScreenLayoutState();
}

class _MobileScreenLayoutState extends ConsumerState<MobileScreenLayout>
    with WidgetsBindingObserver {
  int _railIndex = 0;

  static const kBg = Color(0xFFF4F5F8);
  static const kRail = Color(0xFFE9EBF1);
  static const kCard = Color(0xFFFFFFFF);
  static const kMuted = Color(0xFF9AA2B1);
  static const kText = Color(0xFF2E3140);
  static const kAccent = Color(0xFFFFC107);
  static const kAccentDeep = Color(0xFFFFB300);
  static const kDivider = Color(0xFFE8EAEE);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        ref.read(authControllerProvider).setUserState(true);
        break;
      default:
        ref.read(authControllerProvider).setUserState(false);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      floatingActionButton: _railIndex == 1
          ? FloatingActionButton(
              backgroundColor: kAccent,
              onPressed: () {},
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.edit, color: Colors.white),
            )
          : null,
      body: SafeArea(
        child: Row(
          children: [
            _LeftRail(
              selected: _railIndex,
              onSelect: (i) => setState(() => _railIndex = i),
            ),
            Expanded(child: _buildPanel()),
          ],
        ),
      ),
    );
  }

  Widget _buildPanel() {
    switch (_railIndex) {
      case 0:
        return const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Header(title: 'Home'),
            Expanded(child: HomeRightPanel()),
          ],
        );

      case 1:
        // Show FeedBody here
        return const FeedBody();

      case 2:
        return const StatusList();

      case 3:
      default:
        return const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Header(title: 'Profile'),
            Expanded(child: FriendRequestsPage()),
          ],
        );
    }
  }
}

// ---------- Left Rail ----------
class _LeftRail extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onSelect;
  const _LeftRail({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 76,
      color: _MobileScreenLayoutState.kRail,
      child: Column(
        children: [
          const SizedBox(height: 8),
          _RailItem(
            icon: Icons.chat_bubble_rounded,
            label: 'Chat',
            selected: selected == 0,
            onTap: () => onSelect(0),
          ),
          _RailItem(
            icon: Icons.rss_feed_rounded,
            label: 'Postie',
            selected: selected == 1,
            onTap: () => onSelect(1),
          ),
          _RailItem(
            icon: Icons.grid_view_rounded,
            label: 'Utilities',
            selected: selected == 2,
            onTap: () => onSelect(2),
          ),
          _RailItem(
            icon: Icons.person_rounded,
            label: 'Profile',
            selected: selected == 3,
            onTap: () => onSelect(3),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}

class _RailItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _RailItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final kAccent = _MobileScreenLayoutState.kAccent;
    final kMuted = _MobileScreenLayoutState.kMuted;
    final kAccentDeep = _MobileScreenLayoutState.kAccentDeep;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: selected ? kAccent : Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: selected
                    ? const [
                        BoxShadow(
                          blurRadius: 8,
                          offset: Offset(0, 3),
                          color: Color(0x22000000),
                        ),
                      ]
                    : null,
              ),
              child: Icon(icon, color: selected ? Colors.white : kMuted),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: selected ? kAccentDeep : kMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------- Header ----------
class _Header extends StatelessWidget {
  final String title;
  const _Header({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: _MobileScreenLayoutState.kText,
            ),
          ),
          const Spacer(),
          const Icon(Icons.settings_rounded, color: Colors.black),
        ],
      ),
    );
  }
}
