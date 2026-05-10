import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:ui' as ui;
import 'dart:math' as math;
import 'theme.dart';
import 'splash_screen.dart';
import 'dormy_ai_screen.dart';
import 'dashboard_screen.dart';
import 'wallet_screen.dart';
import 'chores_screen.dart';
import 'shopping_screen.dart';
import 'profile_screen.dart';
import 'decision_wheel_screen.dart';
import 'mystery_chore_screen.dart';
import 'fridge_police_screen.dart';
import 'services/chore_service.dart';
import 'services/house_service.dart';

class GameCenterScreen extends StatelessWidget {
  const GameCenterScreen({super.key});

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
              automaticallyImplyLeading: false,
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(1),
                child: Container(
                  color: AppTheme.surfaceContainerHighest,
                  height: 1,
                ),
              ),
              title: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: AppTheme.surfaceContainer,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.sports_esports,
                      color: AppTheme.primary,
                      size: 18,
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
                  icon: const Icon(Icons.notifications_none, color: AppTheme.outline),
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
                final membersStream = houseId == null
                    ? null
                    : HouseService.instance.watchHouseMembers(houseId);
                final choresStream = houseId == null
                    ? null
                    : ChoreService.instance.watchPendingChores(houseId);

                return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: membersStream,
                  builder: (context, membersSnapshot) {
                    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: choresStream,
                      builder: (context, choresSnapshot) {
                        final membersCount = membersSnapshot.data?.docs.length ?? 0;
                        final pendingCount = choresSnapshot.data?.docs.length ?? 0;
                        return SingleChildScrollView(
                          padding: const EdgeInsets.only(left: 20, right: 20, top: 32, bottom: 120),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Game Center', style: textTheme.headlineLarge),
                              const SizedBox(height: 8),
                              Text(
                                houseId == null
                                    ? 'Join a house to start game challenges.'
                                    : '$membersCount players • $pendingCount pending chores',
                                style: textTheme.bodyMedium?.copyWith(color: AppTheme.onSurfaceVariant),
                              ),
                  const SizedBox(height: 32),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: const [
                        BoxShadow(
                          color: AppTheme.primaryContainerOpacity8,
                          blurRadius: 20,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          right: -24,
                          top: 10,
                          child: Transform.rotate(
                            angle: 15 * math.pi / 180,
                            child: Icon(
                              Icons.data_usage,
                              size: 140,
                              color: AppTheme.surfaceContainerHighest.withValues(alpha: 0.4),
                            ),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade50,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.casino, color: Colors.brown.shade600, size: 28),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Spin the Wheel',
                              style: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Can't decide who takes out the trash? Let fate decide.",
                              style: textTheme.bodyMedium?.copyWith(color: AppTheme.outline),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const DecisionWheelScreen()),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                elevation: 0,
                              ),
                              child: Text(
                                'Start Round',
                                style: textTheme.labelMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Mini Games', style: textTheme.headlineMedium),
                      Text('View All', style: textTheme.labelMedium?.copyWith(color: AppTheme.primary)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _miniCard(
                          context,
                          textTheme,
                          title: 'Mystery Chore',
                          subtitle: 'x2 Points ->',
                          icon: Icons.card_giftcard,
                          iconColor: Colors.purple.shade400,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const MysteryChoreScreen()),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _miniCard(
                          context,
                          textTheme,
                          title: 'Fridge Police',
                          subtitle: 'Inspect ->',
                          icon: Icons.kitchen,
                          iconColor: Colors.cyan.shade700,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const FridgePoliceScreen()),
                          ),
                        ),
                      ),
                    ],
                  ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const DormyAiScreen()),
          );
        },
        backgroundColor: AppTheme.primary,
        elevation: 4,
        child: const Icon(Icons.smart_toy, color: Colors.white, size: 28),
      ),
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.frostedBottomBarBg(context),
              border: Border(
                top: BorderSide(
                    color: AppTheme.schemeContainerHighest(context)),
              ),
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
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(context, Icons.grid_view, 'Dashboard', false, () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const DashboardScreen()),
                      );
                    }),
                    _buildNavItem(
                      context,
                      Icons.account_balance_wallet_outlined,
                      'Wallet',
                      false,
                      () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const WalletScreen()),
                        );
                      },
                    ),
                    _buildNavItem(
                      context,
                      Icons.assignment_turned_in_outlined,
                      'Chores',
                      false,
                      () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const ChoresScreen()),
                        );
                      },
                    ),
                    _buildNavItem(
                      context,
                      Icons.shopping_bag_outlined,
                      'Shopping',
                      false,
                      () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const ShoppingScreen()),
                        );
                      },
                    ),
                    _buildNavItem(
                      context,
                      Icons.sports_esports,
                      'Game',
                      true,
                      () {},
                    ),
                    _buildNavItem(
                      context,
                      Icons.person_outline,
                      'Profile',
                      false,
                      () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const ProfileScreen()),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    IconData icon,
    String label,
    bool isActive,
    VoidCallback onTap,
  ) {
    final color = isActive ? AppTheme.primary : AppTheme.outline;
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

  Widget _miniCard(
    BuildContext context,
    TextTheme textTheme, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: AppTheme.primaryContainerOpacity8,
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: iconColor, size: 28),
                const SizedBox(height: 16),
                Text(title, style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
