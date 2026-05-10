import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'theme.dart';
import 'expense_detail_screen.dart';
import 'services/expense_service.dart';
import 'services/house_service.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  bool _isEqualSplit = true;
  bool _isLoading = false;
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  Future<void> _addExpense() async {
    final amount = double.tryParse(_amountController.text.trim());
    final description = _descriptionController.text.trim();
    if (amount == null || amount <= 0) {
      _showMessage('Please enter a valid amount.');
      return;
    }
    if (description.isEmpty) {
      _showMessage('Please enter an expense description.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final houseId = await HouseService.instance.getCurrentUserHouseId();
      final expenseId = await ExpenseService.instance.createExpense(
        houseId: houseId,
        amount: amount,
        description: description,
      );
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ExpenseDetailScreen(expenseId: expenseId),
        ),
      );
    } catch (e) {
      _showMessage(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final bottomPadding =
        MediaQuery.of(context).viewInsets.bottom; // Handle keyboard

    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset:
          false, // We'll manage padding manually for a smooth slide
      body: Stack(
        children: [
          // Blur backdrop
          Positioned.fill(
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: Container(
                  color: Colors.black.withValues(
                    alpha: cs.brightness == Brightness.dark ? 0.55 : 0.22,
                  ),
                ),
              ),
            ),
          ),

          // Bottom Sheet Card
          Align(
            alignment: Alignment.bottomCenter,
            child: AnimatedPadding(
              padding: EdgeInsets.only(bottom: bottomPadding),
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutQuad,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24).copyWith(
                    bottom: MediaQuery.of(context).padding.bottom + 24),
                decoration: BoxDecoration(
                  color: AppTheme.cardBackground(context),
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(32)),
                  border: Border.all(color: cs.outlineVariant),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 20,
                      offset: Offset(0, -4),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Add Expense',
                                  style: textTheme.headlineLarge),
                              const SizedBox(height: 4),
                              Text('Keep the dorm balance in sync',
                                  style: textTheme.bodyMedium
                                      ?.copyWith(color: cs.outline)),
                            ],
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: Icon(Icons.close, color: cs.outline),
                            style: IconButton.styleFrom(
                              backgroundColor: cs.surfaceContainer,
                              shape: const CircleBorder(),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Amount
                      Text('Amount',
                          style: textTheme.labelMedium?.copyWith(
                              color: AppTheme.schemeOnSurfaceVariant(context))),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _amountController,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        style: textTheme.headlineLarge?.copyWith(
                            fontSize: 36, color: cs.onSurface),
                        decoration: InputDecoration(
                          prefixIcon: Padding(
                            padding:
                                const EdgeInsets.only(left: 16.0, right: 8.0),
                            child: Text('\$',
                                style: textTheme.headlineLarge?.copyWith(
                                    color: AppTheme.primary, fontSize: 36)),
                          ),
                          prefixIconConstraints:
                              const BoxConstraints(minWidth: 0, minHeight: 0),
                          hintText: '0.00',
                          hintStyle: textTheme.headlineLarge?.copyWith(
                              color: cs.onSurfaceVariant.withValues(alpha: 0.6),
                              fontSize: 36),
                          filled: true,
                          fillColor: cs.surfaceContainerHighest,
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 24, horizontal: 16),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Description
                      Text('Description',
                          style: textTheme.labelMedium?.copyWith(
                              color: AppTheme.schemeOnSurfaceVariant(context))),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _descriptionController,
                        style: textTheme.bodyLarge?.copyWith(color: cs.onSurface),
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.edit_note, color: cs.outline),
                          hintText: 'What was it for?',
                          hintStyle: textTheme.bodyMedium?.copyWith(
                              color: cs.onSurfaceVariant.withValues(alpha: 0.65)),
                          filled: true,
                          fillColor: cs.surfaceContainerHighest,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 16),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  BorderSide(color: cs.outlineVariant)),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: cs.primary, width: 2)),
                        ),
                      ),
                      const SizedBox(height: 24),

                      Row(
                        children: [
                          // Paid By
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Paid by',
                                    style: textTheme.labelMedium?.copyWith(
                                        color: AppTheme.schemeOnSurfaceVariant(
                                            context))),
                                const SizedBox(height: 8),
                                DropdownButtonFormField<String>(
                                  initialValue: 'You (Primary)',
                                  items: [
                                    'You (Primary)',
                                    'Alex Rivera',
                                    'Jordan Smith',
                                    'Taylor Chen'
                                  ]
                                      .map((e) => DropdownMenuItem(
                                          value: e, child: Text(e)))
                                      .toList(),
                                  onChanged: (v) {},
                                  icon:
                                      Icon(Icons.expand_more, color: cs.outline),
                                  decoration: InputDecoration(
                                    prefixIcon:
                                        Icon(Icons.person, color: cs.outline),
                                    filled: true,
                                    fillColor: cs.surfaceContainerHighest,
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 14, horizontal: 16),
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide.none),
                                  ),
                                  style: textTheme.bodyMedium
                                      ?.copyWith(color: cs.onSurface),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),

                          // Smart Split
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Smart split',
                                    style: textTheme.labelMedium?.copyWith(
                                        color: AppTheme.schemeOnSurfaceVariant(
                                            context))),
                                const SizedBox(height: 8),
                                Container(
                                  height: 54, // Matches Dropdown height
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: cs.surfaceContainer,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: InkWell(
                                          onTap: () => setState(
                                              () => _isEqualSplit = true),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          child: Container(
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              color: _isEqualSplit
                                                  ? AppTheme.cardBackground(
                                                      context)
                                                  : Colors.transparent,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              boxShadow: _isEqualSplit
                                                  ? [
                                                      const BoxShadow(
                                                          color: Colors.black12,
                                                          blurRadius: 4)
                                                    ]
                                                  : null,
                                            ),
                                            child: Text('Equal',
                                                style: textTheme.labelMedium
                                                    ?.copyWith(
                                                        color: _isEqualSplit
                                                            ? AppTheme.primary
                                                            : cs.outline)),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: InkWell(
                                          onTap: () => setState(
                                              () => _isEqualSplit = false),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          child: Container(
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              color: !_isEqualSplit
                                                  ? AppTheme.cardBackground(
                                                      context)
                                                  : Colors.transparent,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              boxShadow: !_isEqualSplit
                                                  ? [
                                                      const BoxShadow(
                                                          color: Colors.black12,
                                                          blurRadius: 4)
                                                    ]
                                                  : null,
                                            ),
                                            child: Text('Custom',
                                                style: textTheme.labelMedium
                                                    ?.copyWith(
                                                        color: !_isEqualSplit
                                                            ? AppTheme.primary
                                                            : cs.outline)),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Split Info Box
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryContainerOpacity10,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: AppTheme.primaryContainerOpacity20),
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 60,
                              height: 28,
                              child: Stack(
                                children: const [
                                  Positioned(
                                      left: 0,
                                      child: CircleAvatar(
                                          radius: 14,
                                          backgroundColor: Colors.white,
                                          child: CircleAvatar(
                                              radius: 12,
                                              backgroundImage: NetworkImage(
                                                  'https://lh3.googleusercontent.com/aida-public/AB6AXuDpuwTNuxjtQA9TqZvifItkskVE9ur92MTjNw_OzUGTEOFio0rKQb2KlzQkLkW9MiqI-wijm9IsSB2ShD3y0TAvXF76w_cBtpF9cs4uVJoNw2CauVewceLFEhi5BT61bJ6cwKuRVQm_iiosYtAZtrKOgnknrLShsFtVARu57fVk7rycs7xPjEEfWzS7sv0HR8CeHB8Vr3C9rsGwAS17znnOa072vNO8-_1oKcMzp8ahIpUdNybjVbASCqHpgAG5IrLIgCSjH8S6xP8')))),
                                  Positioned(
                                      left: 16,
                                      child: CircleAvatar(
                                          radius: 14,
                                          backgroundColor: Colors.white,
                                          child: CircleAvatar(
                                              radius: 12,
                                              backgroundImage: NetworkImage(
                                                  'https://lh3.googleusercontent.com/aida-public/AB6AXuCb0U0dqpDsJ0K7MazuPoXAez7GcH9PCh6Sv4m3Aml8cWTheuKM4EqpiJZCnQFUZkTLe7BHy76qamP8-Uc_8V_StPtZsG4D-9gOP8Y345zXUXeAwBuJTv2ExID87iyg4p73TdkxkQEsPUjzPiHkgtTBRcW1DvgyJNsl06ziv7aHuci2YcjLyF2E8jXWsTIC_YuhwbwRN_wkCRZG5KNeRKZmaHeekdubLDFsNlNCYfuJvjX4TDvEkFyP6VEgpmy_m74oHqi_aJ6daog')))),
                                  Positioned(
                                      left: 32,
                                      child: CircleAvatar(
                                          radius: 14,
                                          backgroundColor: Colors.white,
                                          child: CircleAvatar(
                                              radius: 12,
                                              backgroundImage: NetworkImage(
                                                  'https://lh3.googleusercontent.com/aida-public/AB6AXuChUBgz9ucMUPVu7La2sJtcDiBSFbArCHfML6QbyAf8wlRPkQVLCeDsgqNLrn4EQknUpfod3rGpZGXixJfVOPz7zmJyuW1tyI_o7_rJjKCR_v2gWnCoBMHmd7hnBuqcdYTmSMcTp-Gz1t86lLT2soCT8HrUZyszm0TAFn_Giab1yo_MetGiktiF441A320l5ywZKvxk2xrnJAd3aTapUSsTh5OH_RrmkixnFbcdn2naEePMCI4dQ5_tls-8d9-SRSb9_hS6U4m0qDc')))),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                                child: Text(
                                    'Splitting equally among 4 roommates',
                                    style: textTheme.labelSmall?.copyWith(
                                        color: AppTheme.onPrimaryContainer))),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Submit Action
                      ElevatedButton(
                        onPressed: _isLoading ? null : _addExpense,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryContainer,
                          foregroundColor: AppTheme.onPrimaryContainer,
                          minimumSize: const Size(double.infinity, 56),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          elevation: 2,
                          shadowColor: AppTheme.primaryContainerOpacity40,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.add_circle, size: 24),
                            const SizedBox(width: 12),
                            Text(_isLoading ? 'Saving...' : 'Add Expense',
                                style: textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.onPrimaryContainer)),
                          ],
                        ),
                      ),
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
}
