import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitmetrics/services/auth_service.dart';
import 'package:fitmetrics/services/local_storage.dart';
import 'package:fitmetrics/core/avatar_data.dart';
import 'package:fitmetrics/core/haptic_service.dart';
import 'package:fitmetrics/screens/profile/achievements_screen.dart'
    show allAchievements, Achievement;

// ── Model ──────────────────────────────────────────────────────────────────────

class CommunityMessage {
  final String id;
  final String uid;
  final String displayName;
  final String? avatarId;
  final String text;
  final DateTime timestamp;
  final Map<String, List<String>> reactions; // emoji → [uid, ...]
  final List<_UnlockedBadge> badges;

  CommunityMessage({
    required this.id,
    required this.uid,
    required this.displayName,
    this.avatarId,
    required this.text,
    required this.timestamp,
    required this.reactions,
    required this.badges,
  });

  factory CommunityMessage.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    final rawReactions = (d['reactions'] as Map<String, dynamic>?) ?? {};
    final reactions = rawReactions.map(
          (k, v) => MapEntry(k, List<String>.from(v as List)),
    );
    final rawBadges = (d['badges'] as List?) ?? [];
    final badges = rawBadges
        .map((b) => _UnlockedBadge(
      id: b['id'] as String,
      emoji: b['emoji'] as String,
      title: b['title'] as String,
    ))
        .toList();
    return CommunityMessage(
      id: doc.id,
      uid: d['uid'] as String? ?? '',
      displayName: d['displayName'] as String? ?? 'User',
      avatarId: d['avatarId'] as String?,
      text: d['text'] as String? ?? '',
      timestamp: (d['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      reactions: reactions,
      badges: badges,
    );
  }
}

class _UnlockedBadge {
  final String id;
  final String emoji;
  final String title;
  const _UnlockedBadge({required this.id, required this.emoji, required this.title});
}

// ── Screen ─────────────────────────────────────────────────────────────────────

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final _db = FirebaseFirestore.instance;
  final _msgCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final _focusNode = FocusNode();

  String? _myUid;
  String _myName = 'User';
  String? _myAvatarId;
  List<_UnlockedBadge> _myBadges = [];
  bool _sending = false;
  bool _showEmojiBar = false;

  static const _quickEmojis = ['🔥', '💪', '🧘', '❤️', '👏', '✨', '😄', '🎉'];
  static const _reactEmojis = ['🔥', '💪', '❤️', '👏', '✨', '😄'];

  @override
  void initState() {
    super.initState();
    _loadMe();
  }

  @override
  void dispose() {
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _loadMe() async {
    final user = await AuthService.getCurrentUser();
    final uid = AuthService.currentFirebaseUser?.uid;
    final avatarId = await LocalStorage.getAvatarId();
    final stats = await LocalStorage.getAllTimeStats();

    // Collect unlocked achievement badges
    final sessions = stats['totalSessions'] ?? 0;
    final streak = stats['streakDays'] ?? 0;
    final minutes = stats['totalMinutes'] ?? 0;

    final badges = <_UnlockedBadge>[];
    for (final a in allAchievements) {
      bool unlocked = false;
      switch (a.category) {
        case 'session':
          unlocked = a.id == 'first_login' ? true : sessions >= a.requiredValue;
          break;
        case 'streak':
          unlocked = streak >= a.requiredValue;
          break;
        case 'time':
          unlocked = minutes >= a.requiredValue;
          break;
      }
      if (unlocked) {
        badges.add(_UnlockedBadge(id: a.id, emoji: a.emoji, title: a.title));
      }
    }

    if (!mounted) return;
    setState(() {
      _myUid = uid;
      _myName = user?.name ?? user?.fullName ?? 'User';
      _myAvatarId = avatarId ?? user?.avatarId;
      _myBadges = badges;
    });
  }

  Future<void> _send() async {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty || _myUid == null || _sending) return;

    setState(() => _sending = true);
    _msgCtrl.clear();
    _showEmojiBar = false;

    try {
      await _db.collection('community_messages').add({
        'uid': _myUid,
        'displayName': _myName,
        'avatarId': _myAvatarId,
        'text': text,
        'timestamp': FieldValue.serverTimestamp(),
        'reactions': {},
        'badges': _myBadges
            .take(3)
            .map((b) => {'id': b.id, 'emoji': b.emoji, 'title': b.title})
            .toList(),
      });

      // Scroll to bottom after send
      await Future.delayed(const Duration(milliseconds: 200));
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    } catch (e) {
      developer.log('[Community] send error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to send. Check your connection.')),
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _react(String messageId, String emoji, Map<String, List<String>> reactions) async {
    if (_myUid == null) return;
    HapticService.medium();

    final existing = reactions[emoji] ?? [];
    final alreadyReacted = existing.contains(_myUid);

    try {
      final ref = _db.collection('community_messages').doc(messageId);
      if (alreadyReacted) {
        await ref.update({
          'reactions.$emoji': FieldValue.arrayRemove([_myUid]),
        });
      } else {
        await ref.update({
          'reactions.$emoji': FieldValue.arrayUnion([_myUid]),
        });
      }
    } catch (e) {
      developer.log('[Community] react error: $e');
    }
  }

  void _insertEmoji(String emoji) {
    HapticService.light();
    final cur = _msgCtrl.text;
    final sel = _msgCtrl.selection;
    final newText = cur.replaceRange(
      sel.start < 0 ? cur.length : sel.start,
      sel.end < 0 ? cur.length : sel.end,
      emoji,
    );
    _msgCtrl.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(
          offset: (sel.start < 0 ? cur.length : sel.start) + emoji.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: const Color(0xFF0F1624),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(child: _buildMessageList()),
            if (_showEmojiBar) _buildQuickEmojiBar(),
            _buildInputBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1624),
        border: Border(bottom: BorderSide(color: Colors.white.withAlpha(15))),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.people_alt_rounded, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Community',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800)),
                Text('Chat with your fitness family',
                    style: TextStyle(color: Colors.white38, fontSize: 12)),
              ],
            ),
          ),
          // Online indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withAlpha(25),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF10B981).withAlpha(60)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Color(0xFF10B981),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5),
                const Text('Live',
                    style: TextStyle(
                        color: Color(0xFF10B981),
                        fontSize: 11,
                        fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _db
          .collection('community_messages')
          .orderBy('timestamp', descending: false)
          .limitToLast(100)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF3B82F6)),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.wifi_off_rounded, color: Colors.white24, size: 48),
                const SizedBox(height: 12),
                Text('Could not load messages',
                    style: TextStyle(color: Colors.white.withAlpha(80), fontSize: 14)),
              ],
            ),
          );
        }

        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return _buildEmptyState();
        }

        final messages = docs.map((d) => CommunityMessage.fromDoc(d)).toList();

        // Auto-scroll to bottom when new messages arrive
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollCtrl.hasClients) {
            final max = _scrollCtrl.position.maxScrollExtent;
            final cur = _scrollCtrl.offset;
            // Only auto-scroll if already near bottom (within 200px)
            if (max - cur < 200) {
              _scrollCtrl.animateTo(max,
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOut);
            }
          }
        });

        return GestureDetector(
          onTap: () {
            _focusNode.unfocus();
            setState(() => _showEmojiBar = false);
          },
          child: ListView.builder(
            controller: _scrollCtrl,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            itemCount: messages.length,
            itemBuilder: (_, i) {
              final msg = messages[i];
              final isMe = msg.uid == _myUid;
              final showDate = i == 0 ||
                  !_isSameDay(messages[i - 1].timestamp, msg.timestamp);
              final showAvatar = !isMe &&
                  (i == messages.length - 1 ||
                      messages[i + 1].uid != msg.uid ||
                      _showDate(messages, i));

              return Column(
                children: [
                  if (showDate) _DateDivider(msg.timestamp),
                  _MessageBubble(
                    message: msg,
                    isMe: isMe,
                    showAvatar: showAvatar,
                    myUid: _myUid ?? '',
                    onReact: (emoji) => _react(msg.id, emoji, msg.reactions),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  bool _showDate(List<CommunityMessage> msgs, int i) {
    if (i + 1 >= msgs.length) return false;
    return !_isSameDay(msgs[i].timestamp, msgs[i + 1].timestamp);
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('🌟', style: const TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          const Text('Be the first to say hello!',
              style: TextStyle(
                  color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text('Share your progress with the community',
              style: TextStyle(color: Colors.white.withAlpha(100), fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildQuickEmojiBar() {
    return Container(
      height: 52,
      color: const Color(0xFF1A2540),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        children: _quickEmojis.map((e) {
          return GestureDetector(
            onTap: () => _insertEmoji(e),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(10),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(e, style: const TextStyle(fontSize: 22)),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(
          12, 10, 12, MediaQuery.of(context).viewInsets.bottom > 0 ? 10 : 20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2540),
        border: Border(top: BorderSide(color: Colors.white.withAlpha(15))),
      ),
      child: Row(
        children: [
          // Emoji toggle button
          GestureDetector(
            onTap: () {
              HapticService.light();
              setState(() => _showEmojiBar = !_showEmojiBar);
              if (_showEmojiBar) _focusNode.unfocus();
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _showEmojiBar
                    ? const Color(0xFF3B82F6).withAlpha(40)
                    : Colors.white.withAlpha(10),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _showEmojiBar ? Icons.keyboard : Icons.emoji_emotions_outlined,
                color: _showEmojiBar ? const Color(0xFF3B82F6) : Colors.white54,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Text input
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(10),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withAlpha(15)),
              ),
              child: TextField(
                controller: _msgCtrl,
                focusNode: _focusNode,
                style: const TextStyle(color: Colors.white, fontSize: 15),
                maxLines: 4,
                minLines: 1,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  hintText: 'Share with your community…',
                  hintStyle: TextStyle(color: Colors.white38, fontSize: 15),
                  border: InputBorder.none,
                  contentPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                onTap: () => setState(() => _showEmojiBar = false),
                onSubmitted: (_) => _send(),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Send button
          GestureDetector(
            onTap: _sending ? null : _send,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                      color: const Color(0xFF3B82F6).withAlpha(80),
                      blurRadius: 10,
                      offset: const Offset(0, 4)),
                ],
              ),
              child: _sending
                  ? const Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2),
                ),
              )
                  : const Icon(Icons.send_rounded, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Message bubble ──────────────────────────────────────────────────────────────

class _MessageBubble extends StatelessWidget {
  final CommunityMessage message;
  final bool isMe;
  final bool showAvatar;
  final String myUid;
  final Function(String emoji) onReact;

  const _MessageBubble({
    required this.message,
    required this.isMe,
    required this.showAvatar,
    required this.myUid,
    required this.onReact,
  });

  void _showReactionPicker(BuildContext context) {
    HapticService.light();
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A2540),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            const Text('React',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: _CommunityScreenState._reactEmojis.map((e) {
                final count = (message.reactions[e] ?? []).length;
                final reacted = (message.reactions[e] ?? []).contains(myUid);
                return GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    onReact(e);
                  },
                  child: Column(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: reacted
                              ? const Color(0xFF3B82F6).withAlpha(40)
                              : Colors.white.withAlpha(10),
                          borderRadius: BorderRadius.circular(16),
                          border: reacted
                              ? Border.all(
                              color: const Color(0xFF3B82F6).withAlpha(100))
                              : null,
                        ),
                        child: Text(e, style: const TextStyle(fontSize: 28)),
                      ),
                      if (count > 0) ...[
                        const SizedBox(height: 4),
                        Text('$count',
                            style: TextStyle(
                                color: reacted
                                    ? const Color(0xFF3B82F6)
                                    : Colors.white54,
                                fontSize: 12,
                                fontWeight: FontWeight.w600)),
                      ],
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final time = _formatTime(message.timestamp);
    final allReactions = message.reactions.entries
        .where((e) => e.value.isNotEmpty)
        .toList();

    return GestureDetector(
      onLongPress: () => _showReactionPicker(context),
      child: Padding(
        padding: EdgeInsets.only(
          top: 2,
          bottom: 2,
          left: isMe ? 48 : 0,
          right: isMe ? 0 : 48,
        ),
        child: Row(
          mainAxisAlignment:
          isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Other user avatar
            if (!isMe)
              Padding(
                padding: const EdgeInsets.only(right: 8, bottom: 4),
                child: showAvatar
                    ? AvatarWidget(avatarId: message.avatarId, size: 32)
                    : const SizedBox(width: 32),
              ),

            // Bubble
            Flexible(
              child: Column(
                crossAxisAlignment:
                isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  // Name + badges (only for others, first in a group)
                  if (!isMe && showAvatar) ...[
                    Padding(
                      padding: const EdgeInsets.only(left: 4, bottom: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(message.displayName,
                              style: const TextStyle(
                                  color: Colors.white60,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600)),
                          ...message.badges.take(3).map((b) => Padding(
                            padding: const EdgeInsets.only(left: 4),
                            child: Tooltip(
                              message: b.title,
                              child: Text(b.emoji,
                                  style: const TextStyle(fontSize: 11)),
                            ),
                          )),
                        ],
                      ),
                    ),
                  ],

                  // Bubble content
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isMe
                          ? const Color(0xFF3B82F6)
                          : const Color(0xFF1E2D4A),
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(18),
                        topRight: const Radius.circular(18),
                        bottomLeft: isMe
                            ? const Radius.circular(18)
                            : const Radius.circular(4),
                        bottomRight: isMe
                            ? const Radius.circular(4)
                            : const Radius.circular(18),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(40),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      message.text,
                      style: TextStyle(
                        color: isMe ? Colors.white : Colors.white.withAlpha(220),
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ),

                  // Time
                  Padding(
                    padding: const EdgeInsets.only(top: 3, left: 4, right: 4),
                    child: Text(time,
                        style: const TextStyle(
                            color: Colors.white24, fontSize: 10)),
                  ),

                  // Reaction chips
                  if (allReactions.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Wrap(
                        spacing: 4,
                        children: allReactions.map((e) {
                          final count = e.value.length;
                          final iMine = e.value.contains(myUid);
                          return GestureDetector(
                            onTap: () => onReact(e.key),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: iMine
                                    ? const Color(0xFF3B82F6).withAlpha(50)
                                    : Colors.white.withAlpha(12),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: iMine
                                      ? const Color(0xFF3B82F6).withAlpha(120)
                                      : Colors.white.withAlpha(20),
                                ),
                              ),
                              child: Text('${e.key} $count',
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: iMine
                                          ? const Color(0xFF3B82F6)
                                          : Colors.white60)),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime t) {
    final h = t.hour % 12 == 0 ? 12 : t.hour % 12;
    final m = t.minute.toString().padLeft(2, '0');
    final period = t.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $period';
  }
}

// ── Date divider ────────────────────────────────────────────────────────────────

class _DateDivider extends StatelessWidget {
  final DateTime date;
  const _DateDivider(this.date);

  String _label() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d = DateTime(date.year, date.month, date.day);
    if (d == today) return 'Today';
    if (d == today.subtract(const Duration(days: 1))) return 'Yesterday';
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Expanded(child: Divider(color: Colors.white.withAlpha(15))),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(_label(),
                style: const TextStyle(color: Colors.white30, fontSize: 11)),
          ),
          Expanded(child: Divider(color: Colors.white.withAlpha(15))),
        ],
      ),
    );
  }
}