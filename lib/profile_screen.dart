import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'theme.dart';
import 'splash_screen.dart';
import 'dashboard_screen.dart';
import 'wallet_screen.dart';
import 'chores_screen.dart';
import 'shopping_screen.dart';
import 'game_center_screen.dart';
import 'house_settings_screen.dart';
import 'payment_methods_screen.dart';
import 'security_privacy_screen.dart';
import 'dormy_ai_screen.dart';
import 'notifications_screen.dart';
import 'auth_gate.dart';
import 'login_screen.dart';
import 'services/auth_service.dart';
import 'services/house_service.dart';
import 'services/expense_service.dart';
import 'services/chore_service.dart';
import 'theme_controller.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    await AuthService.instance.signOut();
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const AuthGate()),
      (_) => false,
    );
  }

  Future<void> _editName(BuildContext context, String currentName) async {
    final controller = TextEditingController(text: currentName);
    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit name'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Full name'),
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (saved != true || !context.mounted) return;
    final name = controller.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name cannot be empty.')),
      );
      return;
    }
    try {
      await AuthService.instance.updateFullName(name);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated.')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    }
  }

  int _myChoreCompletions(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
    String userId,
  ) {
    var n = 0;
    for (final doc in docs) {
      final done = List<String>.from(doc.data()['completedByUserIds'] ?? []);
      if (done.contains(userId)) n++;
    }
    return n;
  }

  int _expensesIPaidFor(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
    String userId,
  ) {
    var n = 0;
    for (final doc in docs) {
      final payer = ExpenseService.payerUserId(doc.data()['paidBy']);
      if (payer == userId) n++;
    }
    return n;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final authUser = AuthService.instance.currentUser;

    if (authUser == null) {
      return Scaffold(
        body: Center(
          child: TextButton(
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
            child: const Text('Sign in'),
          ),
        ),
      );
    }

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
              automaticallyImplyLeading: false,
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
                      color: AppTheme.surfaceContainer,
                      border: Border.all(
                          color: AppTheme.primaryContainerOpacity20, width: 1),
                      image: const DecorationImage(
                        image: NetworkImage(
                            'https://lh3.googleusercontent.com/aida-public/AB6AXuDwqduKxMf-WDoauWTTZTxp-j1LNhFq62bk6gPiM3OUWuf9lsqy08Jgt8sCwv3ZTxPJc8-U0CRqCYWi-BuDncsV2Y1Rr5rDjU0eS1HuNAy3yg5wKDupyrTosT7x_cfQwdkjuq72yfLqfXeKlUHV1K2hnpuE-xHPuTUqkMvG6H9eXqHuOOtIQEd4O3tV59V8WEMmwixdYUndBPfQHaDhckBAmZtFt20F0w3mXIZJwyYcFTI9ma0YirYNdM2ZS3pbmQY6kfnLFju0HQU'),
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
                  icon: const Icon(Icons.settings, color: AppTheme.primary),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const HouseSettingsScreen()),
                    );
                  },
                ),
                IconButton(
                  icon:
                      const Icon(Icons.notifications, color: AppTheme.primary),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const NotificationsScreen()),
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
          Positioned.fill(
            child: CustomPaint(
              painter: BlueprintPainter(brightness: Theme.of(context).brightness),
            ),
          ),
          SafeArea(
            bottom: false,
            child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: HouseService.instance.watchCurrentUserProfile(),
              builder: (context, userSnap) {
                final data = userSnap.data?.data();
                final houseId = data?['houseId'] as String?;
                final fullName = (data?['fullName'] as String?) ??
                    authUser.displayName ??
                    'Roommate';
                final email =
                    (data?['email'] as String?) ?? authUser.email ?? '';

                return SingleChildScrollView(
                  padding: const EdgeInsets.only(
                      left: 20, right: 20, top: 32, bottom: 120),
                  child: Column(
                    children: [
                      _buildHeroCard(
                        context,
                        textTheme,
                        fullName: fullName,
                        email: email,
                        houseId: houseId,
                        role: data?['role'] as String?,
                        authUser: authUser,
                        onEditName: () => _editName(context, fullName),
                      ),
                      const SizedBox(height: 24),
                      _buildBalanceCard(textTheme, houseId, authUser.uid),
                      const SizedBox(height: 16),
                      _buildStatsRow(context, textTheme, houseId, authUser.uid),
                      const SizedBox(height: 24),
                      Container(
                        decoration: BoxDecoration(
                          color: AppTheme.cardBackground(context),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            BoxShadow(
                              color: AppTheme.primaryContainerOpacity8,
                              blurRadius: 20,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          children: [
                            _buildMenuRow(
                              context,
                              Icons.person_outline,
                              'Edit profile',
                              false,
                              onTap: () => _editName(context, fullName),
                            ),
                            Divider(
                                height: 1,
                                color: AppTheme.schemeContainerHighest(context)),
                            _buildMenuRow(
                              context,
                              Icons.notifications,
                              'Notifications',
                              false,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const NotificationsScreen()),
                                );
                              },
                            ),
                            Divider(
                                height: 1,
                                color: AppTheme.schemeContainerHighest(context)),
                            _buildMenuRow(
                              context,
                              Icons.payments,
                              'Payment methods',
                              false,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const PaymentMethodsScreen(),
                                  ),
                                );
                              },
                            ),
                            Divider(
                                height: 1,
                                color: AppTheme.schemeContainerHighest(context)),
                            _buildMenuRow(
                              context,
                              Icons.security,
                              'Security & privacy',
                              false,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const SecurityPrivacyScreen(),
                                  ),
                                );
                              },
                            ),
                            Divider(
                                height: 1,
                                color: AppTheme.schemeContainerHighest(context)),
                            Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(16, 12, 16, 12),
                              child: ListenableBuilder(
                                listenable: ThemeController.instance,
                                builder: (context, _) {
                                  final mode =
                                      ThemeController.instance.themeMode;
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Appearance',
                                        style: textTheme.labelSmall?.copyWith(
                                          color: AppTheme.onSurfaceVariant,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      SegmentedButton<ThemeMode>(
                                        segments: const [
                                          ButtonSegment(
                                            value: ThemeMode.system,
                                            label: Text('Auto'),
                                            icon: Icon(Icons.brightness_auto,
                                                size: 18),
                                          ),
                                          ButtonSegment(
                                            value: ThemeMode.light,
                                            label: Text('Light'),
                                            icon: Icon(Icons.light_mode,
                                                size: 18),
                                          ),
                                          ButtonSegment(
                                            value: ThemeMode.dark,
                                            label: Text('Dark'),
                                            icon: Icon(Icons.dark_mode,
                                                size: 18),
                                          ),
                                        ],
                                        selected: {mode},
                                        onSelectionChanged:
                                            (Set<ThemeMode> next) {
                                          ThemeController.instance
                                              .setThemeMode(next.first);
                                        },
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                            Divider(
                                height: 1,
                                color: AppTheme.schemeContainerHighest(context)),
                            _buildMenuRow(
                              context,
                              Icons.logout,
                              'Logout',
                              true,
                              onTap: () => _logout(context),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Positioned(
            bottom: 100,
            right: 24,
            child: FloatingActionButton(
              heroTag: 'profile_ai_fab',
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
                    _buildNavItem(context, Icons.assignment_turned_in_outlined,
                        'Chores', false, () {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ChoresScreen()));
                    }),
                    _buildNavItem(context, Icons.shopping_bag_outlined,
                        'Shopping', false, () {
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
                    _buildNavItem(context, Icons.person, 'Profile', true, () {}),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroCard(
    BuildContext context,
    TextTheme textTheme, {
    required String fullName,
    required String email,
    required String? houseId,
    required String? role,
    required User authUser,
    required VoidCallback onEditName,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground(context),
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
        alignment: Alignment.center,
        children: [
          Positioned(
            top: -16,
            right: -16,
            child: Icon(
              Icons.home,
              size: 100,
              color: AppTheme.schemeContainerHighest(context)
                  .withValues(alpha: 0.35),
            ),
          ),
          Column(
            children: [
              CircleAvatar(
                radius: 56,
                backgroundColor: AppTheme.primaryContainerOpacity10,
                foregroundColor: AppTheme.primary,
                backgroundImage: authUser.photoURL != null
                    ? NetworkImage(authUser.photoURL!)
                    : null,
                child: authUser.photoURL == null
                    ? Text(
                        fullName.isNotEmpty
                            ? fullName[0].toUpperCase()
                            : '?',
                        style: textTheme.headlineLarge?.copyWith(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      )
                    : null,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      fullName,
                      style: textTheme.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 20),
                    color: AppTheme.primary,
                    onPressed: onEditName,
                    tooltip: 'Edit name',
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                email,
                style: textTheme.bodyMedium
                    ?.copyWith(color: AppTheme.schemeOnSurfaceVariant(context)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              if (houseId == null || houseId.isEmpty)
                Text(
                  'Not in a house yet — create or join from Home.',
                  style: textTheme.bodySmall
                      ?.copyWith(color: AppTheme.schemeOnSurfaceVariant(context)),
                  textAlign: TextAlign.center,
                )
              else
                StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                  stream: HouseService.instance.watchHouseById(houseId),
                  builder: (ctx, houseSnap) {
                    final houseName =
                        houseSnap.data?.data()?['name'] as String? ?? 'House';
                    final roleLabel = role?.isNotEmpty == true ? role! : null;
                    return Text(
                      '$houseName${roleLabel != null ? ' • $roleLabel' : ''}',
                      style: textTheme.bodyMedium
                          ?.copyWith(color: AppTheme.schemeOnSurfaceVariant(ctx)),
                      textAlign: TextAlign.center,
                    );
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard(
    TextTheme textTheme,
    String? houseId,
    String userId,
  ) {
    if (houseId == null || houseId.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.primaryContainerOpacity10,
          borderRadius: BorderRadius.circular(16),
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
            Expanded(
              child: Text(
                'Join a house to see your net balance with roommates.',
                style: textTheme.bodyMedium
                    ?.copyWith(color: AppTheme.onPrimaryContainer),
              ),
            ),
            const Icon(Icons.account_balance_wallet,
                color: AppTheme.primaryContainer, size: 28),
          ],
        ),
      );
    }

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: ExpenseService.instance.watchExpenses(houseId),
      builder: (context, snap) {
        if (snap.hasError) {
          return _balanceShell(
            textTheme,
            title: 'NET BALANCE',
            amountText: '—',
            subtitle: 'Could not load expenses',
          );
        }
        final docs = snap.data?.docs ?? [];
        final summary = ExpenseService.instance.summarizeOutstandingForUser(
          userId: userId,
          expenses: docs.map((d) => d.data()),
        );
        final net = summary.owed - summary.owe;
        final amountText = net == 0
            ? '\$0.00'
            : net > 0
                ? '+\$${net.toStringAsFixed(2)}'
                : '-\$${net.abs().toStringAsFixed(2)}';
        return _balanceShell(
          textTheme,
          title: 'NET BALANCE',
          amountText: amountText,
          subtitle: 'Owed to you − You owe (unsettled)',
        );
      },
    );
  }

  Widget _balanceShell(
    TextTheme textTheme, {
    required String title,
    required String amountText,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryContainerOpacity10,
        borderRadius: BorderRadius.circular(16),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: textTheme.labelSmall?.copyWith(
                        color: AppTheme.onPrimaryContainer,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(amountText,
                    style: textTheme.headlineMedium
                        ?.copyWith(color: AppTheme.onPrimaryContainer)),
                const SizedBox(height: 4),
                Text(subtitle,
                    style: textTheme.labelSmall
                        ?.copyWith(color: AppTheme.onPrimaryContainer)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.account_balance_wallet,
                color: Colors.white, size: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(
    BuildContext context,
    TextTheme textTheme,
    String? houseId,
    String userId,
  ) {
    if (houseId == null || houseId.isEmpty) {
      return Row(
        children: [
          _buildStatCard(
            context,
            textTheme,
            icon: Icons.assignment_turned_in,
            iconColor: AppTheme.secondary,
            title: 'Chores',
            value: '0',
            subtitle: 'Your completions',
          ),
          const SizedBox(width: 16),
          _buildStatCard(
            context,
            textTheme,
            icon: Icons.receipt_long,
            iconColor: AppTheme.primary,
            title: 'Expenses',
            value: '0',
            subtitle: 'You paid for',
            iconSolid: true,
          ),
        ],
      );
    }

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: ChoreService.instance.watchAllChores(houseId),
      builder: (context, choreSnap) {
        final choreDocs = choreSnap.data?.docs ?? [];
        final choreCount = _myChoreCompletions(choreDocs, userId);

        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: ExpenseService.instance.watchExpenses(houseId),
          builder: (context, expSnap) {
            final expDocs = expSnap.data?.docs ?? [];
            final paidCount = _expensesIPaidFor(expDocs, userId);

            return Row(
              children: [
                _buildStatCard(
                  context,
                  textTheme,
                  icon: Icons.assignment_turned_in,
                  iconColor: AppTheme.secondary,
                  title: 'Chores',
                  value: '$choreCount',
                  subtitle: 'Your completions',
                ),
                const SizedBox(width: 16),
                _buildStatCard(
                  context,
                  textTheme,
                  icon: Icons.receipt_long,
                  iconColor: AppTheme.primary,
                  title: 'Expenses',
                  value: '$paidCount',
                  subtitle: 'You paid for',
                  iconSolid: true,
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    TextTheme textTheme, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required String subtitle,
    bool iconSolid = false,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.cardBackground(context),
          borderRadius: BorderRadius.circular(16),
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
                Icon(icon, color: iconColor, size: 20),
                const SizedBox(width: 8),
                Text(title,
                    style: textTheme.labelMedium?.copyWith(color: iconColor)),
              ],
            ),
            const SizedBox(height: 12),
            Text(value, style: textTheme.headlineMedium),
            const SizedBox(height: 2),
            Text(subtitle,
                style: textTheme.labelSmall
                    ?.copyWith(color: Theme.of(context).colorScheme.outline)),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuRow(
    BuildContext context,
    IconData icon,
    String title,
    bool isDestructive, {
    VoidCallback? onTap,
  }) {
    final color = isDestructive ? AppTheme.error : AppTheme.onSurfaceVariant;
    final bgColor =
        isDestructive ? AppTheme.errorContainer : AppTheme.surfaceContainerHigh;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(title,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color:
                          isDestructive ? AppTheme.error : AppTheme.onSurface,
                      fontSize: 14)),
            ),
            Icon(Icons.chevron_right,
                color: isDestructive
                    ? AppTheme.error.withOpacity(0.5)
                    : AppTheme.outlineVariant,
                size: 20),
          ],
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
