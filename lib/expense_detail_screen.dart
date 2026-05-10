import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'theme.dart';
import 'splash_screen.dart'; // For BlueprintPainter
import 'dashboard_screen.dart';
import 'wallet_screen.dart';
import 'chores_screen.dart';
import 'shopping_screen.dart';
import 'profile_screen.dart';
import 'dormy_ai_screen.dart';
import 'services/auth_service.dart';
import 'services/expense_service.dart';

class ExpenseDetailScreen extends StatelessWidget {
  const ExpenseDetailScreen({super.key, this.expenseId});

  final String? expenseId;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final currentUserId = AuthService.instance.currentUser?.uid;

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
                icon: Icon(Icons.arrow_back, color: cs.onSurface),
                onPressed: () => Navigator.pop(context),
              ),
              titleSpacing: 0,
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(1),
                child: Container(
                    color: AppTheme.schemeContainerHighest(context), height: 1),
              ),
              title: Text(
                'Expense Detail',
                style: textTheme.headlineMedium?.copyWith(
                  color: cs.onSurface,
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                ),
              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.edit, color: cs.onSurface),
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
            child: expenseId == null
                ? const Center(child: Text('No expense selected.'))
                : StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                    stream: ExpenseService.instance.watchExpenseById(expenseId!),
                    builder: (context, snapshot) {
                      final data = snapshot.data?.data();
                      final amount = (data?['amount'] as num?)?.toDouble() ?? 0;
                      final description =
                          (data?['description'] as String?) ?? 'Expense';
                      final paidBy =
                          (data?['paidByName'] as String?) ?? 'Unknown';
                      final createdAt =
                          (data?['createdAt'] as Timestamp?)?.toDate();
                      final expenseMap =
                          data ?? <String, dynamic>{};
                      final paidById =
                          ExpenseService.payerUserId(expenseMap['paidBy']) ?? '';
                      final settled =
                          ExpenseService.instance.settledUserIds(expenseMap);
                      final myShare = currentUserId == null
                          ? 0.0
                          : ExpenseService.instance.shareAmountForUser(
                              expenseMap, currentUserId);
                      final canSettle = currentUserId != null &&
                          currentUserId != paidById &&
                          myShare > 0 &&
                          !settled.contains(currentUserId);
                      final createdDate = createdAt == null
                          ? 'Now'
                          : '${createdAt.year}-${createdAt.month.toString().padLeft(2, '0')}-${createdAt.day.toString().padLeft(2, '0')}';
                      return SingleChildScrollView(
              padding: const EdgeInsets.only(
                  left: 20, right: 20, top: 24, bottom: 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Info Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
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
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryContainerOpacity10,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: const Icon(Icons.shopping_cart,
                              color: AppTheme.primary, size: 32),
                        ),
                        const SizedBox(height: 12),
                        Text(description,
                            style: textTheme.headlineLarge
                                ?.copyWith(fontSize: 24)),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text('\$',
                                style: textTheme.headlineLarge?.copyWith(
                                    color: AppTheme.primary, fontSize: 24)),
                            Text(amount.toStringAsFixed(2),
                                style: textTheme.headlineLarge?.copyWith(
                                    color: AppTheme.primary, fontSize: 32)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('Paid by $paidBy • $createdDate',
                            style: textTheme.labelMedium
                                ?.copyWith(color: AppTheme.tertiary)),
                        const SizedBox(height: 8),
                        Text('Your share: \$${myShare.toStringAsFixed(2)}',
                            style: textTheme.labelMedium
                                ?.copyWith(color: AppTheme.schemeOnSurfaceVariant(context))),
                        if (canSettle) ...[
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () async {
                              try {
                                await ExpenseService.instance
                                    .markMyShareSettled(expenseId!);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Marked as settled.')),
                                  );
                                }
                              } catch (_) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Failed to settle share.')),
                                  );
                                }
                              }
                            },
                            child: const Text('Mark my share as settled'),
                          ),
                        ] else if (currentUserId != null &&
                            currentUserId != paidById &&
                            myShare > 0 &&
                            settled.contains(currentUserId)) ...[
                          const SizedBox(height: 12),
                          Text('You already settled this expense.',
                              style: textTheme.labelSmall
                                  ?.copyWith(color: AppTheme.primary)),
                        ],
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceContainer,
                            borderRadius: BorderRadius.circular(9999),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.category,
                                  size: 14,
                                  color:
                                      AppTheme.schemeOnSurfaceVariant(context)),
                              const SizedBox(width: 4),
                              Text('Groceries & Household',
                                  style: textTheme.labelSmall?.copyWith(
                                      color: AppTheme.schemeOnSurfaceVariant(context))),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Receipt Image Card
                  Container(
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
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
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('RECEIPT IMAGE',
                                  style: textTheme.labelMedium?.copyWith(
                                      color: AppTheme.schemeOnSurface(context),
                                      letterSpacing: 1.5)),
                              InkWell(
                                onTap: () {},
                                child: Row(
                                  children: [
                                    const Icon(Icons.fullscreen,
                                        size: 16, color: AppTheme.primary),
                                    const SizedBox(width: 4),
                                    Text('View Full',
                                        style: textTheme.labelMedium?.copyWith(
                                            color: AppTheme.primary)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Divider(
                            height: 1, color: AppTheme.surfaceContainerHighest),
                        AspectRatio(
                          aspectRatio: 4 / 3,
                          child: Container(
                            color: AppTheme.surfaceContainerHighest,
                            child: Image.network(
                              'https://lh3.googleusercontent.com/aida-public/AB6AXuDNzhSX2Z-xeECK2O-i_KQ9rvL30y99355CR-8ciOUvpQsTq9MrKzZdSQFMlAI8097GpAk7JEwj5cvUtHkWH8UCNiou6AbwyeQrQL21rCvgk8e53CEHpQU1wOZMQhE4TgErO0zJ8BVLecXvD91A4rWgfM-cXso3mDqkisxaVWE-bcAM1zl7knQRlNTZWOTWjgwsC28JiCxiZ_N6rc_ueUGYQheG4M7xVk8kPfmWP3Xlu3Ldsf5rAipKPZoSB4nkRvvXshBOomg5f9E',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Who Paid What (Splits)
                  Container(
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
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
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text('WHO PAID WHAT',
                              style: textTheme.labelMedium?.copyWith(
                                  color: AppTheme.schemeOnSurface(context),
                                  letterSpacing: 1.5)),
                        ),
                        const Divider(
                            height: 1, color: AppTheme.surfaceContainerHighest),

                        // Payer
                        _buildSplitItem(
                          context: context,
                          textTheme: textTheme,
                          name: 'Alex Johnson',
                          subtext: 'Paid \$142.50',
                          amount: '+\$106.88',
                          status: 'Settled',
                          imageUrl:
                              'https://lh3.googleusercontent.com/aida-public/AB6AXuDcbHR8T3Nf55xvaU5kbHB_jjSuNxrD0Z491UFae-GIhawga_CMJHHT6DwTf8FQ9u3zSKAKrP4yI5JSXKOzdBGOZR6khTloUIDBVhyRuh03hERR6X605q2KgK_rebubOrlFBDSwDk0-h1kqNZJW2P2Yw0KEjQeB99tpO-p7hGOxqzE0_j4iRUobANYIAzc6nZwmEnKBGqT13fCrS0E90WWb1MTtYP_2xoUPsVNBHtCgGBk8_3JLKmLp3_GkBgt42vl_vvPPJeKjbAQ',
                          isPayer: true,
                        ),
                        const Divider(
                            height: 1, color: AppTheme.surfaceContainerHighest),

                        // Participant 1
                        Container(
                          color: AppTheme.surfaceContainerLow.withOpacity(0.3),
                          child: _buildSplitItem(
                            context: context,
                            textTheme: textTheme,
                            name: 'Sarah Miller',
                            subtext: 'Split 25%',
                            amount: '-\$35.62',
                            status: 'Owes Alex',
                            imageUrl:
                                'https://lh3.googleusercontent.com/aida-public/AB6AXuCyFOcN2SkaOr1W1mI7oFvzWvZsxAILYo1LmkiXNaiT2aTr4unvh2bngoN8SoKE3b_u7gmtIc9ijhOBHST7vhfAow31tyG450VpVPcB_iqikfLINglmDUTfYMRU7p5226DzQYCiL2Ojd9W1hyOCxpW3hDdXRZ-lMtsZW2KF_9mJO_2z3lRK076ERsO6E_MjfZeZ-S-Aisq3iiqHOW2vCwyj7p1-_EgU6fPd7rvS5cZxq2V0ggHHtV0AU9T3-eO7IzAb8n0I0X-1TCU',
                            isPayer: false,
                          ),
                        ),
                        const Divider(
                            height: 1, color: AppTheme.surfaceContainerHighest),

                        // Participant 2
                        _buildSplitItem(
                          context: context,
                          textTheme: textTheme,
                          name: 'Jordan Lee',
                          subtext: 'Split 25%',
                          amount: '-\$35.62',
                          status: 'Owes Alex',
                          imageUrl:
                              'https://lh3.googleusercontent.com/aida-public/AB6AXuCn1Wn9iIndcMBEUK0VnXWxpB-x1ZJwrQG-RExcPxvxwOuuvgLZx7E-h5uN2cTtyragAYZu15V3p__XW5mypGXcJJpeq8xhMjBufjs1H-7o_ae-23kNQNGBUU3WRc0uvMRv13bYC03DGmZjfWUBQIfPKfYLML-lkP1XJHlBcKk5wsbvid9MziFKJJgWqmVSnAOUzTzoMdbzq0_VnqI1M0ZNLvdxw6oNEWOHXn2YEx0jpNfsUTb5z2AIto76S8s6ho6Der3D80rhs6M',
                          isPayer: false,
                        ),
                        const Divider(
                            height: 1, color: AppTheme.surfaceContainerHighest),

                        // Participant 3
                        _buildSplitItem(
                          context: context,
                          textTheme: textTheme,
                          name: 'Maya Chen',
                          subtext: 'Split 25%',
                          amount: '-\$35.62',
                          status: 'Owes Alex',
                          imageUrl:
                              'https://lh3.googleusercontent.com/aida-public/AB6AXuBGUlVCEpDkKez-39tybOsTRJcJPmcyb9rC-yw9Cernb6wT64UpeGHQR44RPAQvQJrfmXtCV7egZhoQIDOKksWZyoECWpHvIn_uqHCbkVGoxBJchcYdLDuh1N9tVl3yjLZO0zegLoZ7OVaSCQg1TY44TrCvjybiEj_Tft8AknEaUqJXbj03IWK50ZP46GKq_8PTE-zs8LYEXXx_o163aLsgX-92p60zTaZg64w1HbHrH02Qv9I22R8pEIYczaxhIHR1OcGc6feeHTE',
                          isPayer: false,
                        ),

                        // Split Visualization
                        Container(
                          padding: const EdgeInsets.all(16),
                          color: AppTheme.primaryContainerOpacity10,
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Equity Distribution',
                                      style: textTheme.labelSmall
                                          ?.copyWith(color: AppTheme.primary)),
                                  Text('Even Split',
                                      style: textTheme.labelSmall?.copyWith(
                                          color: AppTheme.schemeOnSurfaceVariant(context))),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Container(
                                height: 8,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: Row(
                                  children: [
                                    Expanded(
                                        child: Container(
                                            color: AppTheme.primary,
                                            margin: const EdgeInsets.only(
                                                right: 1))),
                                    Expanded(
                                        child: Container(
                                            color: AppTheme.primary
                                                .withOpacity(0.8),
                                            margin: const EdgeInsets.only(
                                                right: 1))),
                                    Expanded(
                                        child: Container(
                                            color: AppTheme.primary
                                                .withOpacity(0.6),
                                            margin: const EdgeInsets.only(
                                                right: 1))),
                                    Expanded(
                                        child: Container(
                                            color: AppTheme.primary
                                                .withOpacity(0.4))),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Activity Section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
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
                        Text('ACTIVITY',
                            style: textTheme.labelMedium?.copyWith(
                                color: AppTheme.schemeOnSurface(context), letterSpacing: 1.5)),
                        const SizedBox(height: 16),

                        // Activity Item 1
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: AppTheme.primaryContainerOpacity20,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.note_add,
                                  color: AppTheme.primary, size: 16),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  RichText(
                                    text: TextSpan(
                                      style: textTheme.bodyMedium
                                          ?.copyWith(color: AppTheme.schemeOnSurface(context)),
                                      children: [
                                        const TextSpan(
                                            text: 'Alex added a note: '),
                                        TextSpan(
                                            text:
                                                '"This includes the cleaning supplies for the kitchen."',
                                            style: textTheme.bodyMedium
                                                ?.copyWith(
                                                    fontStyle: FontStyle.italic,
                                                    color: AppTheme
                                                        .onSurfaceVariant)),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text('Oct 24, 6:15 PM',
                                      style: textTheme.labelSmall
                                          ?.copyWith(color: AppTheme.tertiary)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Activity Item 2
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: AppTheme.secondaryOpacity10,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.payments,
                                  color: AppTheme.secondary, size: 16),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Maya Chen marked as settled.',
                                      style: textTheme.bodyMedium?.copyWith(
                                          color: AppTheme.schemeOnSurface(context))),
                                  const SizedBox(height: 4),
                                  Text('Oct 25, 9:20 AM',
                                      style: textTheme.labelSmall
                                          ?.copyWith(color: AppTheme.tertiary)),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),
                        const Divider(
                            height: 1, color: AppTheme.surfaceContainerHighest),
                        const SizedBox(height: 16),

                        // Input box
                        Container(
                          decoration: BoxDecoration(
                            color: AppTheme.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: AppTheme.surfaceContainerHighest),
                          ),
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Add a comment...',
                              hintStyle: textTheme.bodyMedium
                                  ?.copyWith(color: AppTheme.outlineVariant),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              suffixIcon: const Icon(Icons.send,
                                  color: AppTheme.primary),
                            ),
                          ),
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

          // Dormy AI FAB
          Positioned(
            bottom: 100, // Above bottom nav
            right: 24,
            child: FloatingActionButton(
              heroTag: 'expense_ai_fab',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const DormyAiScreen()),
                );
              },
              backgroundColor: AppTheme.primary,
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
                        context, Icons.account_balance_wallet, 'Wallet', true,
                        () {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const WalletScreen()));
                    }), // Active state
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

  Widget _buildSplitItem({
    required BuildContext context,
    required TextTheme textTheme,
    required String name,
    required String subtext,
    required String amount,
    required String status,
    required String imageUrl,
    required bool isPayer,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: isPayer
                          ? AppTheme.primaryContainer
                          : AppTheme.surfaceContainerHighest,
                      width: 2),
                  image: DecorationImage(
                    image: NetworkImage(imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              if (isPayer)
                Positioned(
                  bottom: -2,
                  right: -2,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check_circle,
                        color: AppTheme.primary, size: 16),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: textTheme.labelMedium
                        ?.copyWith(color: AppTheme.schemeOnSurface(context))),
                Text(subtext,
                    style: textTheme.labelSmall?.copyWith(
                        color: isPayer ? AppTheme.primary : AppTheme.tertiary)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(amount,
                  style: textTheme.labelMedium?.copyWith(
                      color: isPayer
                          ? AppTheme.schemeOnSurfaceVariant(context)
                          : AppTheme.error)),
              Text(status,
                  style:
                      textTheme.labelSmall?.copyWith(color: AppTheme.tertiary)),
            ],
          ),
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
