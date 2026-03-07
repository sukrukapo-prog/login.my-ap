import 'package:flutter/material.dart';
import 'package:fitmetrics/models/onboarding_data.dart';
import 'package:fitmetrics/routes.dart';
import 'package:fitmetrics/core/avatar_data.dart';
import 'package:fitmetrics/services/local_storage.dart';

class AvatarSelectionScreen extends StatefulWidget {
  final OnboardingData data;
  const AvatarSelectionScreen({super.key, required this.data});

  @override
  State<AvatarSelectionScreen> createState() => _AvatarSelectionScreenState();
}

class _AvatarSelectionScreenState extends State<AvatarSelectionScreen> {
  String? _selectedAvatarId;
  String _selectedCategory = 'all';

  List<AppAvatar> get _filteredAvatars {
    if (_selectedCategory == 'all') return allAvatars;
    return allAvatars.where((a) => a.category == _selectedCategory).toList();
  }

  void _continue() async {
    if (_selectedAvatarId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an avatar first')),
      );
      return;
    }

    await LocalStorage.saveAvatarId(_selectedAvatarId!);

    if (mounted) {
      Navigator.pushReplacementNamed(
        context,
        AppRoutes.main,
        arguments: widget.data,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1624),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    // Header
                    const Text(
                      'Choose Your\nAvatar',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'This will represent you throughout the app.',
                      style: TextStyle(color: Colors.white54, fontSize: 14),
                    ),
                    const SizedBox(height: 24),

                    // Selected avatar preview
                    if (_selectedAvatarId != null) ...[
                      Center(
                        child: Column(
                          children: [
                            AvatarWidget(
                              avatarId: _selectedAvatarId,
                              size: 80,
                              showBorder: true,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              getAvatarById(_selectedAvatarId).name,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Category filter
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _CategoryChip(label: 'All', value: 'all', selected: _selectedCategory == 'all', onTap: () => setState(() => _selectedCategory = 'all')),
                          const SizedBox(width: 8),
                          _CategoryChip(label: '♂ Male', value: 'male', selected: _selectedCategory == 'male', onTap: () => setState(() => _selectedCategory = 'male')),
                          const SizedBox(width: 8),
                          _CategoryChip(label: '♀ Female', value: 'female', selected: _selectedCategory == 'female', onTap: () => setState(() => _selectedCategory = 'female')),
                          const SizedBox(width: 8),
                          _CategoryChip(label: '🐾 Animal', value: 'animal', selected: _selectedCategory == 'animal', onTap: () => setState(() => _selectedCategory = 'animal')),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Avatar grid
                    Expanded(
                      child: GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: _filteredAvatars.length,
                        itemBuilder: (context, index) {
                          final avatar = _filteredAvatars[index];
                          final isSelected = _selectedAvatarId == avatar.id;
                          return GestureDetector(
                            onTap: () => setState(() => _selectedAvatarId = avatar.id),
                            child: Column(
                              children: [
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isSelected
                                          ? avatar.primaryColor
                                          : Colors.transparent,
                                      width: 3,
                                    ),
                                  ),
                                  child: AvatarWidget(
                                    avatarId: avatar.id,
                                    size: 60,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  avatar.name,
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : Colors.white38,
                                    fontSize: 10,
                                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Continue button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _selectedAvatarId != null ? _continue : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6),
                    disabledBackgroundColor: Colors.white12,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: const Text(
                    "Let's Go!",
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white),
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

class _CategoryChip extends StatelessWidget {
  final String label;
  final String value;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.value,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF3B82F6) : Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? const Color(0xFF3B82F6) : Colors.transparent,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.white54,
            fontSize: 13,
            fontWeight: selected ? FontWeight.w700 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}