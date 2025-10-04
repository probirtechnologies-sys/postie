import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();

  // Palette tuned to your screenshot
  static const kBg = Color(0xFF111216);
  static const kOnBg = Color(0xFFF5F7FB);
  static const kSubtle = Color(0xFF99A0AE);
  static const kBubbleIn = Color(0xFF2A2D34);
  static const kBubbleOut = Color(0xFFFFC107);
  static const kYellow = Color(0xFFFFC107);
  static const kDivider = Color(0xFF1C1F25);
  static const kPill = Color(0xFF3A3E47);

  final _messages = <_Msg>[
    _Msg(
      outgoing: true,
      text: "Hey Liam, are you still up for the movie tonight?",
      time: "Today 10:30 AM",
    ),
    _Msg(outgoing: false, text: "Absolutely! What time are we thinking?"),
    _Msg(outgoing: true, text: "How about 7 PM? We can grab dinner before."),
    _Msg(
      outgoing: false,
      text: "Sounds perfect! I’ll meet you at the usual spot.",
    ),
    _Msg(outgoing: false, text: "…", isTyping: true),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: Container(
          decoration: const BoxDecoration(
            color: kBg,
            border: Border(bottom: BorderSide(color: kDivider, width: 1)),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: kOnBg,
                    ),
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                  // Avatar + online
                  Stack(
                    children: [
                      const CircleAvatar(
                        radius: 20,
                        backgroundImage: AssetImage(
                          'assets/avatar.png',
                        ), // replace if needed
                        backgroundColor: Color(0xFF2E3138),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: Colors.greenAccent,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Liam',
                          style: TextStyle(
                            color: kOnBg,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Online',
                          style: TextStyle(
                            color: Colors.greenAccent,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_vert_rounded, color: kOnBg),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              itemCount: _messages.length,
              itemBuilder: (context, i) {
                final m = _messages[i];

                // date chip on first message
                final dateChip = (i == 0 && m.time != null)
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Center(
                          child: Text(
                            m.time!,
                            style: const TextStyle(
                              color: kSubtle,
                              fontWeight: FontWeight.w800,
                              letterSpacing: .2,
                            ),
                          ),
                        ),
                      )
                    : const SizedBox.shrink();

                final bubble = _MessageBubble(
                  text: m.text,
                  outgoing: m.outgoing,
                  isTyping: m.isTyping,
                );

                final reactions = (!m.isTyping && !m.outgoing)
                    ? const _ReactionRow(
                        reactions: [
                          _Reaction('❤️', 1),
                          _Reaction('😂', 1),
                          _Reaction('👍', 2),
                        ],
                      )
                    : (!m.isTyping && m.outgoing && (i == 1))
                    ? const _ReactionRow(
                        reactions: [
                          _Reaction('❤️', 2),
                          _Reaction('😂', 1),
                          _Reaction('👍', 3),
                        ],
                      )
                    : const SizedBox.shrink();

                if (i == 0) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      dateChip,
                      Align(
                        alignment: m.outgoing
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: bubble,
                      ),
                    ],
                  );
                }

                return Padding(
                  padding: const EdgeInsets.only(top: 14),
                  child: Column(
                    crossAxisAlignment: m.outgoing
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      // avatar on incoming (as in mock)
                      if (!m.outgoing)
                        const Padding(
                          padding: EdgeInsets.only(left: 8, bottom: 8),
                          child: CircleAvatar(
                            radius: 14,
                            backgroundImage: AssetImage('assets/avatar.png'),
                            backgroundColor: Color(0xFF2E3138),
                          ),
                        ),
                      Align(
                        alignment: m.outgoing
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: bubble,
                      ),
                      const SizedBox(height: 10),
                      reactions,
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          _InputBar(
            controller: _controller,
            onSend: (text) {
              if (text.trim().isEmpty) return;
              setState(() {
                _messages.insert(0, _Msg(outgoing: true, text: text.trim()));
              });
            },
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final String text;
  final bool outgoing;
  final bool isTyping;

  const _MessageBubble({
    required this.text,
    required this.outgoing,
    this.isTyping = false,
  });

  @override
  Widget build(BuildContext context) {
    const kBubbleIn = _ChatScreenState.kBubbleIn;
    const kBubbleOut = _ChatScreenState.kBubbleOut;
    const kOnBg = _ChatScreenState.kOnBg;

    final bg = outgoing ? kBubbleOut : kBubbleIn;
    final color = outgoing ? Colors.black : kOnBg;

    final radius = BorderRadius.only(
      topLeft: const Radius.circular(22),
      topRight: const Radius.circular(22),
      bottomLeft: outgoing
          ? const Radius.circular(22)
          : const Radius.circular(6),
      bottomRight: outgoing
          ? const Radius.circular(6)
          : const Radius.circular(22),
    );

    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.82,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(color: bg, borderRadius: radius),
      child: isTyping
          ? const _TypingDots()
          : Text(
              text,
              style: TextStyle(
                color: color,
                fontSize: 16,
                height: 1.35,
                fontWeight: FontWeight.w700,
              ),
            ),
    );
  }
}

class _TypingDots extends StatefulWidget {
  const _TypingDots();

  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _a;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
    _a = Tween<double>(begin: 0, end: 1).animate(_c);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const dot = BoxDecoration(color: Color(0xFFFFD54F), shape: BoxShape.circle);
    return AnimatedBuilder(
      animation: _a,
      builder: (_, __) {
        double phase(int i) => ((_a.value + i * .2) % 1);
        double y(int i) => (phase(i) < .5) ? 0 : -2;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Transform.translate(
                offset: Offset(0, y(i)),
                child: const SizedBox(
                  width: 10,
                  height: 10,
                  child: DecoratedBox(decoration: dot),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

class _ReactionRow extends StatelessWidget {
  final List<_Reaction> reactions;
  const _ReactionRow({required this.reactions});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      children: reactions.map((r) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: _ChatScreenState.kPill,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(r.emoji, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 6),
              Text(
                '${r.count}',
                style: const TextStyle(
                  color: _ChatScreenState.kOnBg,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onSend;

  const _InputBar({required this.controller, required this.onSend});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
        child: Row(
          children: [
            Expanded(
              child: Container(
                height: 56,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2D34),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF3A3E47)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.add_rounded,
                      color: _ChatScreenState.kOnBg,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: controller,
                        style: const TextStyle(
                          color: _ChatScreenState.kOnBg,
                          fontSize: 16,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Message…',
                          hintStyle: TextStyle(color: _ChatScreenState.kSubtle),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                        textInputAction: TextInputAction.send,
                        onSubmitted: (v) {
                          onSend(v);
                          controller.clear();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: 56,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  final t = controller.text;
                  if (t.trim().isEmpty) return;
                  onSend(t);
                  controller.clear();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _ChatScreenState.kYellow,
                  foregroundColor: Colors.black,
                  shape: const CircleBorder(),
                  elevation: 0,
                ),
                child: const Icon(Icons.send_rounded),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Msg {
  final bool outgoing;
  final String text;
  final String? time;
  final bool isTyping;
  _Msg({
    required this.outgoing,
    required this.text,
    this.time,
    this.isTyping = false,
  });
}

class _Reaction {
  final String emoji;
  final int count;
  const _Reaction(this.emoji, this.count);
}
