import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'theme.dart';
import 'splash_screen.dart';
import 'services/game_center_service.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  final List<Map<String, dynamic>> _paymentMethods = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMethods();
  }

  Future<void> _loadMethods() async {
    try {
      final loaded = await GameCenterService.instance.loadPaymentMethods();
      if (!mounted) return;
      setState(() {
        _paymentMethods
          ..clear()
          ..addAll(loaded);
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _persistMethods() async {
    await GameCenterService.instance.savePaymentMethods(_paymentMethods);
  }

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
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: AppTheme.onSurfaceVariant),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text('Payment Methods', style: textTheme.headlineMedium?.copyWith(color: AppTheme.primary)),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
              child: CustomPaint(
                  painter: BlueprintPainter(
                      brightness: Theme.of(context).brightness))),
          SafeArea(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      if (_paymentMethods.isEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 24, bottom: 12),
                          child: Text(
                            'No payment methods yet.',
                            style: textTheme.bodyLarge?.copyWith(
                              color: AppTheme.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ..._paymentMethods.map((method) => Card(
                            child: ListTile(
                              leading: const Icon(Icons.credit_card, color: AppTheme.primary),
                              title: Text(method['title']),
                              subtitle: Text(method['details']),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () async {
                                  setState(() {
                                    _paymentMethods.removeWhere((m) => m['id'] == method['id']);
                                  });
                                  await _persistMethods();
                                },
                              ),
                            ),
                          )),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () async {
                          final holderController = TextEditingController();
                          final last4Controller = TextEditingController();
                          final saved = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Add card'),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextField(
                                    controller: holderController,
                                    decoration: const InputDecoration(labelText: 'Cardholder name'),
                                  ),
                                  TextField(
                                    controller: last4Controller,
                                    decoration: const InputDecoration(labelText: 'Last 4 digits'),
                                    keyboardType: TextInputType.number,
                                    maxLength: 4,
                                  ),
                                ],
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
                          if (saved != true) return;
                          final holder = holderController.text.trim();
                          final last4 = last4Controller.text.trim();
                          if (holder.isEmpty || last4.length != 4) {
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please enter valid values.')),
                            );
                            return;
                          }

                          setState(() {
                            _paymentMethods.add({
                              'id': DateTime.now().millisecondsSinceEpoch.toString(),
                              'type': 'Card',
                              'title': 'Card',
                              'details': '**** **** **** $last4',
                              'holder': holder,
                              'expires': 'N/A',
                              'isDefault': false,
                            });
                          });
                          await _persistMethods();
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Add Payment Method'),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
