import 'package:flutter/material.dart';

class FriendRequestsPage extends StatefulWidget {
  const FriendRequestsPage({super.key});

  @override
  State<FriendRequestsPage> createState() => _FriendRequestsPageState();
}

class _FriendRequestsPageState extends State<FriendRequestsPage> {
  // ---- Palette ----
  static const kBg = Color(0xFF15161A);
  static const kCard = Color(0xFF25262C);
  static const kStroke = Color(0xFF3A3B42);
  static const kText = Color(0xFFF6F7FB);
  static const kSubtle = Color(0xFFC7CBD6);
  static const kMuted = Color(0xFF9AA2B1);
  static const kYellow = Color(0xFFFFC107);
  static const kGreyChip = Color(0xFF4C4E57);

  // Avatar colors (stable by name)
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
  int _djb2(String s) {
    int h = 5381;
    for (var i = 0; i < s.length; i++) {
      h = ((h << 5) + h) + s.codeUnitAt(i);
    }
    return h & 0x7fffffff;
  }

  Color _colorFor(String name) =>
      _avatarPalette[_djb2(name) % _avatarPalette.length];

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '';
    final a = parts.first.isNotEmpty ? parts.first[0] : '';
    final b = parts.length > 1 && parts[1].isNotEmpty ? parts[1][0] : '';
    return (a + b).toUpperCase();
  }

  // --- Mock data ---
  final List<List<String>> _incoming = const [
    ['Ethan Carter', '+919433889974'],
    ['Sophia Bennett', '+919433889975'],
    ['Liam Harper', '+919433889947'],
    ['Olivia Reed', '+919433889957'],
    ['Noah Foster', '+919433889978'],
  ];

  final List<List<String>> _outgoing = const [
    ['James Miller', '+919433889987'],
    ['Ava Wilson', '+919433889977'],
    ['Benjamin Davis', '+919433889988'],
  ];

  final List<List<String>> _friends = const [
    ['Olivia Chen', '+919433889955'],
    ['Liam O\'Brien', '+919433889965'],
    ['Sophia Nguyen', '+919433889956'],
    ['Noah Patel', '+919433889964'],
  ];

  // Show yellow "Request" button for these handles in outgoing
  final Set<String> _requestableHandles = const {'+919433889977'};

  final _searchCtrl = TextEditingController();
  String _q = '';

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(() {
      setState(() => _q = _searchCtrl.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<List<String>> _filter(List<List<String>> items) {
    if (_q.isEmpty) return items;
    return items
        .where(
          (e) =>
              e[0].toLowerCase().contains(_q) ||
              e[1].toLowerCase().contains(_q),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final incoming = _filter(_incoming);
    final outgoing = _filter(_outgoing);
    final friends = _filter(_friends);

    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: kBg,
        elevation: 0,
        automaticallyImplyLeading: false,
        toolbarHeight: 72,
        title: Row(
          children: [
            InkResponse(
              onTap: () => Navigator.pop(context),
              radius: 24,
              child: Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: Color(0xFF3A3A2A),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back, color: kYellow, size: 20),
              ),
            ),
            const SizedBox(width: 14),
            const Text(
              'Friend Requests',
              style: TextStyle(
                color: kText,
                fontSize: 22,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(64),
          child: Column(
            children: [
              const SizedBox(height: 8),
              _SearchBar(controller: _searchCtrl, hint: 'Search requests'),
              const SizedBox(height: 10),
              const Divider(height: 1, color: kStroke),
            ],
          ),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          // ---- Incoming ----
          _SectionHeader(title: 'Incoming'),
          if (incoming.isEmpty)
            const _EmptySliver(message: 'No incoming requests')
          else
            _SeparatedSliverList(
              itemCount: incoming.length,
              itemBuilder: (context, i) {
                final name = incoming[i][0];
                final handle = incoming[i][1];
                return _IncomingCard(
                  name: name,
                  handle: handle,
                  color: _colorFor(name),
                  initials: _initials(name),
                  onAccept: () {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('Accepted $name')));
                  },
                  onDecline: () {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('Declined $name')));
                  },
                );
              },
            ),

          // ---- Outgoing ----
          _SectionHeader(title: 'Outgoing'),
          if (outgoing.isEmpty)
            const _EmptySliver(message: 'No outgoing requests')
          else
            _SeparatedSliverList(
              itemCount: outgoing.length,
              itemBuilder: (context, i) {
                final name = outgoing[i][0];
                final handle = outgoing[i][1];
                final isRequest = _requestableHandles.contains(handle);
                return _OutgoingCard(
                  name: name,
                  handle: handle,
                  color: _colorFor(name),
                  initials: _initials(name),
                  isRequest: isRequest,
                  onRequest: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Request sent to $name')),
                    );
                  },
                  onWithdraw: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Withdrawn for $name')),
                    );
                  },
                );
              },
            ),

          // ---- Friends ----
          _SectionHeader(title: 'Friends'),
          if (friends.isEmpty)
            const _EmptySliver(message: 'No friends yet')
          else
            _SeparatedSliverList(
              itemCount: friends.length,
              itemBuilder: (context, i) {
                final name = friends[i][0];
                final handle = friends[i][1];
                return _FriendCard(
                  name: name,
                  handle: handle,
                  color: _colorFor(name),
                  initials: _initials(name),
                  onProfile: () {
                    // TODO: open profile
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Open profile: $name')),
                    );
                  },
                  onMessage: () {
                    // TODO: open chat
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Message sent to $name')),
                    );
                  },
                );
              },
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}

/// A SliverList with built-in 14px vertical separators between items.
class _SeparatedSliverList extends StatelessWidget {
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  const _SeparatedSliverList({
    required this.itemCount,
    required this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final total = itemCount * 2 - 1;
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        if (index.isOdd) return const SizedBox(height: 14);
        final i = index ~/ 2;
        return itemBuilder(context, i);
      }, childCount: total > 0 ? total : 0),
    );
  }
}

// ---------- Section Header ----------
class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
        child: Text(
          title,
          style: const TextStyle(
            color: _FriendRequestsPageState.kSubtle,
            fontSize: 16,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }
}

class _EmptySliver extends StatelessWidget {
  final String message;
  const _EmptySliver({required this.message});
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Text(
          message,
          style: const TextStyle(
            color: _FriendRequestsPageState.kMuted,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

// ---------- Incoming Card ----------
class _IncomingCard extends StatelessWidget {
  final String name;
  final String handle;
  final String initials;
  final Color color;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const _IncomingCard({
    required this.name,
    required this.handle,
    required this.initials,
    required this.color,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: _FriendRequestsPageState.kCard,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: color,
                child: Text(
                  initials,
                  style: const TextStyle(
                    color: _FriendRequestsPageState.kText,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        color: _FriendRequestsPageState.kText,
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      handle,
                      style: const TextStyle(
                        color: _FriendRequestsPageState.kMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              _RoundIconButton(
                bg: _FriendRequestsPageState.kYellow,
                icon: Icons.check_rounded,
                onTap: onAccept,
              ),
              const SizedBox(width: 10),
              _RoundIconButton(
                bg: _FriendRequestsPageState.kGreyChip,
                icon: Icons.close_rounded,
                onTap: onDecline,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------- Outgoing Card ----------
class _OutgoingCard extends StatelessWidget {
  final String name;
  final String handle;
  final String initials;
  final Color color;
  final bool isRequest;
  final VoidCallback onRequest;
  final VoidCallback onWithdraw;

  const _OutgoingCard({
    required this.name,
    required this.handle,
    required this.initials,
    required this.color,
    required this.isRequest,
    required this.onRequest,
    required this.onWithdraw,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: _FriendRequestsPageState.kCard,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: color,
                child: Text(
                  initials,
                  style: const TextStyle(
                    color: _FriendRequestsPageState.kText,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        color: _FriendRequestsPageState.kText,
                        fontWeight: FontWeight.w800,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      handle,
                      style: const TextStyle(
                        color: _FriendRequestsPageState.kMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              if (isRequest)
                _RequestChip(onTap: onRequest)
              else
                _WithdrawChip(onTap: onWithdraw),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------- Friend Card ----------
class _FriendCard extends StatelessWidget {
  final String name;
  final String handle;
  final String initials;
  final Color color;
  final VoidCallback onProfile;
  final VoidCallback onMessage;

  const _FriendCard({
    required this.name,
    required this.handle,
    required this.initials,
    required this.color,
    required this.onProfile,
    required this.onMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: _FriendRequestsPageState.kCard,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: color,
                child: Text(
                  initials,
                  style: const TextStyle(
                    color: _FriendRequestsPageState.kText,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        color: _FriendRequestsPageState.kText,
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      handle,
                      style: const TextStyle(
                        color: _FriendRequestsPageState.kMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              _RoundIconButton(
                bg: _FriendRequestsPageState.kGreyChip,
                icon: Icons.person,
                onTap: onProfile,
              ),
              const SizedBox(width: 10),
              _RoundIconButton(
                bg: _FriendRequestsPageState.kYellow,
                icon: Icons.chat_bubble_outline_rounded,
                onTap: onMessage,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------- Shared Small Widgets ----------
class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  const _SearchBar({required this.controller, required this.hint});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xFF2D2E35),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: _FriendRequestsPageState.kStroke),
        ),
        child: Row(
          children: [
            const SizedBox(width: 14),
            const Icon(Icons.search, color: _FriendRequestsPageState.kMuted),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: controller,
                style: const TextStyle(
                  color: _FriendRequestsPageState.kText,
                  fontWeight: FontWeight.w600,
                ),
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: const TextStyle(
                    color: _FriendRequestsPageState.kMuted,
                    fontWeight: FontWeight.w600,
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final Color bg;
  final IconData icon;
  final VoidCallback onTap;
  const _RoundIconButton({
    required this.bg,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      radius: 28,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
        child: Icon(
          icon,
          size: 22,
          color: bg == _FriendRequestsPageState.kYellow
              ? Colors.black
              : Colors.white,
        ),
      ),
    );
  }
}

class _WithdrawChip extends StatelessWidget {
  final VoidCallback onTap;
  const _WithdrawChip({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: _FriendRequestsPageState.kGreyChip,
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Text(
          'Withdraw',
          style: TextStyle(
            color: _FriendRequestsPageState.kText,
            fontSize: 16,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }
}

class _RequestChip extends StatelessWidget {
  final VoidCallback onTap;
  const _RequestChip({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: _FriendRequestsPageState.kYellow,
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Text(
          'Request',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }
}
