import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:ui' as ui;
import 'dart:math' as math;
import 'theme.dart';
import 'splash_screen.dart';
import 'dormy_ai_screen.dart';
import 'services/chore_service.dart';
import 'services/house_service.dart';

class DecisionWheelScreen extends StatefulWidget {
  const DecisionWheelScreen({super.key});

  @override
  State<DecisionWheelScreen> createState() => _DecisionWheelScreenState();
}

class _DecisionWheelScreenState extends State<DecisionWheelScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  double _rotation = 0.0;
  int _lastTick = 0;

  List<Map<String, dynamic>> roommates = [];

  Map<String, dynamic>? _currentTask;
  String? _houseId;
  bool _loadingData = true;
  List<Map<String, dynamic>> _availableTasks = [];
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 4));
    _animation = Tween<double>(begin: 0, end: 0).animate(_controller);

    _controller.addListener(() {
      setState(() => _rotation = _animation.value);
      final sweepAngle = 2 * math.pi / roommates.length;
      final currentTick = (_rotation / sweepAngle).floor();
      if (currentTick != _lastTick) {
        HapticFeedback.selectionClick();
        _lastTick = currentTick;
      }
    });
    _bootstrapData();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _spinWheel() {
    if (_controller.isAnimating) return;

    HapticFeedback.heavyImpact();
    final random = math.Random();
    final extraSpins = 4 + random.nextInt(3);
    final randomStopAngle = random.nextDouble() * 2 * math.pi;
    final targetRotation = _rotation + (extraSpins * 2 * math.pi) + randomStopAngle;

    _animation = Tween<double>(begin: _rotation, end: targetRotation).animate(
      CurvedAnimation(parent: _controller, curve: const Cubic(0.1, 0.9, 0.2, 1.0)),
    );

    _lastTick = (_rotation / (2 * math.pi / roommates.length)).floor();
    _controller.forward(from: 0.0).then((_) {
      _rotation = targetRotation % (2 * math.pi);
      _showWinner();
    });
  }

  void _showWinner() {
    HapticFeedback.vibrate();
    if (_currentTask == null || roommates.length < 2) return;
    final sweepAngle = 2 * math.pi / roommates.length;
    final winnerIndex =
        (roommates.length - (_rotation % (2 * math.pi)) / sweepAngle).floor() % roommates.length;
    final winner = roommates[winnerIndex];

    showDialog(
      context: context,
      barrierColor: AppTheme.onSurface.withValues(alpha: 0.6),
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🎉', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 16),
              Text(
                'Fate has spoken!',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppTheme.outline,
                      letterSpacing: 1.5,
                    ),
              ),
              const SizedBox(height: 8),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppTheme.schemeOnSurface(context)),
                  children: [
                    const TextSpan(text: "It's "),
                    TextSpan(
                      text: "${winner['name']}",
                      style: TextStyle(color: winner['color'], fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: "'s turn to ${_currentTask?['title'] ?? ''}!"),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  final winnerUserId = winner['userId'] as String?;
                  final houseId = _houseId;
                  if (winnerUserId != null && houseId != null) {
                    try {
                      await ChoreService.instance.createChore(
                        houseId: houseId,
                        title: _currentTask!['title'] as String,
                        description: 'Assigned by Decision Wheel',
                        dueAt: DateTime.now().add(const Duration(days: 1)),
                        isHighPriority: false,
                        assignedUserIds: [winnerUserId],
                      );
                    } catch (_) {}
                  }
                  if (!mounted) return;
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryContainer,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Text('Confirm Assignment'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _bootstrapData() async {
    try {
      final houseId = await HouseService.instance.getCurrentUserHouseId();
      final membersSnap =
          await HouseService.instance.watchHouseMembers(houseId).first;
      final pendingSnap =
          await ChoreService.instance.watchPendingChores(houseId).first;

      final sourceMembers = membersSnap.docs.map((d) => d.data()).toList();
      final colors = <Color>[
        AppTheme.primary,
        AppTheme.secondaryContainer,
        AppTheme.primaryContainer,
        AppTheme.error,
        Colors.blueGrey,
      ];
      final loadedRoommates = <Map<String, dynamic>>[];
      for (var i = 0; i < sourceMembers.length; i++) {
        final m = sourceMembers[i];
        final userId = (m['userId'] as String?) ?? '';
        if (userId.trim().isEmpty) continue;
        loadedRoommates.add({
          'name': (m['memberName'] as String?) ?? 'Roommate',
          'userId': userId,
          'color': colors[i % colors.length],
        });
      }

      final pendingDocs = [...pendingSnap.docs];
      pendingDocs.sort((a, b) {
        final aDue = (a.data()['dueAt'] as Timestamp?)?.toDate();
        final bDue = (b.data()['dueAt'] as Timestamp?)?.toDate();
        if (aDue == null && bDue == null) return 0;
        if (aDue == null) return 1;
        if (bDue == null) return -1;
        return aDue.compareTo(bDue);
      });

      final loadedTasks = pendingDocs.map((d) {
        final data = d.data();
        return {
          'title': (data['title'] as String?) ?? 'Untitled chore',
          'icon': Icons.assignment_turned_in,
        };
      }).toList();

      if (!mounted) return;
      setState(() {
        _houseId = houseId;
        _availableTasks = loadedTasks;
        _currentTask = loadedTasks.isNotEmpty ? loadedTasks.first : null;
        roommates = loadedRoommates;
        _loadingData = false;
        _loadError = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loadingData = false;
        _loadError = 'Could not load house data. Join a house to use the wheel.';
      });
    }
  }

  void _showTaskSelector() {
    final tasks = _availableTasks;
    if (tasks.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No pending chores to choose from.')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Select Task', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 16),
              ...tasks.map(
                (task) => ListTile(
                  leading: Icon(task['icon'] as IconData, color: AppTheme.primary),
                  title: Text(task['title'] as String, style: Theme.of(context).textTheme.bodyLarge),
                  onTap: () {
                    setState(() => _currentTask = task);
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCustomizeRoommates() {
    final nameController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 24,
                right: 24,
                top: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Customize Roommates', style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: roommates.map((r) {
                      return Chip(
                        label: Text(r['name'], style: const TextStyle(color: Colors.white)),
                        backgroundColor: r['color'],
                        deleteIconColor: Colors.white,
                        onDeleted: roommates.length > 2
                            ? () {
                                setState(() => roommates.remove(r));
                                setModalState(() {});
                              }
                            : null,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      hintText: 'Add new roommate...',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.add_circle, color: AppTheme.primary),
                        onPressed: () {
                          if (nameController.text.trim().isNotEmpty) {
                            setState(() {
                              roommates.add({
                                'name': nameController.text.trim(),
                                'color': Colors.blueGrey,
                              });
                            });
                            nameController.clear();
                            setModalState(() {});
                          }
                        },
                      ),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
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
              title: Text('Decision Wheel', style: textTheme.headlineMedium?.copyWith(color: AppTheme.primary)),
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
            child: _loadingData
                ? const Center(child: CircularProgressIndicator())
                : (_loadError != null)
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            _loadError!,
                            style: textTheme.bodyLarge?.copyWith(
                              color: AppTheme.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    : (roommates.length < 2)
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Text(
                                'You need at least 2 house members to spin.',
                                style: textTheme.bodyLarge?.copyWith(
                                  color: AppTheme.onSurfaceVariant,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          )
                        : SingleChildScrollView(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 32, bottom: 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('Let fate decide who takes the next task.',
                      style: textTheme.bodyMedium?.copyWith(color: AppTheme.onSurfaceVariant),
                      textAlign: TextAlign.center),
                  const SizedBox(height: 24),
                  InkWell(
                    onTap: _showTaskSelector,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Icon((_currentTask?['icon'] as IconData?) ?? Icons.assignment_turned_in,
                              color: AppTheme.primary),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              (_currentTask?['title'] as String?) ?? 'No pending chores',
                              style: textTheme.bodyLarge,
                            ),
                          ),
                          const Icon(Icons.expand_more, color: AppTheme.outline),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    height: 280,
                    child: Stack(
                      alignment: Alignment.topCenter,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Transform.rotate(
                            angle: _rotation,
                            child: CustomPaint(
                              size: const Size(260, 260),
                              painter: WheelPainter(roommates),
                            ),
                          ),
                        ),
                        CustomPaint(size: const Size(30, 36), painter: PointerPainter()),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: _spinWheel,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
                    ),
                    child: const Text('SPIN'),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _showCustomizeRoommates,
                    child: Text('Customize Roommates', style: textTheme.bodyMedium?.copyWith(color: AppTheme.primary)),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 24,
            right: 24,
            child: FloatingActionButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const DormyAiScreen()));
              },
              backgroundColor: AppTheme.primary,
              child: const Icon(Icons.smart_toy, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class WheelPainter extends CustomPainter {
  final List<Map<String, dynamic>> items;
  WheelPainter(this.items);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final sweepAngle = 2 * math.pi / items.length;

    for (int i = 0; i < items.length; i++) {
      final startAngle = i * sweepAngle - math.pi / 2;
      final fill = Paint()
        ..color = items[i]['color'] as Color
        ..style = PaintingStyle.fill;
      canvas.drawArc(rect, startAngle, sweepAngle, true, fill);

      final divider = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;
      canvas.drawArc(rect, startAngle, sweepAngle, true, divider);
    }
  }

  @override
  bool shouldRepaint(covariant WheelPainter oldDelegate) => false;
}

class PointerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.onSurface
      ..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
