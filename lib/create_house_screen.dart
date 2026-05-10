import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'theme.dart';
import 'splash_screen.dart'; // Importing for BlueprintPainter reuse
import 'dormy_ai_screen.dart';
import 'dashboard_screen.dart';
import 'services/house_service.dart';

class CreateHouseScreen extends StatefulWidget {
  const CreateHouseScreen({super.key});

  @override
  State<CreateHouseScreen> createState() => _CreateHouseScreenState();
}

class _CreateHouseScreenState extends State<CreateHouseScreen> {
  String _selectedTheme = 'eco'; // Default selected theme
  String _selectedCurrency = 'USD';
  bool _isLoading = false;
  final _houseNameController = TextEditingController();
  final _memberLimitController = TextEditingController(text: '4');

  Future<void> _createHouse() async {
    final houseName = _houseNameController.text.trim();
    final memberLimit = int.tryParse(_memberLimitController.text.trim());

    if (houseName.isEmpty) {
      _showMessage('Please enter a house name.');
      return;
    }
    if (memberLimit == null || memberLimit < 2) {
      _showMessage('Member limit must be at least 2.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await HouseService.instance.createHouse(
        houseName: houseName,
        memberLimit: memberLimit,
        currency: _selectedCurrency,
        theme: _selectedTheme,
      );
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const DashboardScreen()),
        (route) => false,
      );
    } catch (e) {
      _showMessage(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    _houseNameController.dispose();
    _memberLimitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppTheme.schemeSurface(context),
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: AppBar(
              automaticallyImplyLeading:
                  false, // We provide our own back button
              backgroundColor: AppTheme.frostedBarBg(context),
              elevation: 0,
              titleSpacing: 0, // Remove default padding
              title: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: AppTheme.outline),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Dorm Mate',
                    style: textTheme.headlineMedium?.copyWith(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w800,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(1),
                child: Container(
                    color: AppTheme.schemeContainerHighest(context), height: 1),
              ),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(painter: BlueprintPainter(brightness: Theme.of(context).brightness)),
          ),
          SafeArea(
            bottom: false,
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0)
                    .copyWith(top: 24, bottom: 100),
                child: Column(
                  children: [
                    // Hero Section
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryContainerOpacity20,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(Icons.home_work,
                          color: AppTheme.primary, size: 40, fill: 1.0),
                    ),
                    const SizedBox(height: 16),
                    Text('Build Your Sanctuary',
                        style: textTheme.headlineLarge),
                    const SizedBox(height: 8),
                    Text(
                      'Create a shared space to manage\nchores, budgets, and groceries with\nease.',
                      style: textTheme.bodyMedium
                          ?.copyWith(color: AppTheme.onSurfaceVariant),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    // Main Form Card
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppTheme.cardBackground(context),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                            color: AppTheme.schemeOutlineVariant(context)
                                .withValues(alpha: 0.35)),
                        boxShadow: const [
                          BoxShadow(
                            color: AppTheme.primaryContainerOpacity8,
                            blurRadius: 20,
                            offset: Offset(0, 4),
                          )
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTextField(context, textTheme,
                              label: 'HOUSE NAME',
                              hint: 'e.g. The Sunny Side Loft',
                              icon: Icons.edit,
                              controller: _houseNameController),
                          const SizedBox(height: 4),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              'This is how your roommates will find the house.',
                              style: textTheme.labelSmall
                                  ?.copyWith(color: AppTheme.outline),
                            ),
                          ),
                          const SizedBox(height: 24),
                          _buildTextField(context, textTheme,
                              label: 'MEMBER LIMIT',
                              icon: Icons.groups,
                              keyboardType: TextInputType.number,
                              controller: _memberLimitController),
                          const SizedBox(height: 24),
                          _buildDropdownField(context, textTheme),
                          const SizedBox(height: 24),
                          _buildThemeSelector(textTheme),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: _isLoading ? null : _createHouse,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryContainer,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(double.infinity, 56),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              elevation: 2,
                              shadowColor: AppTheme.primaryContainerOpacity40,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(_isLoading ? 'Creating...' : 'Create House',
                                    style: textTheme.bodyLarge?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white)),
                                const SizedBox(width: 8),
                                const Icon(Icons.chevron_right, size: 20),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Feature Callout Cards
                    Row(
                      children: [
                        _buildFeatureCard(context, textTheme,
                            icon: Icons.group_add,
                            title: 'Invite-only',
                            subtitle: 'Keep your space private and secure.'),
                        const SizedBox(width: 16),
                        _buildFeatureCard(context, textTheme,
                            icon: Icons.account_balance,
                            title: 'Shared Wallet',
                            subtitle: 'Automate rent and utility splits.'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 24,
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
              child: const Icon(Icons.smart_toy,
                  color: AppTheme.onPrimaryContainer, size: 28, fill: 1.0),
            ),
          ),
        ],
      ),
    );
  }

  // Helper widgets to keep build method clean
  Widget _buildTextField(BuildContext context, TextTheme textTheme,
      {required String label,
      String? hint,
      required IconData icon,
      required TextEditingController controller,
      TextInputType? keyboardType}) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: textTheme.labelSmall?.copyWith(
                color: cs.outline, letterSpacing: 1.5)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          style: textTheme.bodyLarge?.copyWith(color: cs.onSurface),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: textTheme.bodyLarge?.copyWith(color: cs.onSurfaceVariant),
            suffixIcon: Icon(icon, color: cs.outlineVariant),
            filled: true,
            fillColor: cs.surfaceContainerHighest,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: cs.outlineVariant),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: cs.outlineVariant),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: cs.primary, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField(BuildContext context, TextTheme textTheme) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('PRIMARY CURRENCY',
            style: textTheme.labelSmall
                ?.copyWith(color: cs.outline, letterSpacing: 1.5)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: _selectedCurrency,
          items: const [
            DropdownMenuItem(value: 'USD', child: Text('USD - US Dollar')),
            DropdownMenuItem(value: 'EUR', child: Text('EUR - Euro')),
            DropdownMenuItem(value: 'GBP', child: Text('GBP - British Pound')),
          ],
          onChanged: (value) {
            if (value == null) return;
            setState(() => _selectedCurrency = value);
          },
          decoration: InputDecoration(
            suffixIcon: Icon(Icons.payments, color: cs.outlineVariant),
            filled: true,
            fillColor: cs.surfaceContainerHighest,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: cs.outlineVariant),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: cs.outlineVariant),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: cs.primary, width: 2),
            ),
          ),
          style: textTheme.bodyLarge?.copyWith(color: cs.onSurface),
          icon: const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildThemeSelector(TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('HOUSE THEME',
            style: textTheme.labelSmall
                ?.copyWith(color: AppTheme.outline, letterSpacing: 1.5)),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _themeOption(icon: Icons.eco, value: 'eco'),
            _themeOption(icon: Icons.coffee, value: 'coffee'),
            _themeOption(icon: Icons.rocket_launch, value: 'rocket'),
          ],
        ),
      ],
    );
  }

  Widget _themeOption({required IconData icon, required String value}) {
    final isSelected = _selectedTheme == value;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: InkWell(
          onTap: () => setState(() => _selectedTheme = value),
          borderRadius: BorderRadius.circular(12),
          child: AspectRatio(
            aspectRatio: 1,
            child: Container(
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.surfaceContainerHigh
                    : AppTheme.surfaceContainerLowest,
                border: Border.all(
                  color: isSelected
                      ? AppTheme.primaryContainer
                      : AppTheme.outlineVariant,
                  width: isSelected ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon,
                  color: isSelected ? AppTheme.primary : AppTheme.outline,
                  size: 28),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard(BuildContext context, TextTheme textTheme,
      {required IconData icon,
      required String title,
      required String subtitle}) {
    final cs = Theme.of(context).colorScheme;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cs.surfaceContainer.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cs.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppTheme.primary, size: 24),
            const SizedBox(height: 8),
            Text(title,
                style: textTheme.labelMedium
                    ?.copyWith(color: cs.onSurface)),
            const SizedBox(height: 4),
            Text(subtitle,
                style: textTheme.labelSmall?.copyWith(
                    color: cs.onSurfaceVariant, height: 1.2)),
          ],
        ),
      ),
    );
  }
}
