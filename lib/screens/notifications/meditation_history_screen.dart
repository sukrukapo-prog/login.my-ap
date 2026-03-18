import 'package:flutter/material.dart';
import 'package:fitmetrics/services/local_storage.dart';
import 'package:fitmetrics/services/firestore_service.dart';
import 'package:fitmetrics/core/haptic_service.dart';

class MeditationHistoryScreen extends StatefulWidget {
  const MeditationHistoryScreen({super.key});

  @override
  State<MeditationHistoryScreen> createState() => _MeditationHistoryScreenState();
}

class _MeditationHistoryScreenState extends State<MeditationHistoryScreen> {
  List<Map<String, dynamic>> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final history = await FirestoreService  .getMeditationHistory();
    setState(() {
      _history = history;
      _isLoading = false;
    });
  }

  Color _typeColor(String type) {
    return type == 'movement'
        ? const Color(0xFF3B82F6)
        : const Color(0xFF8B5CF6);
  }

  IconData _typeIcon(String type) {
    return type == 'movement'
        ? Icons.directions_walk
        : Icons.music_note;
  }

  String _formatDate(String iso) {
    try {
      final dt = DateTime.parse(iso);
      final now = DateTime.now();
      final diff = now.difference(dt);
      if (diff.inDays == 0) return 'Today ${dt.hour.toString().padLeft(2,'0')}:${dt.minute.toString().padLeft(2,'0')}';
      if (diff.inDays == 1) return 'Yesterday';
      if (diff.inDays < 7) return '${diff.inDays} days ago';
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return '';
    }
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
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () { HapticService.light(); Navigator.pop(context); },
                    child: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(20),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withAlpha(30)),
                      ),
                      child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Text('Session History',
                        style: TextStyle(color: Colors.white, fontSize: 20,
                            fontWeight: FontWeight.w800)),
                  ),
                  if (_history.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF8B5CF6).withAlpha(30),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text('${_history.length} sessions',
                          style: const TextStyle(
                              color: Color(0xFF8B5CF6), fontSize: 12,
                              fontWeight: FontWeight.w600)),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(
                  color: Color(0xFF3B82F6)))
                  : _history.isEmpty
                  ? _EmptyState()
                  : ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                itemCount: _history.length,
                itemBuilder: (_, i) {
                  final item = _history[i];
                  final type = item['type'] ?? 'movement';
                  final color = _typeColor(type);
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: color.withAlpha(15),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: color.withAlpha(40)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44, height: 44,
                          decoration: BoxDecoration(
                            color: color.withAlpha(30),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(_typeIcon(type),
                              color: color, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item['sessionName'] ?? 'Session',
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 14,
                                      fontWeight: FontWeight.w700)),
                              const SizedBox(height: 3),
                              Row(
                                children: [
                                  Icon(Icons.access_time,
                                      color: Colors.white38, size: 11),
                                  const SizedBox(width: 3),
                                  Text('${item['minutes'] ?? 0} min',
                                      style: const TextStyle(
                                          color: Colors.white54,
                                          fontSize: 11)),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: color.withAlpha(30),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      type == 'movement'
                                          ? 'Movement'
                                          : 'Music',
                                      style: TextStyle(
                                          color: color,
                                          fontSize: 9,
                                          fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Text(_formatDate(item['timestamp'] ?? ''),
                            style: const TextStyle(
                                color: Colors.white38, fontSize: 11)),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.self_improvement, color: Colors.white.withAlpha(40), size: 70),
          const SizedBox(height: 16),
          const Text('No sessions yet',
              style: TextStyle(color: Colors.white38, fontSize: 16,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          const Text('Complete a meditation to see your history',
              style: TextStyle(color: Colors.white24, fontSize: 13)),
        ],
      ),
    );
  }
}