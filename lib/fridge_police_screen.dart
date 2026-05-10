import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'theme.dart';
import 'splash_screen.dart';
import 'services/game_center_service.dart';

class FridgePoliceScreen extends StatefulWidget {
  const FridgePoliceScreen({super.key});

  @override
  State<FridgePoliceScreen> createState() => _FridgePoliceScreenState();
}

class _FridgePoliceScreenState extends State<FridgePoliceScreen> {
  final List<Map<String, dynamic>> _checklist = [
    {'title': 'Throw away expired milk/dairy', 'done': false},
    {'title': 'Check leftovers (older than 3 days)', 'done': false},
    {'title': 'Wipe down sticky shelves', 'done': false},
    {'title': 'Organize condiments in the door', 'done': false},
  ];

  int get _checkedCount =>
      _checklist.where((item) => item['done'] == true).length;

  bool _isSubmitting = false;

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
              title: Text('Fridge Police', style: textTheme.headlineMedium?.copyWith(color: AppTheme.primary)),
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 32, bottom: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Inspection Checklist', style: textTheme.headlineMedium),
                  const SizedBox(height: 16),
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
                    child: Theme(
                      data: Theme.of(context).copyWith(
                        checkboxTheme: CheckboxThemeData(
                          fillColor: WidgetStateProperty.resolveWith((states) {
                            if (states.contains(WidgetState.selected)) {
                              return AppTheme.primaryContainer;
                            }
                            return null;
                          }),
                          checkColor: WidgetStateProperty.all(Colors.white),
                        ),
                      ),
                      child: Column(
                        children: _checklist.asMap().entries.map((entry) {
                          final index = entry.key;
                          final item = entry.value;
                          return Column(
                            children: [
                              CheckboxListTile(
                                value: item['done'] as bool,
                                onChanged: (val) => setState(
                                    () => _checklist[index]['done'] = val ?? false),
                                title: Text(item['title'] as String,
                                    style: textTheme.bodyLarge),
                                controlAffinity: ListTileControlAffinity.leading,
                              ),
                              if (index < _checklist.length - 1)
                                const Divider(
                                    height: 1,
                                    color: AppTheme.surfaceContainerHighest),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _checkedCount >= 1
                        ? () async {
                            if (_isSubmitting) return;
                            setState(() => _isSubmitting = true);
                            try {
                              final checkedTitles = _checklist
                                  .where((e) => e['done'] == true)
                                  .map((e) => e['title'] as String)
                                  .toList();
                              await GameCenterService.instance.reportFridgeInspection(
                                checkedItems: checkedTitles,
                              );
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Fridge report saved — thanks for clearing what you checked.')),
                              );
                              Navigator.pop(context);
                            } catch (e) {
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    e.toString().replaceFirst('Exception: ', ''),
                                  ),
                                ),
                              );
                            } finally {
                              if (mounted) setState(() => _isSubmitting = false);
                            }
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 56),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Report Area Clear'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
