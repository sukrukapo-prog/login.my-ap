import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:fitmetrics/core/app_settings.dart';
import 'package:fitmetrics/core/audio_service.dart';
import 'package:fitmetrics/models/onboarding_data.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AppSettings _settings = AppSettings();
  final AudioService _audio = AudioService();
  final _nameController = TextEditingController();
  bool _showNameField = false;

  @override
  void initState() {
    super.initState();
    _settings.addListener(_refresh);
    _loadName();
  }

  void _refresh() => setState(() {});

  Future<void> _loadName() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('userData');
    if (jsonString != null) {
      final data = OnboardingData.fromJson(jsonDecode(jsonString));
      _nameController.text = data.name ?? '';
    }
  }

  Future<void> _saveName() async {
    final newName = _nameController.text.trim();
    if (newName.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('userData');
    if (jsonString != null) {
      final data = OnboardingData.fromJson(jsonDecode(jsonString));
      data.name = newName;
      await prefs.setString('userData', jsonEncode(data.toJson()));
    }
    await _settings.setDisplayName(newName);
    setState(() => _showNameField = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name updated!')),
      );
    }
  }

  @override
  void dispose() {
    _settings.removeListener(_refresh);
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1624),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text('Settings',
                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // ── Sound Control ──────────────────────────────
                    _SectionLabel('Sound Control'),
                    _Card(children: [
                      _ToggleRow(
                        icon: Icons.music_note_outlined,
                        label: 'Background Music',
                        value: _settings.musicEnabled,
                        onChanged: (_) async => await _audio.toggleMusic(),
                      ),
                      const _Divider(),
                      _ToggleRow(
                        icon: Icons.touch_app_outlined,
                        label: 'Sound Effects',
                        value: _settings.soundEffectsEnabled,
                        onChanged: (v) async => await _settings.setSoundEffects(v),
                      ),
                      const _Divider(),
                      // Volume slider
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.volume_up_outlined, color: Colors.white54, size: 20),
                                const SizedBox(width: 12),
                                const Text('Music Volume',
                                    style: TextStyle(color: Colors.white70, fontSize: 14)),
                                const Spacer(),
                                Text(
                                  '${(_settings.musicVolume * 100).round()}%',
                                  style: const TextStyle(
                                      color: Color(0xFF3B82F6), fontSize: 13, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                activeTrackColor: const Color(0xFF3B82F6),
                                inactiveTrackColor: Colors.white12,
                                thumbColor: const Color(0xFF3B82F6),
                                overlayShape: SliderComponentShape.noOverlay,
                                trackHeight: 3,
                              ),
                              child: Slider(
                                value: _settings.musicVolume,
                                min: 0, max: 1,
                                onChanged: (v) async => await _audio.setVolume(v),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ]),

                    const SizedBox(height: 16),

                    // ── Soundtrack Selection ───────────────────────
                    _SectionLabel('Background Soundtrack'),
                    _Card(
                      children: List.generate(AppSettings.tracks.length, (i) {
                        final track = AppSettings.tracks[i];
                        final isSelected = _settings.selectedTrack == i;
                        return Column(
                          children: [
                            GestureDetector(
                              onTap: () async => await _audio.changeTrack(i),
                              child: Container(
                                color: Colors.transparent,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 40, height: 40,
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? const Color(0xFF3B82F6)
                                            : Colors.white.withOpacity(0.08),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Icon(
                                        i == 0 ? Icons.flutter_dash
                                          : i == 1 ? Icons.wb_sunny_outlined
                                          : i == 2 ? Icons.waves
                                          : Icons.bolt,
                                        color: isSelected ? Colors.white : Colors.white54,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Text(
                                      track['name']!,
                                      style: TextStyle(
                                        color: isSelected ? Colors.white : Colors.white70,
                                        fontSize: 15,
                                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
                                      ),
                                    ),
                                    const Spacer(),
                                    if (isSelected)
                                      Container(
                                        width: 24, height: 24,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFF3B82F6),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.check, color: Colors.white, size: 14),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            if (i < AppSettings.tracks.length - 1) const _Divider(),
                          ],
                        );
                      }),
                    ),

                    const SizedBox(height: 16),

                    // ── Account ────────────────────────────────────
                    _SectionLabel('Account'),
                    _Card(children: [
                      GestureDetector(
                        onTap: () => setState(() => _showNameField = !_showNameField),
                        child: Container(
                          color: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          child: Row(
                            children: [
                              const Icon(Icons.person_outline, color: Colors.white54, size: 20),
                              const SizedBox(width: 12),
                              const Text('Change Name',
                                  style: TextStyle(color: Colors.white70, fontSize: 14)),
                              const Spacer(),
                              Icon(
                                _showNameField
                                    ? Icons.keyboard_arrow_up
                                    : Icons.keyboard_arrow_down,
                                color: Colors.white38, size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (_showNameField) ...[
                        const _Divider(),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _nameController,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: InputDecoration(
                                    hintText: 'Enter new name',
                                    hintStyle: const TextStyle(color: Colors.white30),
                                    filled: true,
                                    fillColor: Colors.white.withOpacity(0.07),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide.none,
                                    ),
                                    isDense: true,
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 12),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              GestureDetector(
                                onTap: _saveName,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF3B82F6),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Text('Save',
                                      style: TextStyle(
                                          color: Colors.white, fontWeight: FontWeight.w700)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ]),

                    const SizedBox(height: 16),

                    // ── Appearance ─────────────────────────────────
                    _SectionLabel('Appearance'),
                    _Card(children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: Row(
                          children: [
                            const Icon(Icons.palette_outlined, color: Colors.white54, size: 20),
                            const SizedBox(width: 12),
                            const Text('App Theme',
                                style: TextStyle(color: Colors.white70, fontSize: 14)),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text('Coming Soon',
                                  style: TextStyle(color: Colors.white38, fontSize: 12)),
                            ),
                          ],
                        ),
                      ),
                    ]),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Sub-widgets ────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(text,
          style: const TextStyle(
              color: Colors.white54,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8)),
    );
  }
}

class _Card extends StatelessWidget {
  final List<Widget> children;
  const _Card({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(children: children),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();
  @override
  Widget build(BuildContext context) =>
      const Divider(color: Colors.white12, height: 1);
}

class _ToggleRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: Colors.white54, size: 20),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 14)),
          const Spacer(),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF3B82F6),
            inactiveTrackColor: Colors.white12,
          ),
        ],
      ),
    );
  }
}