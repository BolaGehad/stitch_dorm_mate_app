import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:ui' as ui;
import 'theme.dart';
import 'splash_screen.dart';
import 'forgot_password_screen.dart';
import 'services/game_center_service.dart';

class SecurityPrivacyScreen extends StatefulWidget {
  const SecurityPrivacyScreen({super.key});

  @override
  State<SecurityPrivacyScreen> createState() => _SecurityPrivacyScreenState();
}

class _SecurityPrivacyScreenState extends State<SecurityPrivacyScreen> {
  String _profileVisibility = 'Housemates Only';
  bool _biometricEnabled = true;
  bool _analyticsSharing = false;

  Future<void> _updateSetting(Map<String, dynamic> fields) async {
    try {
      await GameCenterService.instance.updateCurrentUserSettings(fields);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
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
              title: Text('Security & Privacy', style: textTheme.headlineMedium?.copyWith(color: AppTheme.primary)),
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
            child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: GameCenterService.instance.watchCurrentUserSettings(),
              builder: (context, snapshot) {
                final data = snapshot.data?.data();
                final profileVisibility = (data?['profileVisibility'] as String?) ?? _profileVisibility;
                final biometricEnabled = (data?['biometricEnabled'] as bool?) ?? _biometricEnabled;
                final analyticsSharing = (data?['analyticsSharing'] as bool?) ?? _analyticsSharing;

                return ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    ListTile(
                      leading: const Icon(Icons.password, color: AppTheme.primary),
                      title: const Text('Password'),
                      subtitle: const Text('Reset your password'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
                        );
                      },
                    ),
                    const Divider(),
                    SwitchListTile(
                      value: biometricEnabled,
                      onChanged: (v) {
                        setState(() => _biometricEnabled = v);
                        _updateSetting({'biometricEnabled': v});
                      },
                      title: const Text('Biometric Login'),
                    ),
                    SwitchListTile(
                      value: analyticsSharing,
                      onChanged: (v) {
                        setState(() => _analyticsSharing = v);
                        _updateSetting({'analyticsSharing': v});
                      },
                      title: const Text('Analytics Sharing'),
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.visibility_off, color: AppTheme.primary),
                      title: const Text('Profile Visibility'),
                      trailing: DropdownButton<String>(
                        value: profileVisibility,
                        items: ['Everyone', 'Housemates Only', 'Private']
                            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
                        onChanged: (v) {
                          if (v != null) {
                            setState(() => _profileVisibility = v);
                            _updateSetting({'profileVisibility': v});
                          }
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
