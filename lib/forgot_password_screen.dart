import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:firebase_auth/firebase_auth.dart';
import 'theme.dart';
import 'splash_screen.dart'; // Importing for BlueprintPainter reuse
import 'dormy_ai_screen.dart';
import 'services/auth_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _isLoading = false;

  Future<void> _sendResetLink() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      _showMessage('Please enter your email.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await AuthService.instance.sendPasswordResetEmail(email: email);
      _showMessage('Password reset email sent. Check your inbox.');
    } on FirebaseAuthException catch (e) {
      _showMessage(e.message ?? 'Failed to send reset email.');
    } catch (_) {
      _showMessage('Something went wrong. Please try again.');
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
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: AppTheme.schemeSurface(context),
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: AppBar(
              backgroundColor: AppTheme.frostedBarBg(context),
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: AppTheme.primary),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                'Dormy',
                style: textTheme.headlineMedium?.copyWith(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
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
            child: LayoutBuilder(builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.only(
                    left: 20.0, right: 20.0, top: 24.0, bottom: 80.0),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight -
                        104.0, // Accounts for vertical padding
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),

                        // Feature Icon
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryContainerOpacity10,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: const [
                              BoxShadow(
                                color: AppTheme.primaryContainerOpacity8,
                                blurRadius: 20,
                                offset: Offset(0, 4),
                              )
                            ],
                          ),
                          alignment: Alignment.center,
                          child: const Icon(Icons.lock_reset,
                              color: AppTheme.primary, size: 32),
                        ),

                        const SizedBox(height: 24),

                        // Header Texts
                        Text('Forgot Password', style: textTheme.headlineLarge),
                        const SizedBox(height: 8),
                        Text(
                          "Enter your email address and we'll send\nyou instructions to reset your\npassword.",
                          style: textTheme.bodyMedium?.copyWith(
                              color: AppTheme.schemeOnSurfaceVariant(context)),
                        ),

                        const SizedBox(height: 32),

                        // Form Card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: AppTheme.cardBackground(context),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: cs.outlineVariant),
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
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 4.0, bottom: 8.0),
                                child: Text('University Email',
                                    style: textTheme.labelMedium?.copyWith(
                                        color: AppTheme.schemeOnSurfaceVariant(
                                            context))),
                              ),
                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.done,
                                style: textTheme.bodyLarge?.copyWith(
                                    color: cs.onSurface),
                                decoration: InputDecoration(
                                  hintText: 'name@university.edu',
                                  prefixIcon: const Icon(Icons.school),
                                ).applyDefaults(
                                    Theme.of(context).inputDecorationTheme),
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton(
                                onPressed: _isLoading ? null : _sendResetLink,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primaryContainer,
                                  foregroundColor: Colors.white,
                                  minimumSize: const Size(double.infinity, 56),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                  elevation: 2,
                                  shadowColor:
                                      AppTheme.primaryContainerOpacity40,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (_isLoading) ...[
                                      const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                    ] else ...[
                                      const Icon(Icons.send, size: 20),
                                      const SizedBox(width: 8),
                                    ],
                                    Text(
                                      _isLoading
                                          ? 'Sending...'
                                          : 'Send Reset Link',
                                      style: textTheme.bodyLarge?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Back to Login
                        Center(
                          child: TextButton.icon(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.arrow_back,
                                color: AppTheme.primary, size: 18),
                            label: Text('Back to Login',
                                style: textTheme.labelMedium
                                    ?.copyWith(color: AppTheme.primary)),
                          ),
                        ),

                        const Spacer(),

                        // Footer Version
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: Text('Dorm Mate System v2.4.0',
                                style: textTheme.labelSmall
                                    ?.copyWith(color: AppTheme.outlineVariant)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),

          // Floating Dormy AI Button
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
              child: const Icon(Icons.smart_toy, color: Colors.white, size: 28),
            ),
          ),
        ],
      ),
    );
  }
}
