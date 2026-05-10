import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'theme.dart';
import 'splash_screen.dart'; // Importing for BlueprintPainter reuse
import 'dashboard_screen.dart';
import 'chores_screen.dart';
import 'profile_screen.dart';
import 'shopping_screen.dart';
import 'game_center_screen.dart';
import 'add_expense_screen.dart';
import 'dormy_ai_screen.dart';
import 'services/auth_service.dart';
import 'services/expense_service.dart';
import 'services/house_service.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: AppBar(
              backgroundColor:
                  Theme.of(context).colorScheme.surface.withValues(alpha: 0.88),
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
                final userId = AuthService.instance.currentUser?.uid;
                final houseId = userSnapshot.data?.data()?['houseId'] as String?;
                if (houseId == null || userId == null) {
                  return const Center(child: Text('Join a house to use wallet.'));
                }
                return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: ExpenseService.instance.watchExpenses(houseId),
                  builder: (context, expenseSnapshot) {
                    if (expenseSnapshot.hasError) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            'Could not load Wallet expenses (${expenseSnapshot.error})',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    }
                    if (!expenseSnapshot.hasData &&
                        expenseSnapshot.connectionState ==
                            ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final docs = expenseSnapshot.data?.docs ?? [];
                    final summary = ExpenseService.instance.summarizeOutstandingForUser(
                      userId: userId,
                      expenses: docs.map((d) => d.data()),
                    );
                    final weekData = ExpenseService.lastSevenDaysSpending(
                      docs.map((d) => d.data()),
                    );
                    final weekTotals = weekData.totals;
                    final weekLabels = weekData.labels;
                    final maxDay = weekTotals.fold<double>(
                      0,
                      (m, e) => e > m ? e : m,
                    );
                    final monthHouseTotal = ExpenseService.monthToDateHouseTotal(
                      docs.map((d) => d.data()),
                    );

                    return SingleChildScrollView(
              padding: const EdgeInsets.only(
                  left: 20, right: 20, top: 32, bottom: 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Summary Cards (Asymmetric Layout)
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceContainerLowest,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: AppTheme.primaryContainerOpacity20),
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
                              Text('YOU OWE',
                                  style: textTheme.labelSmall?.copyWith(
                                      color: AppTheme.secondary,
                                      letterSpacing: 1.5,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text('\$${summary.owe.toStringAsFixed(2)}', style: textTheme.headlineMedium),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.trending_down,
                                      color: AppTheme.secondary, size: 14),
                                  const SizedBox(width: 4),
                                  Text('${summary.oweToPeople} People',
                                      style: textTheme.labelSmall?.copyWith(
                                          color: AppTheme.secondary)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryContainerOpacity10,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: AppTheme.primaryContainerOpacity20),
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
                              Text('YOU ARE OWED',
                                  style: textTheme.labelSmall?.copyWith(
                                      color: AppTheme.primary,
                                      letterSpacing: 1.5,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text('\$${summary.owed.toStringAsFixed(2)}',
                                  style: textTheme.headlineMedium
                                      ?.copyWith(color: AppTheme.primary)),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.trending_up,
                                      color: AppTheme.primary, size: 14),
                                  const SizedBox(width: 4),
                                  Text('${summary.owedFromPeople} People',
                                      style: textTheme.labelSmall
                                          ?.copyWith(color: AppTheme.primary)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Ledger Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Recent Transactions',
                          style: textTheme.headlineMedium),
                      InkWell(
                        onTap: () {},
                        child: Row(
                          children: [
                            Text('Filter',
                                style: textTheme.labelMedium
                                    ?.copyWith(color: AppTheme.primary)),
                            const SizedBox(width: 4),
                            const Icon(Icons.filter_list,
                                color: AppTheme.primary, size: 18),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  ...docs.take(8).map((doc) {
                    final data = doc.data();
                    final paidBy = ExpenseService.payerUserId(data['paidBy']);
                    final amount = (data['amount'] as num?)?.toDouble() ?? 0;
                    final settledBy = ExpenseService.instance.settledUserIds(data);
                    final userShare =
                        ExpenseService.instance.shareAmountForUser(data, userId);
                    final isPositive = paidBy != null && paidBy == userId;
                    final isSettledForMe = settledBy.contains(userId);
                    final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
                    final date = createdAt == null
                        ? 'NOW'
                        : '${createdAt.year}-${createdAt.month.toString().padLeft(2, '0')}-${createdAt.day.toString().padLeft(2, '0')}';
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildTransactionItem(
                        context,
                        textTheme,
                        icon: Icons.receipt_long,
                        iconColor: isPositive ? Colors.green.shade600 : Colors.orange.shade500,
                        iconBgColor: isPositive ? Colors.green.shade50 : Colors.orange.shade50,
                        title: (data['description'] as String?) ?? 'Expense',
                        subtitle:
                            'Paid by ${(data['paidByName'] as String?) ?? 'Unknown'} • Your share \$${userShare.toStringAsFixed(2)}${isSettledForMe ? ' • Settled' : ''}',
                        amount: '${isPositive ? '+' : '-'}\$${amount.toStringAsFixed(2)}',
                        date: date,
                        isPositive: isPositive,
                      ),
                    );
                  }),

                  const SizedBox(height: 32),

                  // Last 7 days — real totals from expenses
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(16),
                      border:
                          Border.all(color: AppTheme.surfaceContainerHighest),
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
                        Text(
                          'Monthly Spending Analysis',
                          style: textTheme.labelMedium?.copyWith(
                              color: AppTheme.schemeOnSurface(context)),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Last 7 days (house) • Month-to-date \$${monthHouseTotal.toStringAsFixed(2)}',
                          style: textTheme.labelSmall?.copyWith(
                            color: AppTheme.schemeOnSurfaceVariant(context),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 120,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: List.generate(7, (i) {
                              final t = weekTotals[i];
                              double frac;
                              if (maxDay <= 0) {
                                frac = 0.08;
                              } else if (t <= 0) {
                                frac = 0.1;
                              } else {
                                frac = (t / maxDay).clamp(0.15, 1.0);
                              }
                              final isPeak =
                                  maxDay > 0 && t > 0 && t >= maxDay;
                              final color = isPeak
                                  ? AppTheme.primaryContainer
                                  : (t > 0
                                      ? AppTheme.primaryContainerOpacity60
                                      : AppTheme.primaryContainerOpacity20);
                              return _buildChartBar(frac, color);
                            }),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: weekLabels
                              .map((day) => Expanded(
                                    child: Text(day,
                                        textAlign: TextAlign.center,
                                        style: textTheme.labelSmall?.copyWith(
                                            color: AppTheme.outlineVariant,
                                            fontSize: 10)),
                                  ))
                              .toList(),
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

          // Stacked FABs
          Positioned(
            bottom: 100, // Above bottom nav
            right: 24,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton(
                  heroTag: 'ai_fab',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const DormyAiScreen()),
                    );
                  },
                  backgroundColor: Colors.white,
                  mini: true,
                  elevation: 2,
                  shape: const CircleBorder(
                      side:
                          BorderSide(color: AppTheme.surfaceContainerHighest)),
                  child: const Icon(Icons.smart_toy,
                      color: AppTheme.primary, size: 20),
                ),
                const SizedBox(height: 12),
                FloatingActionButton(
                  heroTag: 'add_fab',
                  onPressed: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        opaque: false,
                        pageBuilder: (context, _, __) =>
                            const AddExpenseScreen(),
                      ),
                    );
                  },
                  backgroundColor: AppTheme.primaryContainer,
                  elevation: 4,
                  child: const Icon(Icons.add, color: Colors.white, size: 32),
                ),
              ],
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
                    _buildNavItem(context, Icons.account_balance_wallet,
                        'Wallet', true, () {}), // Active state
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

  Widget _buildTransactionItem(BuildContext context, TextTheme textTheme,
      {required IconData icon,
      required Color iconColor,
      required Color iconBgColor,
      required String title,
      required String subtitle,
      required String amount,
      required String date,
      required bool isPositive}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground(context),
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: AppTheme.schemeContainerHighest(context)),
        boxShadow: const [
          BoxShadow(
              color: Color(0x08000000), blurRadius: 12, offset: Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          Container(
              width: 48,
              height: 48,
              decoration:
                  BoxDecoration(color: iconBgColor, shape: BoxShape.circle),
              child: Icon(icon, color: iconColor)),
          const SizedBox(width: 16),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(title,
                    style: textTheme.bodyLarge
                        ?.copyWith(fontWeight: FontWeight.w600)),
                Text(subtitle,
                    style: textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.outline))
              ])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(amount,
                style: textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isPositive ? AppTheme.primary : AppTheme.secondary)),
            Text(date,
                style: textTheme.labelSmall
                    ?.copyWith(color: AppTheme.outlineVariant, fontSize: 10))
          ]),
          const SizedBox(width: 12),
          const Icon(Icons.chevron_right,
              color: AppTheme.outlineVariant, size: 20),
        ],
      ),
    );
  }

  Widget _buildChartBar(double heightFactor, Color color) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: FractionallySizedBox(
            heightFactor: heightFactor,
            child: Container(
                decoration: BoxDecoration(
                    color: color,
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(8))))),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, IconData icon, String label,
      bool isActive, VoidCallback onTap) {
    final color = isActive ? AppTheme.primary : AppTheme.outline;
    return InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 6.0, vertical: 8.0),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(height: 4),
              Text(label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: color,
                      fontSize: 9,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w500))
            ])));
  }
}
