import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'theme.dart';
import 'splash_screen.dart'; // Importing for BlueprintPainter reuse
import 'guest_dashboard_screen.dart';
import 'profile_screen.dart';
import 'add_expense_screen.dart';
import 'dormy_ai_screen.dart';

class GuestWalletScreen extends StatelessWidget {
  const GuestWalletScreen({super.key});

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
            child: SingleChildScrollView(
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
                            color: Colors.white,
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
                              Text('\$142.50', style: textTheme.headlineMedium),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.trending_down,
                                      color: AppTheme.secondary, size: 14),
                                  const SizedBox(width: 4),
                                  Text('3 Pending',
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
                              Text('\$86.20',
                                  style: textTheme.headlineMedium
                                      ?.copyWith(color: AppTheme.primary)),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.trending_up,
                                      color: AppTheme.primary, size: 14),
                                  const SizedBox(width: 4),
                                  Text('2 People',
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

                  // Transaction List
                  _buildTransactionItem(
                    textTheme,
                    icon: Icons.restaurant,
                    iconColor: Colors.orange.shade500,
                    iconBgColor: Colors.orange.shade50,
                    title: 'Whole Foods Groceries',
                    subtitle: 'Shared with Alex, Jamie',
                    amount: '-\$34.20',
                    date: 'TODAY',
                    isPositive: false,
                  ),
                  const SizedBox(height: 12),
                  _buildTransactionItem(
                    textTheme,
                    icon: Icons.bolt,
                    iconColor: Colors.blue.shade500,
                    iconBgColor: Colors.blue.shade50,
                    title: 'Electricity Bill',
                    subtitle: 'Paid by you',
                    amount: '+\$120.00',
                    date: 'YESTERDAY',
                    isPositive: true,
                  ),
                  const SizedBox(height: 12),
                  _buildTransactionItem(
                    textTheme,
                    icon: Icons.wifi,
                    iconColor: Colors.purple.shade500,
                    iconBgColor: Colors.purple.shade50,
                    title: 'High-Speed Wi-Fi',
                    subtitle: 'Shared with House',
                    amount: '-\$15.00',
                    date: 'MAR 12',
                    isPositive: false,
                  ),
                  const SizedBox(height: 12),
                  _buildTransactionItem(
                    textTheme,
                    icon: Icons.sanitizer,
                    iconColor: Colors.teal.shade500,
                    iconBgColor: Colors.teal.shade50,
                    title: 'Cleaning Supplies',
                    subtitle: 'Paid by Sam',
                    amount: '-\$8.50',
                    date: 'MAR 10',
                    isPositive: false,
                  ),

                  const SizedBox(height: 32),

                  // Summary Chart
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
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
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Monthly Spending Analysis',
                                style: textTheme.labelMedium
                                    ?.copyWith(color: AppTheme.schemeOnSurface(context))),
                            Text('View Report',
                                style: textTheme.labelSmall
                                    ?.copyWith(color: AppTheme.primary)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 120,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildChartBar(
                                  0.40, AppTheme.primaryContainerOpacity20),
                              _buildChartBar(
                                  0.60, AppTheme.primaryContainerOpacity20),
                              _buildChartBar(
                                  0.30, AppTheme.primaryContainerOpacity40),
                              _buildChartBar(
                                  0.80, AppTheme.primaryContainerOpacity20),
                              _buildChartBar(0.95, AppTheme.primaryContainer),
                              _buildChartBar(
                                  0.50, AppTheme.primaryContainerOpacity60),
                              _buildChartBar(
                                  0.45, AppTheme.primaryContainerOpacity30),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            'MON',
                            'TUE',
                            'WED',
                            'THU',
                            'FRI',
                            'SAT',
                            'SUN'
                          ]
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
                  heroTag: 'guest_ai_fab',
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
                  heroTag: 'guest_add_fab',
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
                              builder: (context) =>
                                  const GuestDashboardScreen()));
                    }),
                    _buildNavItem(context, Icons.account_balance_wallet,
                        'Wallet', true, () {}), // Active state
                    _buildNavItem(context, Icons.assignment_turned_in_outlined,
                        'Chores', false, () {}),
                    _buildNavItem(context, Icons.shopping_bag_outlined,
                        'Shopping', false, () {}),
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

  Widget _buildTransactionItem(TextTheme textTheme,
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.surfaceContainerHighest),
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
                    style:
                        textTheme.labelSmall?.copyWith(color: AppTheme.outline))
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
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 4),
              Text(label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: color,
                      fontSize: 10,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w500))
            ])));
  }
}
