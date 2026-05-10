import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'theme.dart';
import 'splash_screen.dart'; // Importing for BlueprintPainter reuse
import 'wallet_screen.dart';
import 'chores_screen.dart';
import 'profile_screen.dart';
import 'shopping_screen.dart';
import 'game_center_screen.dart';
import 'dormy_ai_screen.dart';
import 'services/auth_service.dart';
import 'services/expense_service.dart';
import 'services/house_service.dart';
import 'services/chore_service.dart';
import 'services/shopping_service.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final displayName = AuthService.instance.currentUser?.displayName ?? 'Roommate';

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
                            'https://lh3.googleusercontent.com/aida-public/AB6AXuCV7KhHwJXcD7WlA5AbJbyxhKTpIc2-2CkvUcDJNFV-EA5AiyTdIE_mUOWbfqIf1vzJuSUCmUV6aw_M8mbXtR-5jO2EaywJzb955Z0vC396_PD-z49xvtmxCh8EYoXI7sdaKsZJCyaOvArCaxBumil0E4Asw5VX-pwHbiEPHC9zRY9GfGPcdg9G0-6sNZiZOKZzr0kqxk8-xvFIdC83hZsSVWEZnFEZeT533zBJKUetM9dYuzefGaWGlpu4nf57fE8lfrURhoJ6G84'),
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
                      color: AppTheme.outline),
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
                final userData = userSnapshot.data?.data();
                final houseId = userData?['houseId'] as String?;

                return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                  stream: houseId == null
                      ? null
                      : HouseService.instance.watchHouseById(houseId),
                  builder: (context, houseSnapshot) {
                    final houseData = houseSnapshot.data?.data();
                    final houseName = houseData?['name'] as String? ?? 'No house yet';
                    final inviteCode = houseData?['inviteCode'] as String? ?? '-';
                    final membersCount = (houseData?['membersCount'] as num?)?.toInt() ?? 0;
                    final memberLimit = (houseData?['memberLimit'] as num?)?.toInt() ?? 0;

                    return SingleChildScrollView(
                      padding: const EdgeInsets.only(
                          left: 20,
                          right: 20,
                          top: 32,
                          bottom: 120), // Bottom padding accommodates nav bar
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Greeting Header
                          Text('Hello, $displayName', style: textTheme.headlineLarge),
                          const SizedBox(height: 8),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  houseId == null
                                      ? "You're not in a house yet. Create or join one from Home."
                                      : "House: $houseName • Invite: $inviteCode • Members: $membersCount/$memberLimit",
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: AppTheme.schemeOnSurfaceVariant(context),
                                  ),
                                ),
                              ),
                              if (houseId != null && inviteCode.trim().isNotEmpty && inviteCode != '-')
                                IconButton(
                                  tooltip: 'Copy invite code',
                                  onPressed: () async {
                                    await Clipboard.setData(ClipboardData(text: inviteCode));
                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Invite code copied.')),
                                    );
                                  },
                                  icon: const Icon(Icons.copy, size: 18, color: AppTheme.primary),
                                ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          _buildFinancialStatusCard(context, textTheme, houseId),

                          const SizedBox(height: 24),

                          // Next Chore Card
                          _buildNextChoreCard(context, textTheme, houseId),

                          const SizedBox(height: 24),

                          _buildShoppingListCard(context, textTheme, houseId),

                          const SizedBox(height: 24),

                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppTheme.cardBackground(context),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: AppTheme.primaryContainerOpacity20),
                              boxShadow: const [
                                BoxShadow(
                                  color: AppTheme.primaryContainerOpacity8,
                                  blurRadius: 20,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: AppTheme.schemeContainerLow(context),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  alignment: Alignment.center,
                                  child: const Icon(Icons.sports_esports, color: AppTheme.primary),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Game Center', style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
                                      Text(
                                        'Try Decision Wheel, Mystery Chore, and Fridge Police.',
                                        style: textTheme.bodyMedium?.copyWith(color: AppTheme.schemeOnSurfaceVariant(context)),
                                      ),
                                    ],
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (_) => const GameCenterScreen()),
                                    );
                                  },
                                  child: const Text('Open'),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Promo Banner Card
                          Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      color: const Color(0xFF004C46), // on-primary-container
                      image: DecorationImage(
                        image: const NetworkImage(
                            'https://lh3.googleusercontent.com/aida-public/AB6AXuA6xKUCL3AFid8aUA4ZW_86F3af0WHhVpvfo85uXKj20tLhK4g5Z29vyWU9WTBBVkjMSnuZxAHcpHcK824BvkTTw0ZQV6v0Hr2kXJ_F3-mnIbW6YEWfIo7e9jO4kipWLl2nAtO30cNYcUCRiH9dICEDdfEy5ssffra8ixB9ECz_TNINDnFGQbN1WUftaLn0nQp4mbQsmWl25G9UQTgSCWTwO2iF0PjrLrsMfYVzaYE83jk2huaH1qtINtExddzbnb9c-JbEZbr286A'),
                        fit: BoxFit.cover,
                        colorFilter: ColorFilter.mode(
                            Colors.black.withOpacity(0.8), BlendMode.dstATop),
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: AppTheme.primaryContainerOpacity12,
                          blurRadius: 20,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Living Together, Simplified.',
                            style: textTheme.headlineMedium
                                ?.copyWith(color: Colors.white)),
                        const SizedBox(height: 8),
                        Text(
                          "You've saved 4 hours of chores this month by staying organized.",
                          style: textTheme.bodyMedium
                              ?.copyWith(color: Colors.white.withOpacity(0.9)),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.3)),
                            borderRadius: BorderRadius.circular(9999),
                          ),
                          child: Text('See House Stats',
                              style: textTheme.labelMedium
                                  ?.copyWith(color: Colors.white)),
                        ),
                      ],
                    ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // FAB
          Positioned(
            bottom: 100, // Above bottom nav
            right: 24,
            child: FloatingActionButton(
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
                    _buildNavItem(
                        context, Icons.grid_view, 'Dashboard', true, () {}),
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
                    _buildNavItem(context, Icons.assignment_turned_in_outlined,
                        'Chores', false, () {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ChoresScreen()));
                    }),
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

  Widget _buildNextChoreCard(
      BuildContext context, TextTheme textTheme, String? houseId) {
    if (houseId == null) {
      return _nextChoreShell(
        context,
        textTheme,
        title: 'No house linked yet',
        subtitle: 'Join or create a house to start assigning chores.',
        progressText: '0/0 roommates done',
        progress: 0,
      );
    }

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: ChoreService.instance.watchNextPendingChore(houseId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _nextChoreShell(
            context,
            textTheme,
            title: 'Loading next chore...',
            subtitle: 'Fetching chore timeline',
            progressText: '0/0 roommates done',
            progress: 0,
          );
        }

        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return _nextChoreShell(
            context,
            textTheme,
            title: 'No pending chores',
            subtitle: 'Everything looks good for now.',
            progressText: '0/0 roommates done',
            progress: 0,
          );
        }

        final data = docs.first.data();
        final title = (data['title'] as String?) ?? 'Untitled chore';
        final dueAt = data['dueAt'] as Timestamp?;
        final dueDate = dueAt?.toDate();
        final assigned = (data['assignedUserIds'] as List<dynamic>?)?.length ??
            (data['assigneeCount'] as num?)?.toInt() ??
            0;
        final completed = (data['completedByCount'] as num?)?.toInt() ?? 0;
        final safeAssigned = assigned <= 0 ? 1 : assigned;
        final progress = (completed / safeAssigned).clamp(0, 1).toDouble();

        return _nextChoreShell(
          context,
          textTheme,
          title: title,
          subtitle: 'Due: ${_dueText(dueDate)}',
          progressText: '$completed/$assigned roommates done',
          progress: progress,
        );
      },
    );
  }

  Widget _buildFinancialStatusCard(
      BuildContext context, TextTheme textTheme, String? houseId) {
    final userId = AuthService.instance.currentUser?.uid;
    if (houseId == null || userId == null) {
      return _financialCardShell(textTheme, context, owe: 0, owed: 0);
    }
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: ExpenseService.instance.watchExpenses(houseId),
      builder: (context, snapshot) {
        if (!snapshot.hasData &&
            snapshot.connectionState == ConnectionState.waiting) {
          return _financialCardShell(
            textTheme,
            context,
            owe: 0,
            owed: 0,
            statusNote: 'Loading balances…',
            showProgress: true,
          );
        }
        if (snapshot.hasError) {
          return _financialCardShell(
            textTheme,
            context,
            owe: 0,
            owed: 0,
            statusNote:
                'Could not load balances (${snapshot.error})',
          );
        }
        final docs = snapshot.data?.docs ?? [];
        final totals = ExpenseService.instance.summarizeOutstandingForUser(
          userId: userId,
          expenses: docs.map((d) => d.data()),
        );
        return _financialCardShell(
          textTheme,
          context,
          owe: totals.owe,
          owed: totals.owed,
          statusNote:
              docs.isEmpty ? 'No expenses yet — totals will appear here.' : null,
        );
      },
    );
  }

  Widget _financialCardShell(TextTheme textTheme, BuildContext context,
      {required double owe,
      required double owed,
      String? statusNote,
      bool showProgress = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.primaryContainerOpacity20),
        boxShadow: const [
          BoxShadow(
            color: AppTheme.primaryContainerOpacity8,
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'FINANCIAL STATUS',
                style: textTheme.labelSmall?.copyWith(
                  color: AppTheme.primary,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Icon(Icons.account_balance_wallet, color: AppTheme.primary, size: 20),
            ],
          ),
          const SizedBox(height: 16),
          if (statusNote != null) ...[
            Text(
              statusNote,
              style: textTheme.bodySmall?.copyWith(color: AppTheme.schemeOnSurfaceVariant(context)),
            ),
            const SizedBox(height: 8),
          ],
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.schemeContainerLow(context),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: showProgress
                      ? const SizedBox(
                          height: 56,
                          child: Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('You Owe',
                                style: textTheme.labelSmall
                                    ?.copyWith(color: AppTheme.schemeOnSurfaceVariant(context))),
                            const SizedBox(height: 4),
                            Text('\$${owe.toStringAsFixed(2)}',
                                style: textTheme.headlineMedium
                                    ?.copyWith(color: AppTheme.error)),
                          ],
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryContainerOpacity10,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: showProgress
                      ? const SizedBox(
                          height: 56,
                          child: Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('You Are Owed',
                                style: textTheme.labelSmall
                                    ?.copyWith(color: AppTheme.schemeOnSurfaceVariant(context))),
                            const SizedBox(height: 4),
                            Text('\$${owed.toStringAsFixed(2)}',
                                style: textTheme.headlineMedium
                                    ?.copyWith(color: AppTheme.primary)),
                          ],
                        ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const WalletScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryContainer,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: Text('Settle Balances',
                style: textTheme.labelMedium?.copyWith(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _nextChoreShell(
    BuildContext context,
    TextTheme textTheme, {
    required String title,
    required String subtitle,
    required String progressText,
    required double progress,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.primaryContainerOpacity20),
        boxShadow: const [
          BoxShadow(
            color: AppTheme.primaryContainerOpacity8,
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'NEXT CHORE',
                style: textTheme.labelSmall?.copyWith(
                  color: AppTheme.primary,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Icon(Icons.assignment_turned_in, color: AppTheme.primary, size: 20),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.secondaryContainerOpacity20,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.delete_sweep, color: AppTheme.secondary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
                    Text(
                      subtitle,
                      style: textTheme.bodyMedium?.copyWith(
                          color: AppTheme.schemeOnSurfaceVariant(context)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            height: 8,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppTheme.schemeContainerHighest(context),
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.primaryContainer,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              progressText,
              style: textTheme.labelSmall?.copyWith(color: AppTheme.schemeOnSurfaceVariant(context)),
            ),
          ),
        ],
      ),
    );
  }

  String _dueText(DateTime? dueAt) {
    if (dueAt == null) return 'No due date';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dueDay = DateTime(dueAt.year, dueAt.month, dueAt.day);
    final diffDays = dueDay.difference(today).inDays;

    final hh = dueAt.hour.toString().padLeft(2, '0');
    final mm = dueAt.minute.toString().padLeft(2, '0');
    if (diffDays == 0) return 'Today, $hh:$mm';
    if (diffDays == 1) return 'Tomorrow, $hh:$mm';
    if (diffDays == -1) return 'Yesterday, $hh:$mm';
    return '${dueAt.year}-${dueAt.month.toString().padLeft(2, '0')}-${dueAt.day.toString().padLeft(2, '0')} $hh:$mm';
  }

  Widget _buildShoppingItem(BuildContext context, TextTheme textTheme,
      String text, bool isChecked) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(
            isChecked ? Icons.check_circle : Icons.radio_button_unchecked,
            color: isChecked
                ? AppTheme.primaryContainer
                : Theme.of(context).colorScheme.outlineVariant,
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(
            text,
            style: textTheme.bodyMedium?.copyWith(
              color: isChecked
                  ? AppTheme.schemeOnSurfaceVariant(context)
                  : AppTheme.schemeOnSurface(context),
              decoration: isChecked ? TextDecoration.lineThrough : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShoppingListCard(
      BuildContext context, TextTheme textTheme, String? houseId) {
    if (houseId == null) {
      return _shoppingCardShell(
        context,
        textTheme,
        items: const [],
        footerText: 'No house linked yet',
      );
    }

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: ShoppingService.instance.watchItems(houseId),
      builder: (ctx, snapshot) {
        final docs = snapshot.data?.docs ?? [];
        final pending = docs
            .where((d) => (d.data()['isChecked'] as bool?) != true)
            .map((d) => (d.data()['title'] as String?) ?? 'Item')
            .toList();
        final checked = docs
            .where((d) => (d.data()['isChecked'] as bool?) == true)
            .map((d) => (d.data()['title'] as String?) ?? 'Item')
            .toList();

        final rows = <_DashboardShoppingRow>[
          ...pending.take(2).map((t) => _DashboardShoppingRow(title: t, isChecked: false)),
          ...checked.take(1).map((t) => _DashboardShoppingRow(title: t, isChecked: true)),
        ];

        return _shoppingCardShell(
          ctx,
          textTheme,
          items: rows,
          footerText: pending.isEmpty
              ? 'All items are checked'
              : '${pending.length} items remaining',
        );
      },
    );
  }

  Widget _shoppingCardShell(
    BuildContext context,
    TextTheme textTheme, {
    required List<_DashboardShoppingRow> items,
    required String footerText,
  }) {
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      elevation: 2,
      shadowColor: AppTheme.primaryContainerOpacity8,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const ShoppingScreen()),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppTheme.primaryContainerOpacity20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('SHOPPING LIST',
                      style: textTheme.labelSmall?.copyWith(
                          color: AppTheme.primary,
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.bold)),
                  const Icon(Icons.shopping_bag,
                      color: AppTheme.primary, size: 20),
                ],
              ),
              const SizedBox(height: 16),
              if (items.isEmpty)
                Text('No shopping items yet.',
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppTheme.schemeOnSurfaceVariant(context),
                    )),
              ...items.map((item) {
                final idx = items.indexOf(item);
                return Column(
                  children: [
                    _buildShoppingItem(context, textTheme, item.title, item.isChecked),
                    if (idx != items.length - 1)
                      Divider(
                          height: 1,
                          color: AppTheme.schemeContainerHighest(context)),
                  ],
                );
              }),
              const SizedBox(height: 16),
              Text(footerText,
                  style:
                      textTheme.labelMedium?.copyWith(color: AppTheme.primary)),
            ],
          ),
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

class _DashboardShoppingRow {
  _DashboardShoppingRow({required this.title, required this.isChecked});
  final String title;
  final bool isChecked;
}
