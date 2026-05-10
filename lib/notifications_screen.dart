import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'theme.dart';
import 'splash_screen.dart';
import 'dashboard_screen.dart';
import 'wallet_screen.dart';
import 'chores_screen.dart';
import 'shopping_screen.dart';
import 'profile_screen.dart';
import 'dormy_ai_screen.dart';
import 'services/auth_service.dart';
import 'services/notification_service.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  static String _formatRelative(Timestamp? t) {
    if (t == null) return '';
    final d = t.toDate();
    final diff = DateTime.now().difference(d);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  static IconData _iconForType(String? type) {
    switch (type) {
      case 'expense':
        return Icons.account_balance_wallet;
      case 'chore':
        return Icons.assignment_turned_in;
      case 'shopping':
        return Icons.shopping_bag;
      case 'member':
        return Icons.person_add_alt_1;
      default:
        return Icons.notifications;
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final user = AuthService.instance.currentUser;

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
              title: Text(
                'Notifications',
                style: textTheme.headlineMedium?.copyWith(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  fontSize: 20,
                ),
              ),
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
            child: user == null
                ? const Center(child: Text('Sign in to see notifications.'))
                : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: NotificationService.instance.watchMyNotifications(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Text(
                              'Could not load notifications.\n${snapshot.error}',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      }
                      final docs = snapshot.data?.docs ?? [];
                      final sorted = List<QueryDocumentSnapshot<Map<String, dynamic>>>.from(docs);
                      sorted.sort((a, b) {
                        final ta = a.data()['createdAt'] as Timestamp?;
                        final tb = b.data()['createdAt'] as Timestamp?;
                        if (ta == null && tb == null) return 0;
                        if (ta == null) return 1;
                        if (tb == null) return -1;
                        return tb.compareTo(ta);
                      });

                      if (sorted.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.notifications_none,
                                    size: 64, color: AppTheme.outlineVariant),
                                const SizedBox(height: 16),
                                Text(
                                  'No notifications yet',
                                  style: textTheme.headlineSmall,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'You will see expenses, chores, shopping updates, and new roommates here.',
                                  style: textTheme.bodyMedium
                                      ?.copyWith(color: AppTheme.onSurfaceVariant),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      return ListView.separated(
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
                        itemCount: sorted.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, i) {
                          final doc = sorted[i];
                          final data = doc.data();
                          final type = data['type'] as String?;
                          final title = (data['title'] as String?) ?? 'Update';
                          final body = (data['body'] as String?) ?? '';
                          final createdAt =
                              data['createdAt'] as Timestamp?;
                          final icon = _iconForType(type);
                          Color iconColor = AppTheme.primary;
                          Color iconBg = AppTheme.primaryContainerOpacity10;
                          if (type == 'chore') {
                            iconColor = AppTheme.secondary;
                            iconBg = AppTheme.secondaryOpacity10;
                          } else if (type == 'member') {
                            iconColor = AppTheme.primary;
                            iconBg = AppTheme.primaryContainerOpacity10;
                          }

                          return _NotificationTile(
                            textTheme: textTheme,
                            icon: icon,
                            iconColor: iconColor,
                            iconBgColor: iconBg,
                            title: title,
                            time: _formatRelative(createdAt),
                            content: body,
                            onDismiss: () {
                              NotificationService.instance
                                  .deleteNotification(doc.id);
                            },
                          );
                        },
                      );
                    },
                  ),
          ),
          Positioned(
            bottom: 100,
            right: 24,
            child: FloatingActionButton(
              heroTag: 'notifications_ai_fab',
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
                    _buildNavItem(
                        context, Icons.shopping_bag_outlined, 'Shopping', false,
                        () {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ShoppingScreen()));
                    }),
                    _buildNavItem(context, Icons.person_outline, 'Profile',
                        false, () {
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

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.textTheme,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.title,
    required this.time,
    required this.content,
    required this.onDismiss,
  });

  final TextTheme textTheme;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String title;
  final String time;
  final String content;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.outlineVariantOpacity15),
        boxShadow: const [
          BoxShadow(
            color: AppTheme.primaryContainerOpacity8,
            blurRadius: 20,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(title,
                          style: textTheme.labelMedium?.copyWith(
                              color: AppTheme.onSurface,
                              fontWeight: FontWeight.bold)),
                    ),
                    Text(time,
                        style: textTheme.labelSmall
                            ?.copyWith(color: AppTheme.outline)),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      color: AppTheme.outline,
                      onPressed: onDismiss,
                      tooltip: 'Dismiss',
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(content,
                    style: textTheme.bodyMedium
                        ?.copyWith(color: AppTheme.onSurfaceVariant)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
