import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'notifications_screen.dart';
import 'auth_gate.dart';
import 'services/auth_service.dart';
import 'services/house_service.dart';

class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;
  final double radius;

  DashedBorderPainter({
    required this.color,
    this.strokeWidth = 1.5,
    this.gap = 6.0,
    this.radius = 8.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    var path = Path()
      ..addRRect(RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          Radius.circular(radius)));

    Path dashPath = Path();
    double distance = 0.0;
    for (ui.PathMetric pathMetric in path.computeMetrics()) {
      while (distance < pathMetric.length) {
        dashPath.addPath(
            pathMetric.extractPath(distance, distance + gap), Offset.zero);
        distance += gap * 2;
      }
    }
    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class HouseSettingsScreen extends StatelessWidget {
  const HouseSettingsScreen({super.key});

  static List<String> _parseRules(Map<String, dynamic>? h) {
    final raw = h?['houseRules'];
    if (raw is! List) return [];
    return raw.map((e) => '$e').where((s) => s.trim().isNotEmpty).toList();
  }

  Future<void> _copyInviteCode(BuildContext context, String code) async {
    await Clipboard.setData(ClipboardData(text: code));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invite code copied.')),
      );
    }
  }

  Future<void> _editHouseName(
    BuildContext context,
    String houseId,
    String current,
  ) async {
    final c = TextEditingController(text: current);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('House name'),
        content: TextField(
          controller: c,
          decoration: const InputDecoration(labelText: 'Name'),
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
    if (ok != true || !context.mounted) return;
    try {
      await HouseService.instance.updateHouseAsOwner(
        houseId: houseId,
        name: c.text,
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('House name updated.')),
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

  Future<void> _addRule(
    BuildContext context,
    String houseId,
    List<String> rules,
  ) async {
    final c = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add house rule'),
        content: TextField(
          controller: c,
          decoration: const InputDecoration(hintText: 'e.g. Quiet hours after 10pm'),
          maxLines: 2,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Add'),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    final text = c.text.trim();
    if (text.isEmpty) return;
    try {
      await HouseService.instance.updateHouseAsOwner(
        houseId: houseId,
        houseRules: [...rules, text],
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    }
  }

  Future<void> _deleteRule(
    BuildContext context,
    String houseId,
    List<String> rules,
    int index,
  ) async {
    final next = List<String>.from(rules)..removeAt(index);
    try {
      await HouseService.instance.updateHouseAsOwner(
        houseId: houseId,
        houseRules: next,
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    }
  }

  Future<void> _confirmLeave(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Leave household?'),
        content: const Text(
          'You will lose access to this house’s shared data on this device until you join again.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Leave', style: TextStyle(color: AppTheme.error)),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    try {
      await HouseService.instance.leaveHouse();
      if (!context.mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const AuthGate()),
        (_) => false,
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final uid = AuthService.instance.currentUser?.uid;

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
                'House Settings',
                style: textTheme.headlineMedium?.copyWith(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  fontSize: 20,
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined,
                      color: AppTheme.outline),
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
            child: uid == null
                ? const Center(child: Text('Sign in required.'))
                : StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                    stream: HouseService.instance.watchCurrentUserProfile(),
                    builder: (context, userSnap) {
                      final houseId =
                          userSnap.data?.data()?['houseId'] as String?;
                      if (houseId == null || houseId.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Text(
                              'Join or create a house first.',
                              style: textTheme.bodyLarge,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      }
                      return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                        stream: HouseService.instance.watchHouseById(houseId),
                        builder: (context, houseSnap) {
                          final h = houseSnap.data?.data();
                          if (h == null) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }
                          final name = (h['name'] as String?) ?? 'House';
                          final inviteCode =
                              (h['inviteCode'] as String?) ?? '—';
                          final isOwner = h['ownerId'] == uid;
                          final rules = _parseRules(h);
                          final autoApprove =
                              (h['autoApproveExpense'] as bool?) ?? false;
                          final quiet =
                              (h['quietHoursNotify'] as bool?) ?? false;

                          return SingleChildScrollView(
                            padding: const EdgeInsets.only(
                                left: 20, right: 20, top: 24, bottom: 120),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(name, style: textTheme.headlineLarge),
                                const SizedBox(height: 8),
                                Text(
                                  isOwner
                                      ? 'You are the owner — you can edit house details.'
                                      : 'Member — invite code and some settings are view-only.',
                                  style: textTheme.bodyMedium?.copyWith(
                                      color: AppTheme.onSurfaceVariant),
                                ),
                                const SizedBox(height: 32),
                                _inviteCard(
                                  context,
                                  textTheme,
                                  inviteCode,
                                  isOwner,
                                ),
                                const SizedBox(height: 24),
                                _rulesCard(
                                  context,
                                  textTheme,
                                  houseId,
                                  rules,
                                  isOwner,
                                ),
                                const SizedBox(height: 24),
                                _generalCard(
                                  context,
                                  textTheme,
                                  houseId,
                                  name,
                                  autoApprove,
                                  quiet,
                                  isOwner,
                                ),
                                const SizedBox(height: 24),
                                _safetyCard(textTheme),
                                const SizedBox(height: 24),
                                if (!isOwner)
                                  _leaveCard(context, textTheme)
                                else
                                  _ownerNoteCard(textTheme),
                              ],
                            ),
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
              heroTag: 'settings_ai_fab',
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

  Widget _inviteCard(
    BuildContext context,
    TextTheme textTheme,
    String inviteCode,
    bool isOwner,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
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
          Text('INVITE ROOMMATES',
              style: textTheme.labelSmall?.copyWith(
                  color: AppTheme.primary,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Share this code',
                        style: textTheme.labelSmall
                            ?.copyWith(color: AppTheme.outline)),
                    const SizedBox(height: 4),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppTheme.outlineVariant),
                      ),
                      child: Text(
                        inviteCode,
                        style: textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold, letterSpacing: 1.2),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: () => _copyInviteCode(context, inviteCode),
                icon: const Icon(Icons.content_copy, size: 18),
                label: const Text('Copy'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryContainer,
                  foregroundColor: AppTheme.onPrimaryContainer,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            isOwner
                ? 'Anyone with this code can join until the house is full.'
                : 'Share the code with your owner if someone new should join.',
            style:
                textTheme.labelSmall?.copyWith(color: AppTheme.outline, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _rulesCard(
    BuildContext context,
    TextTheme textTheme,
    String houseId,
    List<String> rules,
    bool isOwner,
  ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
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
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.teal.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.gavel,
                      color: Colors.teal.shade700, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                    child: Text('House rules', style: textTheme.headlineMedium)),
              ],
            ),
          ),
          const Divider(height: 1, color: AppTheme.surfaceContainerHighest),
          if (rules.isEmpty)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'No rules yet.${isOwner ? ' Add expectations for everyone.' : ''}',
                style: textTheme.bodyMedium
                    ?.copyWith(color: AppTheme.onSurfaceVariant),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: List.generate(rules.length, (i) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      children: [
                        const Icon(Icons.circle,
                            size: 8, color: AppTheme.primary),
                        const SizedBox(width: 12),
                        Expanded(
                            child: Text(rules[i], style: textTheme.bodyMedium)),
                        if (isOwner)
                          IconButton(
                            icon: const Icon(Icons.delete_outline,
                                color: AppTheme.outlineVariant),
                            onPressed: () =>
                                _deleteRule(context, houseId, rules, i),
                          ),
                      ],
                    ),
                  );
                }),
              ),
            ),
          if (isOwner)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.surfaceContainerLow.withOpacity(0.5),
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(16)),
              ),
              child: CustomPaint(
                painter: DashedBorderPainter(color: AppTheme.outlineVariant),
                child: InkWell(
                  onTap: () => _addRule(context, houseId, rules),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.add,
                            color: AppTheme.onSurfaceVariant, size: 20),
                        const SizedBox(width: 8),
                        Text('Add rule',
                            style: textTheme.labelMedium
                                ?.copyWith(color: AppTheme.onSurfaceVariant)),
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

  Widget _generalCard(
    BuildContext context,
    TextTheme textTheme,
    String houseId,
    String houseName,
    bool autoApprove,
    bool quiet,
    bool isOwner,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.settings,
                    color: Colors.orange.shade800, size: 24),
              ),
              const SizedBox(width: 12),
              Text('General', style: textTheme.headlineMedium),
            ],
          ),
          const SizedBox(height: 20),
          InkWell(
            onTap: isOwner
                ? () => _editHouseName(context, houseId, houseName)
                : null,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('House name',
                    style: textTheme.bodyMedium
                        ?.copyWith(color: AppTheme.onSurfaceVariant)),
                Row(
                  children: [
                    Text(houseName,
                        style: textTheme.labelMedium
                            ?.copyWith(color: AppTheme.primary)),
                    if (isOwner) ...[
                      const SizedBox(width: 4),
                      const Icon(Icons.edit, size: 16, color: AppTheme.primary),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Auto-approve expenses',
                  style: textTheme.bodyMedium
                      ?.copyWith(color: AppTheme.onSurfaceVariant),
                ),
              ),
              Switch(
                value: autoApprove,
                onChanged: isOwner
                    ? (v) async {
                        try {
                          await HouseService.instance.updateHouseAsOwner(
                            houseId: houseId,
                            autoApproveExpense: v,
                          );
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(e
                                      .toString()
                                      .replaceFirst('Exception: ', ''))),
                            );
                          }
                        }
                      }
                    : null,
                activeTrackColor: AppTheme.primaryContainer,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Quiet hours reminders',
                  style: textTheme.bodyMedium
                      ?.copyWith(color: AppTheme.onSurfaceVariant),
                ),
              ),
              Switch(
                value: quiet,
                onChanged: isOwner
                    ? (v) async {
                        try {
                          await HouseService.instance.updateHouseAsOwner(
                            houseId: houseId,
                            quietHoursNotify: v,
                          );
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(e
                                      .toString()
                                      .replaceFirst('Exception: ', ''))),
                            );
                          }
                        }
                      }
                    : null,
                activeTrackColor: AppTheme.primaryContainer,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'These toggles are stored in Firestore. Push alerts (FCM) can be added later.',
            style: textTheme.labelSmall?.copyWith(color: AppTheme.outline),
          ),
        ],
      ),
    );
  }

  Widget _safetyCard(TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child:
                    Icon(Icons.badge, color: Colors.blue.shade600, size: 24),
              ),
              const SizedBox(width: 12),
              Text('Safety', style: textTheme.headlineMedium),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Emergency contacts and building codes are not stored in the app yet. Use your house group chat for critical info.',
            style: textTheme.bodySmall
                ?.copyWith(color: AppTheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _leaveCard(BuildContext context, TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.errorContainer.withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.errorContainer),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('LEAVE HOUSE',
              style: textTheme.labelSmall?.copyWith(
                  color: AppTheme.onErrorContainer,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text(
            'You will be removed from this house and lose access to shared data until you join again with an invite code.',
            style: textTheme.labelSmall?.copyWith(color: AppTheme.error),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () => _confirmLeave(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.error,
              side: const BorderSide(color: AppTheme.error),
            ),
            child: const Text('Leave household'),
          ),
        ],
      ),
    );
  }

  Widget _ownerNoteCard(TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.surfaceContainerHighest),
      ),
      child: Text(
        'House owners cannot use “Leave” here. To move out, transfer ownership (coming soon) or manage the house from Firebase Console if needed.',
        style: textTheme.bodySmall?.copyWith(color: AppTheme.onSurfaceVariant),
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
