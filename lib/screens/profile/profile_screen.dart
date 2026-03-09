import 'package:flutter/material.dart';
import 'package:fitmetrics/models/onboarding_data.dart';
import 'package:fitmetrics/routes.dart';
import 'package:fitmetrics/core/avatar_data.dart';
import 'package:fitmetrics/core/audio_service.dart';
import 'package:fitmetrics/services/local_storage.dart';
import 'package:fitmetrics/services/auth_service.dart';
import 'package:fitmetrics/core/haptic_service.dart';

class ProfileScreen extends StatefulWidget {
  final OnboardingData userData;
  const ProfileScreen({super.key, required this.userData});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late OnboardingData _data;
  String? _avatarId;
  bool _isEditing = false;
  bool _showPersonalDetails = false;
  Map<String, int> _allTimeStats = {};
  int _dailyGoal = 15;
  bool _showGoalPicker = false;

  late TextEditingController _ageController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;

  @override
  void initState() {
    super.initState();
    _data = widget.userData;
    _ageController = TextEditingController(text: _data.age?.toString() ?? '');
    _heightController = TextEditingController(text: _data.heightCm?.toStringAsFixed(0) ?? '');
    _weightController = TextEditingController(text: _data.currentWeightKg?.toStringAsFixed(1) ?? '');
    _loadAvatar();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final stats = await LocalStorage.getAllTimeStats();
    final goal = await LocalStorage.getDailyGoalMinutes();
    setState(() {
      _allTimeStats = stats;
      _dailyGoal = goal;
    });
  }

  Future<void> _loadAvatar() async {
    final id = await LocalStorage.getAvatarId();
    setState(() => _avatarId = id);
  }

  Future<void> _saveData() async {
    final age = int.tryParse(_ageController.text.trim());
    final height = double.tryParse(_heightController.text.trim());
    final weight = double.tryParse(_weightController.text.trim());
    if (age != null) _data.age = age;
    if (height != null) _data.heightCm = height;
    if (weight != null) _data.currentWeightKg = weight;
    await LocalStorage.updateStats(
      age: age,
      heightCm: height,
      weightKg: weight,
    );
    setState(() => _isEditing = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated!')),
      );
    }
  }

  void _changeAvatar() {
    AudioService().playClickSound();
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A2540),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (_) => _AvatarPickerSheet(
        currentAvatarId: _avatarId,
        onSelected: (id) async {
          await LocalStorage.saveAvatarId(id);
          setState(() => _avatarId = id);
          if (mounted) Navigator.pop(context);
        },
      ),
    );
  }

  void _openSettings() {
    AudioService().playClickSound();
    Navigator.pushNamed(context, AppRoutes.settings);
  }

  void _openAchievements() {
    HapticService.light();
    Navigator.pushNamed(context, AppRoutes.achievements);
  }

  void _openMeditationHistory() {
    HapticService.light();
    Navigator.pushNamed(context, AppRoutes.meditationHistory);
  }

  void _openNotifications() {
    HapticService.light();
    Navigator.pushNamed(context, AppRoutes.notificationHistory);
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A2540),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Logout', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to logout?', style: TextStyle(color: Colors.white60)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await AuthService.logout(); // clears all user data, avatar, meditation stats
              if (mounted) Navigator.pushReplacementNamed(context, AppRoutes.welcome);
            },
            child: const Text('Logout', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1624),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 24),

              // Avatar + name
              Center(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _changeAvatar,
                      child: Stack(
                        children: [
                          AvatarWidget(avatarId: _avatarId, size: 90, showBorder: true),
                          Positioned(
                            bottom: 0, right: 0,
                            child: Container(
                              width: 28, height: 28,
                              decoration: const BoxDecoration(
                                color: Color(0xFF3B82F6),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.edit, color: Colors.white, size: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(_data.name ?? 'User',
                        style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    Text(_data.email ?? '',
                        style: const TextStyle(color: Colors.white38, fontSize: 13)),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Stats row
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.white.withOpacity(0.08)),
                ),
                child: Row(
                  children: [
                    _StatBox(label: 'Height', value: _data.heightCm != null ? '${_data.heightCm!.round()} cm' : '—'),
                    _VertDivider(),
                    _StatBox(label: 'Age', value: _data.age?.toString() ?? '—'),
                    _VertDivider(),
                    _StatBox(label: 'Weight', value: _data.currentWeightKg != null ? '${_data.currentWeightKg!.toStringAsFixed(1)} kg' : '—'),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Personal Details — hidden by default, toggle to show
              _SectionCard(
                title: 'Personal Details',
                trailing: GestureDetector(
                  onTap: () => setState(() => _showPersonalDetails = !_showPersonalDetails),
                  child: Text(
                    _showPersonalDetails ? 'Hide' : 'Show',
                    style: const TextStyle(color: Color(0xFF3B82F6), fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                ),
                child: _showPersonalDetails
                    ? Column(
                  children: [
                    _InfoRow(label: 'Preferred Name', value: _data.name ?? '—'),
                    const Divider(color: Colors.white12, height: 1),
                    _InfoRow(label: 'Email', value: _data.email ?? '—'),
                    const Divider(color: Colors.white12, height: 1),
                    _InfoRow(label: 'Gender', value: _data.gender ?? '—'),
                  ],
                )
                    : const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    children: [
                      Icon(Icons.lock_outline, color: Colors.white38, size: 16),
                      SizedBox(width: 8),
                      Text('Tap "Show" to reveal details',
                          style: TextStyle(color: Colors.white38, fontSize: 13)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // All-time stats
              _SectionCard(
                title: 'My Stats',
                child: Column(
                  children: [
                    _InfoRow(label: '🕐 Total Hours', value: '${_allTimeStats["totalHours"] ?? 0}h meditated'),
                    const Divider(color: Colors.white12, height: 1),
                    _InfoRow(label: '🔥 Current Streak', value: '${_allTimeStats["streakDays"] ?? 0} days'),
                    const Divider(color: Colors.white12, height: 1),
                    _InfoRow(label: '🏆 Longest Streak', value: '${_allTimeStats["longestStreak"] ?? 0} days'),
                    const Divider(color: Colors.white12, height: 1),
                    _InfoRow(label: '🧘 Total Sessions', value: '${_allTimeStats["totalSessions"] ?? 0} completed'),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Daily goal
              _SectionCard(
                title: 'Daily Goal',
                trailing: GestureDetector(
                  onTap: () {
                    HapticService.light();
                    setState(() => _showGoalPicker = !_showGoalPicker);
                  },
                  child: Text(
                    _showGoalPicker ? 'Done' : 'Change',
                    style: const TextStyle(color: Color(0xFF3B82F6),
                        fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        children: [
                          const Icon(Icons.flag_outlined,
                              color: Color(0xFF3B82F6), size: 20),
                          const SizedBox(width: 10),
                          Text('$_dailyGoal minutes per day',
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 14,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                    if (_showGoalPicker) ...[
                      const Divider(color: Colors.white12, height: 1),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8, runSpacing: 8,
                        children: [5, 10, 15, 20, 30, 45, 60].map((mins) {
                          final sel = mins == _dailyGoal;
                          return GestureDetector(
                            onTap: () async {
                              HapticService.medium();
                              await LocalStorage.setDailyGoalMinutes(mins);
                              setState(() {
                                _dailyGoal = mins;
                                _showGoalPicker = false;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: sel
                                    ? const Color(0xFF3B82F6)
                                    : Colors.white.withAlpha(15),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: sel
                                      ? const Color(0xFF3B82F6)
                                      : Colors.white.withAlpha(30),
                                ),
                              ),
                              child: Text('${mins}m',
                                  style: TextStyle(
                                    color: sel ? Colors.white : Colors.white54,
                                    fontSize: 13,
                                    fontWeight: sel ? FontWeight.w700 : FontWeight.normal,
                                  )),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Update Stats"

              _SectionCard(
                title: 'Update Stats',
                trailing: _isEditing
                    ? GestureDetector(
                  onTap: _saveData,
                  child: const Text('Save', style: TextStyle(color: Color(0xFF3B82F6), fontWeight: FontWeight.w700, fontSize: 14)),
                )
                    : GestureDetector(
                  onTap: () => setState(() => _isEditing = true),
                  child: const Text('Edit', style: TextStyle(color: Color(0xFF3B82F6), fontWeight: FontWeight.w700, fontSize: 14)),
                ),
                child: Column(
                  children: [
                    _EditableRow(label: 'Age', controller: _ageController, isEditing: _isEditing,
                        value: _data.age?.toString() ?? '—', keyboardType: TextInputType.number, suffix: 'yrs'),
                    const Divider(color: Colors.white12, height: 1),
                    _EditableRow(label: 'Height', controller: _heightController, isEditing: _isEditing,
                        value: _data.heightCm != null ? '${_data.heightCm!.round()} cm' : '—',
                        keyboardType: const TextInputType.numberWithOptions(decimal: true), suffix: 'cm'),
                    const Divider(color: Colors.white12, height: 1),
                    _EditableRow(label: 'Weight', controller: _weightController, isEditing: _isEditing,
                        value: _data.currentWeightKg != null ? '${_data.currentWeightKg!.toStringAsFixed(1)} kg' : '—',
                        keyboardType: const TextInputType.numberWithOptions(decimal: true), suffix: 'kg'),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              _MenuCard(items: [
                _MenuItem(icon: Icons.color_lens_outlined, label: 'Change Avatar', onTap: _changeAvatar),
                _MenuItem(icon: Icons.emoji_events_outlined, label: 'Achievements', onTap: _openAchievements),
                _MenuItem(icon: Icons.history, label: 'Meditation History', onTap: _openMeditationHistory),
                _MenuItem(icon: Icons.settings_outlined, label: 'Settings', onTap: _openSettings),
              ]),
              const SizedBox(height: 12),

              _MenuCard(items: [
                _MenuItem(icon: Icons.logout, label: 'Logout', onTap: _logout, color: Colors.redAccent),
              ]),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label, value;
  const _StatBox({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _VertDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 36, color: Colors.white12);
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? trailing;
  const _SectionCard({required this.title, required this.child, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
                if (trailing != null) trailing!,
              ],
            ),
          ),
          const Divider(color: Colors.white12, height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: child,
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label, value;
  const _InfoRow({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 14)),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _EditableRow extends StatelessWidget {
  final String label, value, suffix;
  final TextEditingController controller;
  final bool isEditing;
  final TextInputType keyboardType;
  const _EditableRow({required this.label, required this.controller,
    required this.isEditing, required this.value,
    required this.keyboardType, required this.suffix});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 14)),
          if (isEditing)
            SizedBox(
              width: 100,
              child: TextField(
                controller: controller,
                keyboardType: keyboardType,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                textAlign: TextAlign.right,
                decoration: InputDecoration(
                  suffixText: suffix,
                  suffixStyle: const TextStyle(color: Colors.white38, fontSize: 12),
                  isDense: true, filled: true,
                  fillColor: Colors.white.withOpacity(0.08),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                ),
              ),
            )
          else
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final List<_MenuItem> items;
  const _MenuCard({required this.items});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        children: items.asMap().entries.map((e) {
          final i = e.key;
          final item = e.value;
          return Column(
            children: [
              ListTile(
                leading: Icon(item.icon, color: item.color ?? Colors.white70, size: 22),
                title: Text(item.label,
                    style: TextStyle(color: item.color ?? Colors.white70, fontSize: 15)),
                trailing: const Icon(Icons.chevron_right, color: Colors.white24, size: 20),
                onTap: item.onTap,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
              ),
              if (i < items.length - 1)
                const Divider(color: Colors.white12, height: 1, indent: 16, endIndent: 16),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;
  const _MenuItem({required this.icon, required this.label, required this.onTap, this.color});
}

// ── Avatar picker bottom sheet ─────────────────────────────────────────────────
class _AvatarPickerSheet extends StatefulWidget {
  final String? currentAvatarId;
  final Function(String) onSelected;
  const _AvatarPickerSheet({required this.currentAvatarId, required this.onSelected});

  @override
  State<_AvatarPickerSheet> createState() => _AvatarPickerSheetState();
}

class _AvatarPickerSheetState extends State<_AvatarPickerSheet> {
  late String? _selected;
  String _category = 'all';

  @override
  void initState() {
    super.initState();
    _selected = widget.currentAvatarId;
  }

  List<AppAvatar> get _filtered {
    if (_category == 'all') return allAvatars;
    return allAvatars.where((a) => a.category == _category).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.65,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: Container(width: 40, height: 4,
              decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 16),
          const Text('Change Avatar',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _Chip(label: 'All', selected: _category == 'all', onTap: () => setState(() => _category = 'all')),
                const SizedBox(width: 8),
                _Chip(label: '♂ Male', selected: _category == 'male', onTap: () => setState(() => _category = 'male')),
                const SizedBox(width: 8),
                _Chip(label: '♀ Female', selected: _category == 'female', onTap: () => setState(() => _category = 'female')),
                const SizedBox(width: 8),
                _Chip(label: '🐾 Animal', selected: _category == 'animal', onTap: () => setState(() => _category = 'animal')),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4, crossAxisSpacing: 12, mainAxisSpacing: 12,
              ),
              itemCount: _filtered.length,
              itemBuilder: (context, i) {
                final avatar = _filtered[i];
                final isSelected = _selected == avatar.id;
                return GestureDetector(
                  onTap: () {
                    setState(() => _selected = avatar.id);
                    widget.onSelected(avatar.id);
                  },
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? avatar.primaryColor : Colors.transparent,
                            width: 3,
                          ),
                        ),
                        child: AvatarWidget(avatarId: avatar.id, size: 56),
                      ),
                      const SizedBox(height: 4),
                      Text(avatar.name,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.white38,
                            fontSize: 10,
                          ),
                          overflow: TextOverflow.ellipsis),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _Chip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF3B82F6) : Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label,
            style: TextStyle(
              color: selected ? Colors.white : Colors.white54,
              fontSize: 12,
              fontWeight: selected ? FontWeight.w700 : FontWeight.normal,
            )),
      ),
    );
  }
}