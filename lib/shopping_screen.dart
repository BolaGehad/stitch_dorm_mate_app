import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'theme.dart';
import 'splash_screen.dart'; // For BlueprintPainter
import 'dashboard_screen.dart';
import 'wallet_screen.dart';
import 'chores_screen.dart';
import 'profile_screen.dart';
import 'game_center_screen.dart';
import 'add_item_screen.dart';
import 'dormy_ai_screen.dart';
import 'expense_detail_screen.dart';
import 'services/expense_service.dart';
import 'services/house_service.dart';
import 'services/shopping_service.dart';

class ShoppingScreen extends StatefulWidget {
  const ShoppingScreen({super.key});

  @override
  State<ShoppingScreen> createState() => _ShoppingScreenState();
}

class _ShoppingScreenState extends State<ShoppingScreen> {
  bool _isConverting = false;

  Future<void> _convertCheckedItemsToBill(
    String houseId,
    List<QueryDocumentSnapshot<Map<String, dynamic>>> checkedDocs,
  ) async {
    final unbilled = checkedDocs
        .where((d) => (d.data()['isBilled'] as bool?) != true)
        .toList();
    if (unbilled.isEmpty) {
      _showMessage('No unbilled checked items.');
      return;
    }

    final total = unbilled.fold<double>(
      0,
      (acc, d) => acc + ((d.data()['estimatedPrice'] as num?)?.toDouble() ?? 0),
    );
    if (total <= 0) {
      _showMessage('Please add estimated price to checked items.');
      return;
    }

    setState(() => _isConverting = true);
    try {
      final expenseId = await ExpenseService.instance.createExpense(
        houseId: houseId,
        amount: total,
        description: 'Shopping items (${unbilled.length})',
      );
      await ShoppingService.instance.markItemsAsBilled(
        itemIds: unbilled.map((d) => d.id).toList(),
        expenseId: expenseId,
      );
      _showMessage('Converted to Wallet expense.');
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ExpenseDetailScreen(expenseId: expenseId),
        ),
      );
    } catch (e) {
      _showMessage(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isConverting = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
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
                      border: Border.all(
                          color: AppTheme.primaryContainerOpacity20, width: 2),
                      image: const DecorationImage(
                        image: NetworkImage(
                            'https://lh3.googleusercontent.com/aida-public/AB6AXuDSoU6d9ybmmaBVl-wrSEt06CQW-X8l2idx-ujmdi17AA-RUfIxiWGtTL3svVLrZm7Zlz7hQWgz1IL3EyedM-DAHGKMTvNbo4jJZ2SIL2Hf1D3mhrjCDJKi0ChovMkd6vHjmTE-d-Ut8Ak3F5D4NH8vAaFnsrHf2SK0pqMEr-VOwcbHEX7ow7IJkl_1-j6YJj_ASYgGXk8hjzUjvoeH0qL7mMJCGNf5z3UJ3FkzCWj2vv4_zTkP7hWdSDXUxP124-Ni1Wao0XRAGIQ'),
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
                final houseId = userSnapshot.data?.data()?['houseId'] as String?;
                if (houseId == null) {
                  return const Center(child: Text('Join a house to use shopping.'));
                }
                return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: ShoppingService.instance.watchItems(houseId),
                  builder: (context, itemsSnapshot) {
                    final docs = itemsSnapshot.data?.docs ?? [];
                    final pending = docs
                        .where((d) => (d.data()['isChecked'] as bool?) != true)
                        .toList();
                    final checked = docs
                        .where((d) => (d.data()['isChecked'] as bool?) == true)
                        .toList();
                    final unbilledChecked = checked
                        .where((d) => (d.data()['isBilled'] as bool?) != true)
                        .toList();
                    final convertTotal = unbilledChecked.fold<double>(
                      0,
                      (acc, d) => acc +
                          ((d.data()['estimatedPrice'] as num?)?.toDouble() ?? 0),
                    );
                    return SingleChildScrollView(
              padding: const EdgeInsets.only(
                  left: 20, right: 20, top: 32, bottom: 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Shopping List',
                                style: textTheme.headlineLarge),
                            const SizedBox(height: 4),
                            Text(
                              '${pending.length} items remaining for the house',
                              style: textTheme.bodyMedium
                                  ?.copyWith(color: AppTheme.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const AddItemScreen()),
                          );
                        },
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Add Item'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryContainer,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                          shadowColor: AppTheme.primaryContainerOpacity40,
                          textStyle: textTheme.labelMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Main List Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withOpacity(0.4)),
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
                        // Pending Items Section
                        Padding(
                          padding: const EdgeInsets.only(left: 4, bottom: 12),
                          child: Text(
                            'PENDING ITEMS',
                            style: textTheme.labelSmall?.copyWith(
                                color: AppTheme.outline, letterSpacing: 1.5),
                          ),
                        ),
                        if (pending.isEmpty)
                          Text('No pending items.',
                              style: textTheme.bodyMedium?.copyWith(
                                  color: AppTheme.onSurfaceVariant)),
                        ...pending.map((doc) {
                          final item = doc.data();
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildShoppingListItem(
                              textTheme: textTheme,
                              itemId: doc.id,
                              title: (item['title'] as String?) ?? 'Item',
                              tagText:
                                  'REQUESTED BY ${((item['requestedByName'] as String?) ?? 'MEMBER').toUpperCase()}',
                              userName: (item['requestedByName'] as String?) ?? 'Member',
                              isChecked: false,
                            ),
                          );
                        }),

                        const SizedBox(height: 32),

                        // Checked Items Section
                        Padding(
                          padding: const EdgeInsets.only(left: 4, bottom: 12),
                          child: Text(
                            'CHECKED ITEMS',
                            style: textTheme.labelSmall?.copyWith(
                                color: AppTheme.outline, letterSpacing: 1.5),
                          ),
                        ),
                        if (checked.isEmpty)
                          Text('No checked items yet.',
                              style: textTheme.bodyMedium?.copyWith(
                                  color: AppTheme.onSurfaceVariant)),
                        ...checked.map((doc) {
                          final item = doc.data();
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildShoppingListItem(
                              textTheme: textTheme,
                              itemId: doc.id,
                              title: (item['title'] as String?) ?? 'Item',
                              tagText:
                                  'PICKED UP BY ${((item['checkedByName'] as String?) ?? 'MEMBER').toUpperCase()}',
                              userName: (item['checkedByName'] as String?) ?? 'Member',
                              isChecked: true,
                              price:
                                  '\$${((item['estimatedPrice'] as num?)?.toDouble() ?? 0).toStringAsFixed(2)}',
                            ),
                          );
                        }),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Conversion Action Area
                  ElevatedButton(
                    onPressed: _isConverting
                        ? null
                        : () => _convertCheckedItemsToBill(houseId, checked),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryContainer,
                      foregroundColor: AppTheme.onPrimaryContainer,
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      elevation: 4,
                      shadowColor: AppTheme.primaryContainerOpacity40,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.receipt_long, size: 24),
                        const SizedBox(width: 12),
                        Text(_isConverting
                            ? 'Converting...'
                            : 'Convert checked items to bill',
                            style: textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppTheme.onPrimaryContainer)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: Text(
                      'This will create a shared expense in Wallet for\n\$${convertTotal.toStringAsFixed(2)} split among all roommates.',
                      style: textTheme.labelSmall
                          ?.copyWith(color: AppTheme.outline),
                      textAlign: TextAlign.center,
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

          // Floating Action Button
          Positioned(
            bottom: 100, // Above bottom nav
            right: 24,
            child: FloatingActionButton(
              heroTag: 'shopping_ai_fab',
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
                    _buildNavItem(context, Icons.shopping_bag, 'Shopping', true,
                        () {}), // Active State
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

  // Dynamic tag color generator based on user name
  Map<String, Color> _getUserTagStyles(String userName) {
    switch (userName.toLowerCase()) {
      case 'sam':
        return {'bg': Colors.blue.shade50, 'text': Colors.blue.shade600};
      case 'jordan':
        return {'bg': Colors.purple.shade50, 'text': Colors.purple.shade600};
      case 'casey':
      default:
        return {'bg': Colors.teal.shade50, 'text': AppTheme.primary};
    }
  }

  Widget _buildShoppingListItem({
    required TextTheme textTheme,
    required String itemId,
    required String title,
    required String tagText,
    required String userName,
    required bool isChecked,
    String? price,
  }) {
    final tagStyles = _getUserTagStyles(userName);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isChecked
            ? AppTheme.surfaceContainerLow.withOpacity(0.4)
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: isChecked
                ? AppTheme.surfaceContainerHighest
                : Colors.grey.shade100),
      ),
      child: Row(
        children: [
          // Checkbox
          InkWell(
            onTap: () async {
              await ShoppingService.instance.toggleItem(
                itemId: itemId,
                isChecked: !isChecked,
              );
            },
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isChecked ? AppTheme.primaryContainer : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppTheme.primaryContainer, width: 2),
              ),
              child: isChecked
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
          ),
          const SizedBox(width: 16),

          // Text & Tag
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.bodyLarge?.copyWith(
                    color: isChecked ? AppTheme.outline : AppTheme.onSurface,
                    decoration: isChecked
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: tagStyles['bg'],
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    tagText,
                    style: textTheme.labelSmall?.copyWith(
                        color: tagStyles['text'],
                        fontSize: 9,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),

          // Trailing Element (Dots or Price)
          if (isChecked && price != null)
            Text(price,
                style: textTheme.bodyLarge?.copyWith(color: AppTheme.outline))
          else
            const Icon(Icons.more_vert, color: AppTheme.outlineVariant),
        ],
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
