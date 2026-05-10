import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'theme.dart';
import 'services/chore_service.dart';
import 'services/house_service.dart';

class AssignChoreScreen extends StatefulWidget {
  const AssignChoreScreen({super.key});

  @override
  State<AssignChoreScreen> createState() => _AssignChoreScreenState();
}

class _AssignChoreScreenState extends State<AssignChoreScreen> {
  String? _selectedAssigneeId;
  bool _isHighPriority = false;
  bool _isLoading = false;
  DateTime _dueAt = DateTime.now().add(const Duration(days: 1));
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueAt,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked == null) return;
    setState(() {
      _dueAt = DateTime(
        picked.year,
        picked.month,
        picked.day,
        _dueAt.hour,
        _dueAt.minute,
      );
    });
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_dueAt),
    );
    if (picked == null) return;
    setState(() {
      _dueAt = DateTime(
        _dueAt.year,
        _dueAt.month,
        _dueAt.day,
        picked.hour,
        picked.minute,
      );
    });
  }

  Future<void> _createChore() async {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    if (title.isEmpty) {
      _showMessage('Please enter chore title.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final houseId = await HouseService.instance.getCurrentUserHouseId();
      await ChoreService.instance.createChore(
        houseId: houseId,
        title: title,
        description: description,
        dueAt: _dueAt,
        isHighPriority: _isHighPriority,
        assignedUserIds:
            _selectedAssigneeId == null ? const [] : [_selectedAssigneeId!],
      );
      if (!mounted) return;
      _showMessage('Chore assigned successfully.');
      Navigator.pop(context);
    } catch (e) {
      _showMessage(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // Blur backdrop
          Positioned.fill(
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: Container(
                  color: Colors.black.withValues(
                    alpha: cs.brightness == Brightness.dark ? 0.55 : 0.22,
                  ),
                ),
              ),
            ),
          ),

          // Bottom Sheet Card
          Align(
            alignment: Alignment.bottomCenter,
            child: AnimatedPadding(
              padding: EdgeInsets.only(bottom: bottomPadding),
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutQuad,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24).copyWith(
                    bottom: MediaQuery.of(context).padding.bottom + 24),
                decoration: BoxDecoration(
                  color: AppTheme.cardBackground(context),
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 20,
                      offset: Offset(0, -4),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Assign Chore',
                                  style: textTheme.headlineMedium),
                              const SizedBox(height: 4),
                              Text('Set responsibilities for the week',
                                  style: textTheme.bodyMedium?.copyWith(
                                      color:
                                          AppTheme.schemeOnSurfaceVariant(
                                              context))),
                            ],
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: Icon(Icons.close, color: cs.outline),
                            style: IconButton.styleFrom(
                              backgroundColor: cs.surfaceContainerLow,
                              shape: const CircleBorder(),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Selected Task
                      Text('SELECTED TASK',
                          style: textTheme.labelSmall?.copyWith(
                              color: cs.outline, letterSpacing: 1.5)),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: cs.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: cs.outlineVariant),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: AppTheme.primaryContainerOpacity20,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.cleaning_services,
                                  color: AppTheme.primaryContainer),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('New Chore',
                                      style: textTheme.bodyLarge),
                                  const SizedBox(height: 4),
                                  Text('Created by you',
                                      style: textTheme.bodyMedium?.copyWith(
                                          color: AppTheme.outline)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _titleController,
                        style: textTheme.bodyLarge?.copyWith(color: cs.onSurface),
                        decoration: InputDecoration(
                          hintText: 'Task title (e.g. Clean Kitchen)',
                        ).applyDefaults(
                            Theme.of(context).inputDecorationTheme),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 2,
                        style: textTheme.bodyLarge?.copyWith(color: cs.onSurface),
                        decoration: InputDecoration(
                          hintText: 'Optional details',
                        ).applyDefaults(
                            Theme.of(context).inputDecorationTheme),
                      ),
                      const SizedBox(height: 24),

                      // Assign to Roommate
                      Text('Assign to Roommate',
                          style: textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w500)),
                      const SizedBox(height: 12),
                      _buildAssignees(),
                      const SizedBox(height: 24),

                      // Due Date
                      Text('Due Date',
                          style: textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w500)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: cs.surfaceContainerLowest,
                                borderRadius: BorderRadius.circular(16),
                                border:
                                    Border.all(color: cs.outlineVariant),
                              ),
                              child: InkWell(
                                onTap: _pickDate,
                                child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('DATE',
                                          style: textTheme.labelSmall?.copyWith(
                                              color: cs.onSurface)),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${_dueAt.month}/${_dueAt.day},',
                                          style: textTheme.bodyMedium?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: cs.onSurface)),
                                      Text('${_dueAt.year}',
                                          style: textTheme.bodyMedium?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: cs.onSurface)),
                                    ],
                                  ),
                                  Icon(Icons.calendar_today,
                                      color: cs.onSurface),
                                ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: cs.surfaceContainerLowest,
                                borderRadius: BorderRadius.circular(16),
                                border:
                                    Border.all(color: cs.outlineVariant),
                              ),
                              child: InkWell(
                                onTap: _pickTime,
                                child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('TIME',
                                          style: textTheme.labelSmall?.copyWith(
                                              color: cs.onSurface)),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${_dueAt.hour.toString().padLeft(2, '0')}:${_dueAt.minute.toString().padLeft(2, '0')}',
                                          style: textTheme.bodyMedium?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: cs.onSurface)),
                                    ],
                                  ),
                                  Icon(Icons.schedule,
                                      color: cs.onSurface),
                                ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Priority Toggle
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.priority_high,
                                  color: cs.onSurface),
                              const SizedBox(width: 12),
                              Text('Mark as High Priority',
                                  style: textTheme.bodyMedium),
                            ],
                          ),
                          Switch(
                            value: _isHighPriority,
                            onChanged: (v) =>
                                setState(() => _isHighPriority = v),
                            thumbColor:
                                WidgetStateProperty.resolveWith((states) {
                              if (states.contains(WidgetState.selected)) {
                                return cs.surface;
                              }
                              return cs.surfaceContainerHighest;
                            }),
                            trackColor:
                                WidgetStateProperty.resolveWith((states) {
                              if (states.contains(WidgetState.selected)) {
                                return AppTheme.primaryContainer;
                              }
                              return cs.surfaceContainerHighest;
                            }),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: cs.onSurface,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16)),
                                side: BorderSide(color: cs.outlineVariant),
                              ),
                              child: const Text('Cancel'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 1,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _createChore,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: cs.surfaceContainerHighest,
                                foregroundColor: cs.onSurface,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16)),
                                elevation: 2,
                                shadowColor: AppTheme.primaryContainerOpacity40,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(_isLoading ? 'Saving...' : 'Confirm'),
                                  const Text('Assignment'),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssignees() {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: HouseService.instance.watchCurrentUserProfile(),
      builder: (context, userSnapshot) {
        final houseId = userSnapshot.data?.data()?['houseId'] as String?;
        if (houseId == null) {
          return const Text('Join a house first to assign roommates.');
        }
        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: HouseService.instance.watchHouseMembers(houseId),
          builder: (context, membersSnapshot) {
            final docs = membersSnapshot.data?.docs ?? [];
            if (docs.isEmpty) {
              return const Text('No roommates found yet.');
            }

            if (_selectedAssigneeId == null) {
              final currentUserId = docs.first.data()['userId'] as String?;
              if (currentUserId != null) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted && _selectedAssigneeId == null) {
                    setState(() => _selectedAssigneeId = currentUserId);
                  }
                });
              }
            }

            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: docs.map((doc) {
                  final data = doc.data();
                  final userId = (data['userId'] as String?) ?? '';
                  final memberName = (data['memberName'] as String?) ?? 'Member';
                  final isSelected = _selectedAssigneeId == userId;
                  return Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: _buildAssigneeAvatar(
                      userId: userId,
                      name: memberName,
                      isSelected: isSelected,
                    ),
                  );
                }).toList(),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAssigneeAvatar({
    required String userId,
    required String name,
    required bool isSelected,
  }) {
    final textTheme = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final initials = _initials(name);
    return GestureDetector(
      onTap: () => setState(() => _selectedAssigneeId = userId),
      child: Opacity(
        opacity: isSelected ? 1.0 : 0.6,
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: isSelected
                    ? Border.all(color: cs.primary, width: 3)
                    : Border.all(color: Colors.transparent, width: 3),
              ),
              padding: const EdgeInsets.all(2),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: Container(
                  color: cs.surfaceContainer,
                  alignment: Alignment.center,
                  child: Text(
                    initials,
                    style: textTheme.titleMedium?.copyWith(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(name,
                style: textTheme.bodyMedium?.copyWith(
                    color: isSelected ? cs.onSurface : cs.outline,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal)),
          ],
        ),
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((e) => e.isNotEmpty);
    final firstTwo = parts.take(2).toList();
    if (firstTwo.isEmpty) return 'M';
    return firstTwo.map((p) => p[0].toUpperCase()).join();
  }
}
