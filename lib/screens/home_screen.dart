import 'package:flutter/material.dart';
import 'package:postie/select_contacts/screens/select_contacts_screen.dart';

class HomeRightPanel extends StatelessWidget {
  const HomeRightPanel({super.key});

  // ——— Palette ———
  static const kText = Color(0xFF2E3140);
  static const kMuted = Color(0xFF9AA2B1);
  static const kCard = Color(0xFFFFFFFF);
  static const kAccent = Color(0xFFFFC107);
  static const kAccentDeep = Color(0xFFFFB300);
  static const kDivider = Color(0xFFE8EAEE);

  static const List<Color> _avatarPalette = <Color>[
    Color(0xFFB39DDB),
    Color(0xFF90CAF9),
    Color(0xFFA5D6A7),
    Color(0xFFFFCC80),
    Color(0xFFEF9A9A),
    Color(0xFFFFF59D),
    Color(0xFF80DEEA),
    Color(0xFFCE93D8),
    Color(0xFF81D4FA),
    Color(0xFFC5E1A5),
  ];

  int _djb2Hash(String s) {
    int hash = 5381;
    for (var i = 0; i < s.length; i++) {
      hash = ((hash << 5) + hash) + s.codeUnitAt(i);
    }
    return hash & 0x7fffffff;
  }

  Color _colorForName(String name) {
    final idx = _djb2Hash(name) % _avatarPalette.length;
    return _avatarPalette[idx];
  }

  String _initialsFor(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '';
    final a = parts[0][0];
    final b = parts.length > 1 ? parts[1][0] : '';
    return (a + b).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Main content
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stories
            SizedBox(
              height: 92,
              child: _StoriesRow(
                names: const [
                  'Your Story',
                  'Sophia Carter',
                  'Ethan Bennett',
                  'Olivia Hayes',
                  'Noah Price',
                  'Ava Patel',
                ],
                colorFor: _colorForName,
                initialsFor: _initialsFor,
              ),
            ),

            // Quick Utilities (responsive)
            const _QuickUtilitiesCard(),

            // Contacts
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: _ContactsListChromed(
                  colorFor: _colorForName,
                  initialsFor: _initialsFor,
                ),
              ),
            ),
          ],
        ),

        // Floating Action Button (bottom-right)
        Positioned(
          right: 16,
          bottom: 16,
          child: SafeArea(
            child: FloatingActionButton(
              heroTag: 'homeRightPeopleFab',
              backgroundColor: kAccent,
              foregroundColor: Colors.black,
              onPressed: () {
                // TODO: handle tap (e.g., open "Add People" / "New Group")
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const FriendRequestsPage()),
                );
              },
              child: const Icon(Icons.people_alt_rounded),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              tooltip: 'People',
              elevation: 2,
            ),
          ),
        ),
      ],
    );
  }
}

// ---------- Stories Row ----------
class _StoriesRow extends StatelessWidget {
  final List<String> names;
  final Color Function(String name) colorFor;
  final String Function(String name) initialsFor;

  const _StoriesRow({
    required this.names,
    required this.colorFor,
    required this.initialsFor,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.only(left: 16),
      scrollDirection: Axis.horizontal,
      itemCount: names.length,
      itemBuilder: (context, i) {
        final isAdd = i == 0;
        final name = names[i];

        return Padding(
          padding: const EdgeInsets.only(right: 14),
          child: Column(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(29),
                      border: Border.all(
                        color: HomeRightPanel.kAccent,
                        width: 2,
                      ),
                    ),
                    child: isAdd
                        ? const Center(
                            child: Icon(
                              Icons.add,
                              color: HomeRightPanel.kMuted,
                            ),
                          )
                        : _InitialsAvatar(
                            name: name,
                            radius: 24,
                            bgColor: colorFor(name),
                            text: initialsFor(name),
                          ),
                  ),
                  if (isAdd)
                    Positioned(
                      right: -2,
                      bottom: -2,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: const BoxDecoration(
                          color: HomeRightPanel.kAccent,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.add,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              SizedBox(
                width: 64,
                child: Text(
                  isAdd ? 'Your Story' : name.split(' ').first,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: HomeRightPanel.kText,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _InitialsAvatar extends StatelessWidget {
  final String name;
  final double radius;
  final Color bgColor;
  final String text;

  const _InitialsAvatar({
    required this.name,
    required this.radius,
    required this.bgColor,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: bgColor,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: HomeRightPanel.kText,
        ),
      ),
    );
  }
}

// ---------- Quick Utilities (responsive) ----------
class _QuickUtilitiesCard extends StatelessWidget {
  const _QuickUtilitiesCard();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Container(
        decoration: BoxDecoration(
          color: HomeRightPanel.kCard,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              blurRadius: 8,
              offset: Offset(0, 2),
              color: Color(0x11000000),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final maxW = constraints.maxWidth;
              const minPillSize = 64.0;
              const maxPillSize = 88.0;
              const spacing = 12.0;

              int cols = (maxW / (minPillSize + spacing)).floor().clamp(2, 4);
              final totalSpacing = spacing * (cols - 1);
              final pillSize = ((maxW - totalSpacing) / cols).clamp(
                minPillSize,
                maxPillSize,
              );

              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: [
                  // _UtilityPill(
                  //   icon: Icons.qr_code_scanner_rounded,
                  //   label: 'Scan',
                  //   size: pillSize,
                  // ),
                  _UtilityPill(
                    icon: Icons.account_balance_wallet_rounded,
                    label: 'Pay',
                    size: pillSize,
                  ),
                  _UtilityPill(
                    icon: Icons.receipt_long_rounded,
                    label: 'Bills',
                    size: pillSize,
                  ),
                  _UtilityPill(
                    icon: Icons.sports_esports_rounded,
                    label: 'Games',
                    size: pillSize,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _UtilityPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final double size;

  const _UtilityPill({required this.icon, required this.label, this.size = 72});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF6F7FB),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: size * 0.36, color: HomeRightPanel.kAccentDeep),
            const SizedBox(height: 6),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: HomeRightPanel.kText,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------- Contacts ----------
class _ContactsListChromed extends StatelessWidget {
  final Color Function(String name) colorFor;
  final String Function(String name) initialsFor;

  const _ContactsListChromed({
    required this.colorFor,
    required this.initialsFor,
  });

  @override
  Widget build(BuildContext context) {
    const data = [
      ['Sophia Carter', "Hey, how's it going?", '10:42 AM', true],
      ['Ethan Bennett', 'See you tomorrow!', 'Yesterday', false],
      ['Olivia Hayes', "Let's catch up soon.", 'Tuesday', false],
    ];

    return ListView.separated(
      itemCount: data.length,
      separatorBuilder: (_, __) =>
          const Divider(height: 1, color: HomeRightPanel.kDivider),
      itemBuilder: (context, i) {
        final name = data[i][0] as String;
        final msg = data[i][1] as String;
        final time = data[i][2] as String;
        final highlight = data[i][3] as bool;

        return ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 6,
          ),
          leading: CircleAvatar(
            radius: 24,
            backgroundColor: colorFor(name),
            child: Text(
              initialsFor(name),
              style: const TextStyle(
                color: HomeRightPanel.kText,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    color: HomeRightPanel.kText,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                time,
                style: const TextStyle(
                  color: HomeRightPanel.kMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          subtitle: Row(
            children: [
              Expanded(
                child: Text(
                  msg,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: highlight
                        ? HomeRightPanel.kAccentDeep
                        : HomeRightPanel.kMuted,
                    fontWeight: highlight ? FontWeight.w800 : FontWeight.w600,
                  ),
                ),
              ),
              if (highlight) const SizedBox(width: 6),
              if (highlight)
                Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    color: HomeRightPanel.kAccent,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text(
                      '2',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          onTap: () {},
        );
      },
    );
  }
}
