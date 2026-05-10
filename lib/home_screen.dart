import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'theme.dart';
import 'splash_screen.dart'; // Importing for BlueprintPainter reuse
import 'dashboard_screen.dart';
import 'create_house_screen.dart';
import 'wallet_screen.dart';
import 'chores_screen.dart';
import 'shopping_screen.dart';
import 'profile_screen.dart';
import 'auth_gate.dart';
import 'services/auth_service.dart';
import 'services/house_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _inviteCodeController = TextEditingController();
  bool _isJoining = false;

  Future<void> _joinHouse() async {
    final code = _inviteCodeController.text.trim();
    if (code.isEmpty) {
      _showMessage('Please enter invite code.');
      return;
    }
    setState(() => _isJoining = true);
    try {
      await HouseService.instance.joinHouseByInviteCode(code);
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const DashboardScreen()),
        (route) => false,
      );
    } catch (e) {
      _showMessage(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isJoining = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    _inviteCodeController.dispose();
    super.dispose();
  }

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
                      border:
                          Border.all(color: AppTheme.primaryContainerOpacity20),
                      image: const DecorationImage(
                        image: NetworkImage(
                            'https://lh3.googleusercontent.com/aida-public/AB6AXuBD0PvCI6BImJNAkld0H3DJr9oLrn66hvlXGnSfxJENDuv7b7-WZ7LSovOGA1vrm15kYEyGwmCdirTHjsQSM_ld0nvbWVmTOaxjnEIvRYfYV-aZb65ZzPDxdiiWhPy3l4005rztVRRfTAme3kDF8_9LoIAEUkDR7v_dVM5rAzLxV6FMiwaHzJuTh9vO7B5BktFwOwjylc2250eX0OAiM9ROvJWmKXUD5YHe3z099jmUbTgxbvxt2BvXgknAp9NILEtdq_6NuWACnTA'),
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
                IconButton(
                  icon: const Icon(Icons.logout, color: AppTheme.outline),
                  onPressed: () async {
                    await AuthService.instance.signOut();
                    if (!context.mounted) return;
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const AuthGate()),
                      (route) => false,
                    );
                  },
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
                  left: 20,
                  right: 20,
                  top: 32,
                  bottom: 120), // Bottom padding accommodates nav bar
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Text('Welcome Home', style: textTheme.headlineLarge),
                  const SizedBox(height: 8),
                  Text(
                    "Let's get your living space organized. Start by creating a new house or joining an existing one.",
                    style: textTheme.bodyMedium
                        ?.copyWith(color: AppTheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 32),

                  // Create New House Card
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border:
                          Border.all(color: AppTheme.primaryContainerOpacity20),
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
                        borderRadius: BorderRadius.circular(24),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const CreateHouseScreen()),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryContainerOpacity12,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                alignment: Alignment.center,
                                child: const Icon(Icons.add_home,
                                    color: AppTheme.primary, size: 32),
                              ),
                              const SizedBox(height: 16),
                              Text('Create New House',
                                  style: textTheme.headlineMedium),
                              const SizedBox(height: 4),
                              Text(
                                'Be the admin, invite your roommates, and set up the chore schedule.',
                                style: textTheme.bodyMedium?.copyWith(
                                    color: AppTheme.onSurfaceVariant),
                              ),
                              const SizedBox(height: 16),
                              Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: IgnorePointer(
                                      child: Image.network(
                                        'https://lh3.googleusercontent.com/aida-public/AB6AXuCYuskMc-cqOHIPZHjPDlPRc9D6pgiiiWCaRofU7D5T1PALnxTGlIPvqVTcrGUMGvCKJIZrw1O3UUIkA9hxytXX5tjrkUx_YvPu0p7Ax-_mGZFuqP6N9gzm1sfvUj0kLJ4MWbzJ530zSt6dkM9Qv_aMkOSp5bWg8M0wyXg52bXZWtVqXfn0v1EXmwEJwq4pDpQWwrgYcMO_oVi3yPFlW4f91fHG_yxYlbo1MrGfYwV1BWtr6zYr4qP09pK8b6HZ_eTcBSU62p6RTZQ',
                                        height: 160,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        color: Colors.black.withOpacity(0.1),
                                        colorBlendMode: BlendMode.darken,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 12,
                                    right: 12,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const CreateHouseScreen()),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            AppTheme.primaryContainer,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(9999)),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 24, vertical: 12),
                                        elevation: 4,
                                        shadowColor:
                                            AppTheme.primaryContainerOpacity40,
                                      ),
                                      child: Text('Get Started',
                                          style: textTheme.labelMedium
                                              ?.copyWith(color: Colors.white)),
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

                  const SizedBox(height: 32),

                  // Join Existing House Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border:
                          Border.all(color: AppTheme.primaryContainerOpacity20),
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
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: AppTheme.secondaryOpacity10,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              alignment: Alignment.center,
                              child: const Icon(Icons.group_add,
                                  color: AppTheme.secondary),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Join Existing House',
                                      style: textTheme.headlineMedium),
                                  Text('REQUIRES INVITE CODE',
                                      style: textTheme.labelSmall?.copyWith(
                                          letterSpacing: 1.0,
                                          color: AppTheme.outline)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.only(left: 4, bottom: 8),
                          child: Text('Invite Code',
                              style: textTheme.labelMedium
                                  ?.copyWith(color: AppTheme.onSurfaceVariant)),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _inviteCodeController,
                                  decoration: InputDecoration(
                                    hintText: 'DORM-XXXX-XXXX',
                                    hintStyle: textTheme.bodyMedium?.copyWith(
                                        color:
                                            AppTheme.outline.withOpacity(0.5)),
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 16),
                                  ),
                                  style: textTheme.bodyLarge?.copyWith(
                                      fontFamily: 'monospace',
                                      letterSpacing: 2.0),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: InkWell(
                                  onTap: () {},
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    alignment: Alignment.center,
                                    child: const Icon(Icons.qr_code_scanner,
                                        color: AppTheme.primary),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _isJoining ? null : _joinHouse,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.onSurface,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 56),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            elevation: 2,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(_isJoining ? 'Joining...' : 'Join House',
                                  style: textTheme.labelMedium
                                      ?.copyWith(color: Colors.white)),
                              const SizedBox(width: 8),
                              const Icon(Icons.arrow_forward, size: 16),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Divider(color: AppTheme.surfaceContainerHighest),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            SizedBox(
                              width: 72,
                              height: 32,
                              child: Stack(
                                children: [
                                  const Positioned(
                                    left: 0,
                                    child: CircleAvatar(
                                        radius: 16,
                                        backgroundColor: Colors.white,
                                        child: CircleAvatar(
                                            radius: 14,
                                            backgroundImage: NetworkImage(
                                                'https://lh3.googleusercontent.com/aida-public/AB6AXuAUusH5hfWKLX4nfDYS6rAQQZ-NNILIKh_pfNS54G7NPCqf5wkv4O44XLjPAYQ6ncjQLGBWE0P69625umqsB4pIIrivlPxnhqvPe9LDahmAkFgrGNlKsv2d4LNyGpGsjbtWqGNLUjvJYYZ-lZGP197Bk3reiZVcPo0e0nhYo9okkNZpZna2TWc7kWZ3RlDf2_4ccseQ3INnZpwDdTAlkgz0UAmhnogzi8KAkYWrb_auuZsYCqmLcBV-81HzhuQqs9k6mkQIKFBBptI'))),
                                  ),
                                  const Positioned(
                                    left: 20,
                                    child: CircleAvatar(
                                        radius: 16,
                                        backgroundColor: Colors.white,
                                        child: CircleAvatar(
                                            radius: 14,
                                            backgroundImage: NetworkImage(
                                                'https://lh3.googleusercontent.com/aida-public/AB6AXuARLAh5qZ-GL7Yeto1GzUuEP9jLkFmWDfQn5SGd9IG5OO-J5SS2EqDgZIYWvWqPQaGRMMtRxcEVEFAUij-YkeAQU77_MoOrBtMgFQqPii5TipXWiUbOfTI1lUSkwmvViec-9CQO1W0I6tGHULNtVX9rg7Q5XPKpxdQLhxBWXPom6mR68f-ZMBUHHGfRfHfkviuw9BViV6MXdjTobDqIr0bb_nfRkpWZUcdDKtV-r-pBmVwUABKO1AF8tsXJ8ddonpmmqUhFc3h2cxA'))),
                                  ),
                                  const Positioned(
                                    left: 40,
                                    child: CircleAvatar(
                                        radius: 16,
                                        backgroundColor: Colors.white,
                                        child: CircleAvatar(
                                            radius: 14,
                                            backgroundImage: NetworkImage(
                                                'https://lh3.googleusercontent.com/aida-public/AB6AXuBcKmvD48fwqLQDjbpcAGYsVs-Opb16JKg2um7kDlGjxioGOhbuVxJYYVw_-hkGx-9EtYbW4vgtzS5XneUeAU0y_MOIbkpo8ybisG1Ea8ERWtfcXN6fu4HAxcjO_y0syKdwf6oz3WN1YlJLyA5Ly8IV5gZsjnpF5siUtz7blc5223UrUGwWXIBeK7McsmxYhBjFfp1oV4BQ3Ma1QCfCqJ9OK71QHbYelT5ZgiMHmKVdJ3KT3Qq8U3DJkmr26dNlD_c6yMx5EK3rJHk'))),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text('Join 12,000+ active dorms',
                                style: textTheme.labelSmall
                                    ?.copyWith(color: AppTheme.outline)),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Secondary Helper Cards
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceContainerLow,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.auto_awesome,
                                  color: AppTheme.primary),
                              const SizedBox(height: 8),
                              Text('Dormy AI',
                                  style: textTheme.labelMedium?.copyWith(
                                      color: AppTheme.schemeOnSurface(context))),
                              const SizedBox(height: 4),
                              Text(
                                  'Need help deciding? Ask our AI co-pilot about setup tips.',
                                  style: textTheme.bodyMedium?.copyWith(
                                      fontSize: 11,
                                      height: 1.2,
                                      color: AppTheme.schemeOnSurfaceVariant(
                                          context))),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceContainerLow,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.menu_book,
                                  color: AppTheme.primary),
                              const SizedBox(height: 8),
                              Text('House Rules',
                                  style: textTheme.labelMedium?.copyWith(
                                      color: AppTheme.schemeOnSurface(context))),
                              const SizedBox(height: 4),
                              Text(
                                  'Explore our library of shared house templates.',
                                  style: textTheme.bodyMedium?.copyWith(
                                      fontSize: 11,
                                      height: 1.2,
                                      color: AppTheme.schemeOnSurfaceVariant(
                                          context))),
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
                      context,
                      Icons.grid_view,
                      'Dashboard',
                      true,
                      () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const DashboardScreen(),
                          ),
                        );
                      },
                    ),
                    _buildNavItem(
                      context,
                      Icons.account_balance_wallet_outlined,
                      'Wallet',
                      false,
                      () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const WalletScreen(),
                          ),
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
                          MaterialPageRoute(
                            builder: (context) => const ChoresScreen(),
                          ),
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
                          MaterialPageRoute(
                            builder: (context) => const ShoppingScreen(),
                          ),
                        );
                      },
                    ),
                    _buildNavItem(
                      context,
                      Icons.person_outline,
                      'Profile',
                      false,
                      () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ProfileScreen(),
                          ),
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

  Widget _buildNavItem(BuildContext context, IconData icon, String label,
      bool isActive, VoidCallback onTap) {
    final color = isActive ? AppTheme.primary : AppTheme.outline;
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: color,
                    fontSize: 10,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
