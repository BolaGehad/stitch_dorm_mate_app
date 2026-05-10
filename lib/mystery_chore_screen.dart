import 'dart:math';

import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'theme.dart';
import 'splash_screen.dart';
import 'services/game_center_service.dart';

class _MysteryTask {
  const _MysteryTask({
    required this.title,
    required this.description,
    required this.icon,
  });

  final String title;
  final String description;
  final IconData icon;
}

class MysteryChoreScreen extends StatefulWidget {
  const MysteryChoreScreen({super.key});

  @override
  State<MysteryChoreScreen> createState() => _MysteryChoreScreenState();
}

class _MysteryChoreScreenState extends State<MysteryChoreScreen>
    with SingleTickerProviderStateMixin {
  static const List<_MysteryTask> _pool = [
    _MysteryTask(
      title: 'Clean the Microwave!',
      description: 'Wipe down the inside and wash the glass plate.',
      icon: Icons.microwave,
    ),
    _MysteryTask(
      title: 'Scrub the Sink',
      description: 'Clear dishes and polish the faucet and basin.',
      icon: Icons.water_drop_outlined,
    ),
    _MysteryTask(
      title: 'Vacuum the Common Area',
      description: 'Hit the couch crumbs and the main walking paths.',
      icon: Icons.cleaning_services,
    ),
    _MysteryTask(
      title: 'Take Out Trash & Recycling',
      description: 'All bins — tie bags and replace liners if needed.',
      icon: Icons.delete_outline,
    ),
    _MysteryTask(
      title: 'Wipe Kitchen Counters',
      description: 'Clear clutter, disinfect, and dry surfaces.',
      icon: Icons.kitchen,
    ),
    _MysteryTask(
      title: 'Load / Unload Dishwasher',
      description: 'Run a cycle if full; empty clean dishes to cabinets.',
      icon: Icons.local_dining_outlined,
    ),
    _MysteryTask(
      title: 'Clean Bathroom Mirror',
      description: 'Streak-free glass and quick wipe of the sink ledge.',
      icon: Icons.auto_fix_high,
    ),
    _MysteryTask(
      title: 'Sweep the Entryway',
      description: 'Shoes in a row; sweep dirt tracked inside.',
      icon: Icons.door_front_door_outlined,
    ),
  ];

  final Random _rng = Random();

  bool _isRevealed = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isSaving = false;
  _MysteryTask? _current;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _scaleAnimation = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _pickTask() {
    _current = _pool[_rng.nextInt(_pool.length)];
  }

  void _revealChore() {
    _pickTask();
    setState(() => _isRevealed = true);
    _controller.forward(from: 0);
  }

  void _drawAnotherTask() {
    _pickTask();
    _controller.forward(from: 0);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final task = _current;
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: AppTheme.schemeSurface(context),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: AppBar(
              backgroundColor: AppTheme.frostedBarBg(context),
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: AppTheme.onSurfaceVariant),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text('Mystery Chore',
                  style: textTheme.headlineMedium?.copyWith(color: AppTheme.primary)),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
              child: CustomPaint(
                  painter: BlueprintPainter(
                      brightness: Theme.of(context).brightness))),
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (!_isRevealed) ...[
                      Text('Dare to open the box?', style: textTheme.headlineLarge),
                      const SizedBox(height: 8),
                      Text(
                        'Tap the gift — each draw picks a random chore. Complete it for Double Points (x2)!',
                        textAlign: TextAlign.center,
                        style: textTheme.bodyMedium?.copyWith(color: AppTheme.outline),
                      ),
                      const SizedBox(height: 64),
                      GestureDetector(
                        onTap: _revealChore,
                        child: Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            color: Colors.purple.shade400,
                            borderRadius: BorderRadius.circular(32),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.purple.shade200.withValues(alpha: 0.6),
                                blurRadius: 24,
                                offset: const Offset(0, 12),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Icon(Icons.card_giftcard, color: Colors.white, size: 80),
                          ),
                        ),
                      ),
                    ] else if (task != null) ...[
                      ScaleTransition(
                        scale: _scaleAnimation,
                        child: Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: AppTheme.cardBackground(context),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: AppTheme.primaryContainer, width: 2),
                            boxShadow: const [
                              BoxShadow(
                                color: AppTheme.primaryContainerOpacity20,
                                blurRadius: 40,
                                offset: Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Icon(task.icon, color: AppTheme.primary, size: 48),
                              const SizedBox(height: 24),
                              Text(
                                task.title,
                                style: textTheme.headlineMedium?.copyWith(
                                    fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                task.description,
                                style: textTheme.bodyMedium?.copyWith(color: AppTheme.outline),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              OutlinedButton.icon(
                                onPressed: _drawAnotherTask,
                                icon: const Icon(Icons.casino, size: 20),
                                label: const Text('Draw another chore'),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _isSaving
                                    ? null
                                    : () async {
                                        setState(() => _isSaving = true);
                                        try {
                                          await GameCenterService.instance.assignMysteryChore(
                                            title: 'Mystery: ${task.title}',
                                            description: task.description,
                                            isHighPriority: false,
                                          );
                                          if (!mounted) return;
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content:
                                                  Text('Challenge saved to your house chores.'),
                                            ),
                                          );
                                          Navigator.pop(context);
                                        } catch (e) {
                                          if (!mounted) return;
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                e.toString().replaceFirst('Exception: ', ''),
                                              ),
                                            ),
                                          );
                                        } finally {
                                          if (mounted) setState(() => _isSaving = false);
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primaryContainer,
                                  foregroundColor: Colors.white,
                                ),
                                child: _isSaving
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Text('Accept Challenge'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
