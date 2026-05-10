import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'theme.dart';
import 'splash_screen.dart'; // Importing for BlueprintPainter reuse
import 'guest_wallet_screen.dart';
import 'profile_screen.dart';
import 'dormy_ai_screen.dart';

class GuestDashboardScreen extends StatelessWidget {
  const GuestDashboardScreen({super.key});

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
                  left: 20,
                  right: 20,
                  top: 32,
                  bottom: 120), // Bottom padding accommodates nav bar
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Greeting Header
                  Text('Hello, Alex', style: textTheme.headlineLarge),
                  const SizedBox(height: 8),
                  Text(
                    "Here's what's happening in your dorm.",
                    style: textTheme.bodyMedium
                        ?.copyWith(color: AppTheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 24),

                  // Financial Status Card
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('FINANCIAL STATUS',
                                style: textTheme.labelSmall?.copyWith(
                                    color: AppTheme.primary,
                                    letterSpacing: 1.5,
                                    fontWeight: FontWeight.bold)),
                            const Icon(Icons.account_balance_wallet,
                                color: AppTheme.primary, size: 20),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppTheme.surfaceContainerLow,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('You Owe',
                                        style: textTheme.labelSmall?.copyWith(
                                            color: AppTheme.onSurfaceVariant)),
                                    const SizedBox(height: 4),
                                    Text('\$42.50',
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
                                  color: const Color(
                                      0xFFE6F2FE), // very pale mint/teal as per design
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('You Are Owed',
                                        style: textTheme.labelSmall?.copyWith(
                                            color: AppTheme.onSurfaceVariant)),
                                    const SizedBox(height: 4),
                                    Text('\$128.00',
                                        style: textTheme.headlineMedium
                                            ?.copyWith(
                                                color: AppTheme.primary)),
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
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const GuestWalletScreen()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryContainer,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 48),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          child: Text('Settle Balances',
                              style: textTheme.labelMedium?.copyWith(
                                  color: AppTheme.onPrimaryContainer)),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Next Chore Card
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('NEXT CHORE',
                                style: textTheme.labelSmall?.copyWith(
                                    color: AppTheme.primary,
                                    letterSpacing: 1.5,
                                    fontWeight: FontWeight.bold)),
                            const Icon(Icons.assignment_turned_in,
                                color: AppTheme.primary, size: 20),
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
                              child: const Icon(Icons.delete_sweep,
                                  color: AppTheme.secondary),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Trash & Recycling',
                                      style: textTheme.bodyLarge?.copyWith(
                                          fontWeight: FontWeight.bold)),
                                  Text('Due: Tonight, 8:00 PM',
                                      style: textTheme.bodyMedium?.copyWith(
                                          color: AppTheme.onSurfaceVariant)),
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
                            color: AppTheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: 0.75,
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
                          child: Text('3/4 roommates done',
                              style: textTheme.labelSmall
                                  ?.copyWith(color: AppTheme.onSurfaceVariant)),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Shopping List Card
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
                        _buildShoppingItem(
                            textTheme, 'Oat Milk (Barista Ed.)', false),
                        const Divider(
                            height: 1, color: AppTheme.surfaceContainerHighest),
                        _buildShoppingItem(textTheme, 'Avocados (3x)', false),
                        const Divider(
                            height: 1, color: AppTheme.surfaceContainerHighest),
                        _buildShoppingItem(textTheme, 'Dish Soap', true),
                        const SizedBox(height: 16),
                        InkWell(
                          onTap: () {},
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('View All Items',
                                  style: textTheme.labelMedium
                                      ?.copyWith(color: AppTheme.primary)),
                              const SizedBox(width: 4),
                              const Icon(Icons.arrow_forward,
                                  color: AppTheme.primary, size: 16),
                            ],
                          ),
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
                          "You've saved 4 hours of chores this month\nby staying organized.",
                          style: textTheme.bodyMedium
                              ?.copyWith(color: Colors.white.withOpacity(0.9)),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            border: Border.all(
                                color: Colors.white.withOpacity(0.5)),
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
                              builder: (context) => const GuestWalletScreen()));
                    }),
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

  Widget _buildShoppingItem(TextTheme textTheme, String text, bool isChecked) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(
            isChecked ? Icons.check_circle : Icons.radio_button_unchecked,
            color:
                isChecked ? AppTheme.primaryContainer : AppTheme.outlineVariant,
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(
            text,
            style: textTheme.bodyMedium?.copyWith(
              color: isChecked ? AppTheme.outline : AppTheme.onSurface,
              decoration: isChecked ? TextDecoration.lineThrough : null,
            ),
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
