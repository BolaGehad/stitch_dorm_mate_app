import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'theme.dart';
import 'splash_screen.dart'; // Importing for BlueprintPainter reuse
import 'dashboard_screen.dart';
import 'wallet_screen.dart';
import 'profile_screen.dart';
import 'shopping_screen.dart';
import 'game_center_screen.dart';
import 'chore_history_screen.dart';
import 'assign_chore_screen.dart';
import 'dormy_ai_screen.dart';
import 'services/auth_service.dart';
import 'services/chore_service.dart';
import 'services/house_service.dart';

class ChoresScreen extends StatelessWidget {
  const ChoresScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
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
                icon: const Icon(Icons.arrow_back, color: AppTheme.outline),
                onPressed: () => Navigator.pop(context),
              ),
              titleSpacing: 0,
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(1),
                child: Container(
                    color: AppTheme.schemeContainerHighest(context), height: 1),
              ),
              title: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: AppTheme.primaryContainerOpacity20, width: 2),
                      image: const DecorationImage(
                        image: NetworkImage(
                            'https://lh3.googleusercontent.com/aida-public/AB6AXuCpvezihTm1XB2FSmj2gUdxS1W1PAJel7dOhwTHvlvNhLwX9z-iY6CpXU8d3aUW79ptsN17ulm3CqHVmnzAiVbXJXWp6RlKol_YBE0tKbvEHokO2zNHj7hWBZGd65aa04dsPcpoX4fKYcuV5AM4J031IfNjmwVLENN19anaCcBRLUuE44dn5jZRjL1hSSU94MMLKmTnGpvOxEmjh2WlstBmtZnY95t-v5Y4_KvuQxss521_F2_um1sVhYE4N0qExMhuvAQLu_SLvzo'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Dorm Mate',
                    style: textTheme.headlineMedium?.copyWith(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.notifications_none,
                      color: AppTheme.primary),
                  onPressed: () {},
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Background Blueprint Grid Layer
          Positioned.fill(
            child: CustomPaint(
              painter: BlueprintPainter(brightness: Theme.of(context).brightness),
            ),
          ),

          SafeArea(
            bottom: false,
            child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: HouseService.instance.watchCurrentUserProfile(),
              builder: (context, userSnapshot) {
                final houseId = userSnapshot.data?.data()?['houseId'] as String?;
                return SingleChildScrollView(
                  padding: const EdgeInsets.only(
                      left: 20, right: 20, top: 24, bottom: 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  // House Fairness Meter Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('House Fairness Meter',
                          style: textTheme.headlineMedium),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4.0),
                        child: Text('Balanced week',
                            style: textTheme.labelSmall
                                ?.copyWith(color: AppTheme.primary)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  _buildDynamicFairnessCard(context, textTheme, houseId),

                  const SizedBox(height: 32),

                  _buildDynamicUpNext(textTheme, houseId),

                  const SizedBox(height: 32),

                  // Weekly Schedule Header
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text('Weekly Schedule',
                            style: textTheme.headlineMedium),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              opaque: false,
                              pageBuilder: (context, _, __) =>
                                  const AssignChoreScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Assign Task'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryContainer,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          textStyle: textTheme.labelMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(width: 16),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ChoreHistoryScreen(),
                            ),
                          );
                        },
                        child: Text('View all',
                            style: textTheme.labelMedium
                                ?.copyWith(color: AppTheme.primary)),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  _buildDynamicScheduleList(context, textTheme, houseId),
                ],
              ),
            );
              },
            ),
          ),

          // Floating Dormy AI Button
          Positioned(
            bottom: 100, // Above bottom nav
            right: 24,
            child: FloatingActionButton(
              heroTag: 'chores_ai_fab',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const DormyAiScreen()),
                );
              },
              backgroundColor: AppTheme.primaryContainer,
              elevation: 4,
              child: const Icon(Icons.smart_toy, color: Colors.white, size: 28),
            ),
          ),
        ],
      ),
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.frostedBottomBarBg(context),
              border: Border(top: BorderSide(color: AppTheme.schemeContainerHighest(context))),
              boxShadow: const [
                BoxShadow(
                  color: AppTheme.primaryContainerOpacity8,
                  blurRadius: 20,
                  offset: Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(context, Icons.grid_view, 'Dashboard', false,
                        () {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const DashboardScreen()));
                    }),
                    _buildNavItem(
                        context,
                        Icons.account_balance_wallet_outlined,
                        'Wallet',
                        false, () {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const WalletScreen()));
                    }),
                    _buildNavItem(context, Icons.assignment_turned_in, 'Chores',
                        true, () {}), // Active state
                    _buildNavItem(
                        context, Icons.shopping_bag_outlined, 'Shopping', false,
                        () {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ShoppingScreen()));
                    }),
                    _buildNavItem(
                        context, Icons.sports_esports_outlined, 'Game', false,
                        () {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const GameCenterScreen()));
                    }),
                    _buildNavItem(
                        context, Icons.person_outline, 'Profile', false, () {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ProfileScreen()));
                    }),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDynamicUpNext(TextTheme textTheme, String? houseId) {
    if (houseId == null) {
      return _buildEmptyChoreCard(textTheme, 'No house found yet.');
    }

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: ChoreService.instance.watchNextPendingChore(houseId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildEmptyChoreCard(
            textTheme,
            'Unable to load chores right now.',
          );
        }
        final docs = [...(snapshot.data?.docs ?? [])];
        docs.sort((a, b) {
          final aDue = (a.data()['dueAt'] as Timestamp?)?.toDate();
          final bDue = (b.data()['dueAt'] as Timestamp?)?.toDate();
          if (aDue == null && bDue == null) return 0;
          if (aDue == null) return 1;
          if (bDue == null) return -1;
          return aDue.compareTo(bDue);
        });
        if (docs.isEmpty) {
          return _buildEmptyChoreCard(textTheme, 'No pending chores.');
        }
        final chore = docs.first;
        final data = chore.data();
        final title = (data['title'] as String?) ?? 'Untitled chore';
        final description = (data['description'] as String?) ?? 'No details';
        final isHighPriority = (data['isHighPriority'] as bool?) ?? false;
        final dueAt = (data['dueAt'] as Timestamp?)?.toDate();

        return Container(
          decoration: BoxDecoration(
            color: AppTheme.primaryContainer,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: AppTheme.primaryContainerOpacity12,
                blurRadius: 16,
                offset: Offset(0, 4),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isHighPriority)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'HIGH PRIORITY',
                      style: textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                        fontSize: 9,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                if (isHighPriority) const SizedBox(height: 12),
                Text(
                  title,
                  style: textTheme.headlineMedium?.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: textTheme.bodyMedium?.copyWith(color: Colors.white.withOpacity(0.9)),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Icon(Icons.event, color: Colors.white, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'Due ${_dueText(dueAt)}',
                      style: textTheme.labelMedium?.copyWith(color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    await ChoreService.instance.markChoreDone(chore.id);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.cardBackground(context),
                    foregroundColor: AppTheme.primary,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Mark as Done'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDynamicFairnessCard(
      BuildContext context, TextTheme textTheme, String? houseId) {
    if (houseId == null) {
      return _fairnessCardShell(context, textTheme, const []);
    }
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: HouseService.instance.watchHouseMembers(houseId),
      builder: (ctx, membersSnapshot) {
        final members = membersSnapshot.data?.docs ?? [];
        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: ChoreService.instance.watchAllChores(houseId),
          builder: (context, choresSnapshot) {
            final chores = choresSnapshot.data?.docs ?? [];
            final rows = members.map((memberDoc) {
              final member = memberDoc.data();
              final uid = (member['userId'] as String?) ?? '';
              final memberName = (member['memberName'] as String?) ?? 'Member';
              int assigned = 0;
              int done = 0;
              for (final choreDoc in chores) {
                final chore = choreDoc.data();
                final assignedIds =
                    List<String>.from(chore['assignedUserIds'] ?? const []);
                final doneIds =
                    List<String>.from(chore['completedByUserIds'] ?? const []);
                if (assignedIds.contains(uid)) {
                  assigned++;
                  if (doneIds.contains(uid)) done++;
                }
              }
              final ratio = assigned == 0 ? 0.0 : done / assigned;
              final isYou = uid == AuthService.instance.currentUser?.uid;
              return _FairnessRowData(
                name: isYou ? 'You' : memberName,
                ratio: ratio,
                isYou: isYou,
              );
            }).toList();

            return _fairnessCardShell(ctx, textTheme, rows);
          },
        );
      },
    );
  }

  Widget _fairnessCardShell(
      BuildContext context, TextTheme textTheme, List<_FairnessRowData> rows) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground(context),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: AppTheme.primaryContainerOpacity8,
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: rows.isEmpty
            ? [
                Text(
                  'No members data yet.',
                  style: textTheme.bodyMedium?.copyWith(color: AppTheme.outline),
                ),
              ]
            : rows.map((row) {
                final index = rows.indexOf(row);
                return Column(
                  children: [
                    _buildFairnessRow(context, textTheme, row.name, row.ratio,
                        isYou: row.isYou),
                    if (index != rows.length - 1) const SizedBox(height: 16),
                  ],
                );
              }).toList(),
      ),
    );
  }

  Widget _buildDynamicScheduleList(
      BuildContext context, TextTheme textTheme, String? houseId) {
    if (houseId == null) {
      return _buildChoreItem(
        context,
        textTheme,
        title: 'No house linked',
        subtitle: 'Create or join a house first',
        icon: Icons.info_outline,
      );
    }

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: ChoreService.instance.watchPendingChores(houseId),
      builder: (ctx, snapshot) {
        if (snapshot.hasError) {
          return _buildChoreItem(
            ctx,
            textTheme,
            title: 'Failed to load chores',
            subtitle: 'Please try again in a moment',
            icon: Icons.error_outline,
          );
        }
        final docs = [...(snapshot.data?.docs ?? [])];
        docs.sort((a, b) {
          final aDue = (a.data()['dueAt'] as Timestamp?)?.toDate();
          final bDue = (b.data()['dueAt'] as Timestamp?)?.toDate();
          if (aDue == null && bDue == null) return 0;
          if (aDue == null) return 1;
          if (bDue == null) return -1;
          return aDue.compareTo(bDue);
        });
        if (docs.isEmpty) {
          return _buildChoreItem(
            ctx,
            textTheme,
            title: 'No pending tasks',
            subtitle: 'You are all caught up',
            icon: Icons.check_circle_outline,
          );
        }

        return Column(
          children: docs.take(5).toList().asMap().entries.map((entry) {
            final idx = entry.key;
            final chore = entry.value.data();
            final dueAt = (chore['dueAt'] as Timestamp?)?.toDate();
            return _buildChoreItem(
              ctx,
              textTheme,
              title: (chore['title'] as String?) ?? 'Untitled chore',
              subtitle: 'Due ${_dueText(dueAt)}',
              icon: Icons.assignment,
              isActive: idx == 0,
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildEmptyChoreCard(TextTheme textTheme, String message) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.primaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        message,
        style: textTheme.bodyLarge?.copyWith(color: Colors.white),
      ),
    );
  }

  String _dueText(DateTime? dueAt) {
    if (dueAt == null) return 'No date';
    return '${dueAt.year}-${dueAt.month.toString().padLeft(2, '0')}-${dueAt.day.toString().padLeft(2, '0')}';
  }

  Widget _buildFairnessRow(BuildContext context, TextTheme textTheme,
      String name, double percentage,
      {bool isYou = false}) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(name,
                    style: textTheme.labelMedium?.copyWith(
                        color: AppTheme.schemeOnSurface(context))),
                if (isYou) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryContainerOpacity10,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text('You',
                        style: textTheme.labelSmall
                            ?.copyWith(color: AppTheme.primary, fontSize: 10)),
                  ),
                ],
              ],
            ),
            Text('${(percentage * 100).toInt()}%',
                style: textTheme.labelSmall
                    ?.copyWith(color: AppTheme.onSurfaceVariantOpacity60)),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 8,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppTheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: percentage,
            child: Container(
              decoration: BoxDecoration(
                color: isYou
                    ? AppTheme.primaryContainer
                    : AppTheme.primaryContainerOpacity60,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChoreItem(BuildContext context, TextTheme textTheme,
      {required String title,
      required String subtitle,
      required IconData icon,
      bool isActive = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isActive
            ? AppTheme.cardBackground(context)
            : AppTheme.schemeContainerLow(context),
        borderRadius: BorderRadius.circular(12),
        border: isActive
            ? const Border(
                left: BorderSide(color: AppTheme.primaryContainer, width: 4))
            : null,
        boxShadow: const [
          BoxShadow(
            color: AppTheme.primaryContainerOpacity8,
            blurRadius: 12,
            offset: Offset(0, 2),
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppTheme.primary, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: textTheme.labelMedium?.copyWith(
                          color: AppTheme.schemeOnSurface(context),
                          fontSize: 14)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: textTheme.labelSmall?.copyWith(
                          color: AppTheme.schemeOnSurfaceVariant(context))),
                ],
              ),
            ),
            Icon(Icons.more_vert,
                color: Theme.of(context).colorScheme.outline, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, IconData icon, String label,
      bool isActive, VoidCallback onTap) {
    final color = isActive
        ? AppTheme.primary
        : Theme.of(context).colorScheme.outline;
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: color,
                    fontSize: 9,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FairnessRowData {
  _FairnessRowData({
    required this.name,
    required this.ratio,
    required this.isYou,
  });

  final String name;
  final double ratio;
  final bool isYou;
}
