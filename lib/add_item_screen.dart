import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'theme.dart';
import 'splash_screen.dart'; // For BlueprintPainter
import 'dashboard_screen.dart';
import 'wallet_screen.dart';
import 'chores_screen.dart';
import 'profile_screen.dart';
import 'shopping_screen.dart';
import 'services/house_service.dart';
import 'services/shopping_service.dart';

class AddItemScreen extends StatefulWidget {
  const AddItemScreen({super.key});

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _itemController = TextEditingController();
  final _priceController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _itemController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _addItem() async {
    final title = _itemController.text.trim();
    final price = double.tryParse(_priceController.text.trim()) ?? 0;
    if (title.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      final houseId = await HouseService.instance.getCurrentUserHouseId();
      await ShoppingService.instance.addItem(
        houseId: houseId,
        title: title,
        estimatedPrice: price,
      );
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

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
                icon: Icon(Icons.close,
                    color: AppTheme.schemeOnSurfaceVariant(context)),
                onPressed: () => Navigator.pop(context),
              ),
              titleSpacing: 0,
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(1),
                child: Container(
                    color: AppTheme.schemeContainerHighest(context), height: 1),
              ),
              title: Text(
                'Add New Item',
                style: textTheme.headlineMedium?.copyWith(
                  color: AppTheme.primaryContainer, // Teal color based on spec
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                ),
              ),
              actions: [
                Container(
                  margin: const EdgeInsets.only(right: 20),
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: AppTheme.primaryContainerOpacity20, width: 2),
                    image: const DecorationImage(
                      image: NetworkImage(
                          'https://lh3.googleusercontent.com/aida-public/AB6AXuDJVg_da43ddKT5JehEUo050NbqzmVfDUZKEl_zzhwr_yFvgdpKaR9zexNfXe0eXTfxcaczkpx1sRopcc9uOCIi-FfvRwnLgueceBVSQgZlT5O-sX1xNtruu97lv8tI9AGnc17UXhK90admkyqHhHWlqcO5Tzjn-eKB7sJKgCbzPHeemLOcWVs0gqoUD_KI8Hb_ngH4JWrPwjNexcBddVzpOt4kD2urmiRGT13JjNWB26yuiMRktY7dB3kkVNUHNHsP5mpTpXOYxQ8'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
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
                  // Primary Input Group
                  Text('What needs to be done?',
                      style: textTheme.bodyLarge?.copyWith(
                          color: AppTheme.schemeOnSurfaceVariant(context),
                          fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      boxShadow: const [
                        BoxShadow(
                          color: AppTheme.primaryContainerOpacity8,
                          blurRadius: 20,
                          offset: Offset(0, 4),
                        ),
                      ],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextFormField(
                      controller: _itemController,
                      onFieldSubmitted: (_) => _isLoading ? null : _addItem(),
                      style: textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface),
                      decoration: InputDecoration(
                        hintText: 'Buy milk, clean the fridge...',
                        hintStyle: textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant
                                .withValues(alpha: 0.85)),
                        filled: true,
                        fillColor: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                        contentPadding: const EdgeInsets.only(
                            left: 16, top: 20, bottom: 20),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: AppTheme.primaryContainer, width: 2),
                        ),
                        suffixIcon: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _addItem,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryContainer,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(40, 40),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              elevation: 2,
                            ),
                            child: const Icon(Icons.add, size: 24),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _priceController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      hintText: 'Estimated price (optional)',
                      prefixText: '\$ ',
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Suggestions Section
                  Text('Suggestions',
                      style: textTheme.headlineMedium?.copyWith(
                          color: AppTheme.schemeOnSurface(context),
                          fontSize: 20)),
                  const SizedBox(height: 16),
                  Column(
                    children: [
                      Row(
                        children: [
                          _buildSuggestionCard(
                            context,
                            textTheme,
                            title: 'Grocery Run',
                            subtitle: 'Milk, Eggs, Bread',
                            icon: Icons.shopping_cart,
                          ),
                          const SizedBox(width: 16),
                          _buildSuggestionCard(
                            context,
                            textTheme,
                            title: 'Deep Clean',
                            subtitle: 'Kitchen & Living Room',
                            icon: Icons.cleaning_services,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _buildSuggestionCard(
                            context,
                            textTheme,
                            title: 'Split Bills',
                            subtitle: 'Electricity or Wi-Fi',
                            icon: Icons.payments,
                          ),
                          const SizedBox(width: 16),
                          _buildSuggestionCard(
                            context,
                            textTheme,
                            title: 'House Meeting',
                            subtitle: 'Monthly Check-in',
                            icon: Icons.redeem, // gift icon as per HTML spec
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Quick Tags Section
                  Text('QUICK TAGS',
                      style: textTheme.labelSmall?.copyWith(
                          color: cs.outline, letterSpacing: 1.5)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: [
                      _buildQuickTag(context, textTheme, '#Urgent'),
                      _buildQuickTag(context, textTheme, '#Shared'),
                      _buildQuickTag(context, textTheme, '#Kitchen'),
                      _buildQuickTag(context, textTheme, '#Rent'),
                      _buildQuickTag(context, textTheme, '#Repairs'),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Motivational Image Card
                  Container(
                    width: double.infinity,
                    height: 180,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      image: const DecorationImage(
                        image: NetworkImage(
                            'https://lh3.googleusercontent.com/aida-public/AB6AXuDmESst7awV58PMSpUmgj-FMgy6NvEgS7WdHfSRruuL0ddqKkuVcWEnbucCfg87433zQHzubwZ0Hp3PMihkIApCNt-Ms2XHJJts2t_tStX6IyPrjgsoGjk6bkXxMIWQCk3cwB-fe1II8JWGPIcocnsNC7KGkd7IzoKrMR9ddlxqWYDXmO5-hjAIq_yP4Ggduj7X8FJZ1AGX06qVmsZdW9f1VzRfSr1ODWdYl7BJAaaAskhM8S3jDL113DG658X1EhmKUyybG1Qg6zg'),
                        fit: BoxFit.cover,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: AppTheme.primaryContainerOpacity12,
                          blurRadius: 16,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.7),
                          ],
                        ),
                      ),
                      padding: const EdgeInsets.all(24),
                      alignment: Alignment.bottomLeft,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Keep things running smoothly.',
                              style: textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white)),
                          const SizedBox(height: 4),
                          Text('Organization is the key to house harmony.',
                              style: textTheme.bodyMedium?.copyWith(
                                  color: Colors.white.withOpacity(0.9))),
                        ],
                      ),
                    ),
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

  Widget _buildSuggestionCard(BuildContext context, TextTheme textTheme,
      {required String title,
      required String subtitle,
      required IconData icon}) {
    final cs = Theme.of(context).colorScheme;
    return Expanded(
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.cardBackground(context),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: cs.outlineVariant.withValues(alpha: 0.6)),
            boxShadow: const [
              BoxShadow(
                color: AppTheme.primaryContainerOpacity8,
                blurRadius: 16,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: AppTheme.primaryContainerOpacity10,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppTheme.primaryContainer, size: 20),
              ),
              const SizedBox(height: 12),
              Text(title,
                  style: textTheme.labelMedium?.copyWith(
                      color: cs.onSurface, fontSize: 14)),
              const SizedBox(height: 4),
              Text(subtitle,
                  style: textTheme.labelSmall
                      ?.copyWith(color: cs.onSurfaceVariant)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickTag(BuildContext context, TextTheme textTheme, String text) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(9999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.cardBackground(context),
          borderRadius: BorderRadius.circular(9999),
          border: Border.all(color: cs.outlineVariant),
        ),
        child: Text(text,
            style: textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, IconData icon, String label,
      bool isActive, VoidCallback onTap) {
    final color =
        isActive ? AppTheme.primary : Theme.of(context).colorScheme.outline;
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
