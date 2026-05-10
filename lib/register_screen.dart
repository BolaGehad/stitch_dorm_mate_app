import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:firebase_auth/firebase_auth.dart';
import 'theme.dart';
import 'splash_screen.dart'; // Importing for BlueprintPainter reuse
import 'login_screen.dart';
import 'services/auth_service.dart';

class WavePainter extends CustomPainter {
  const WavePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.primaryContainerOpacity3
      ..style = PaintingStyle.fill;
    
    final path = Path();
    path.moveTo(0, size.height * 0.85);
    path.quadraticBezierTo(size.width * 0.25, size.height * 0.8, size.width * 0.5, size.height * 0.85);
    path.quadraticBezierTo(size.width * 0.75, size.height * 0.9, size.width, size.height * 0.85);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeTerms = false;
  bool _isLoading = false;
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Reusable method for filled text fields based on design deviation
  Widget _buildFilledInput({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onToggleVisibility,
    TextInputType keyboardType = TextInputType.text,
    TextInputAction textInputAction = TextInputAction.next,
  }) {
    final textTheme = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
          child: Text(
            label,
            style: textTheme.labelMedium?.copyWith(
                color: AppTheme.schemeOnSurfaceVariant(context)),
          ),
        ),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          style: textTheme.bodyLarge?.copyWith(
            color: cs.onSurface,
            letterSpacing: isPassword && obscureText ? 2.0 : 0.0,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: textTheme.bodyMedium?.copyWith(
              letterSpacing: isPassword ? 2.0 : 0.0,
            ),
            prefixIcon: Icon(icon),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      obscureText ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: onToggleVisibility,
                  )
                : null,
          ).applyDefaults(Theme.of(context).inputDecorationTheme),
        ),
      ],
    );
  }

  Future<void> _register() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      _showMessage('Please fill in all fields.');
      return;
    }
    if (!_isStrongPassword(password)) {
      _showMessage(
        'Password must be 8+ chars with upper, lower, number, and symbol.',
      );
      return;
    }
    if (password != confirmPassword) {
      _showMessage('Passwords do not match.');
      return;
    }
    if (!_agreeTerms) {
      _showMessage('Please agree to Terms of Service and Privacy Policy.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await AuthService.instance.register(
        fullName: name,
        email: email,
        password: password,
      );

      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginScreen(
            initialMessage:
                'Account created. Please verify your email, then login.',
          ),
        ),
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      // ignore: avoid_print
      print('AUTH ERROR CODE: ${e.code}');
      // ignore: avoid_print
      print('AUTH ERROR MESSAGE: ${e.message}');
      // ignore: avoid_print
      print('FULL ERROR: ${e.toString()}');
      _showMessage(_authErrorMessage(e));
    } catch (e) {
      final dynamic err = e;
      // ignore: avoid_print
      print('AUTH ERROR CODE: ${err.code}');
      // ignore: avoid_print
      print('AUTH ERROR MESSAGE: ${err.message}');
      // ignore: avoid_print
      print('FULL ERROR: ${e.toString()}');
      _showMessage('Something went wrong. Please try again.');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _authErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'network-request-failed':
        return 'فيه مشكلة في الاتصال بالنت دلوقتي. جرّب تاني.';
      case 'api-key-not-valid':
      case 'invalid-api-key':
        return 'فيه مشكلة في إعدادات الـ API Key. راجع قيود المفتاح (HTTP referrers) وجرب تاني.';
      case 'operation-not-allowed':
        return 'التسجيل بالإيميل/الباسورد مش متفعّل في Firebase Auth. فعّله من الـ Console.';
      case 'email-already-in-use':
        return 'This email is already in use.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Choose a stronger password.';
      default:
        return e.message ?? 'Registration failed. Please try again.';
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  bool _isStrongPassword(String password) {
    final hasMinLength = password.length >= 8;
    final hasUpper = RegExp(r'[A-Z]').hasMatch(password);
    final hasLower = RegExp(r'[a-z]').hasMatch(password);
    final hasDigit = RegExp(r'\d').hasMatch(password);
    final hasSpecial = RegExp(r'[!@#$%^&*(),.?":{}|<>_\-+=/\\\[\]~`]').hasMatch(password);
    return hasMinLength && hasUpper && hasLower && hasDigit && hasSpecial;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppTheme.schemeSurface(context),
      body: Stack(
        children: [
          // Level 1: Background Blueprint Grid Layer
          Positioned.fill(
            child: CustomPaint(
              painter: BlueprintPainter(brightness: Theme.of(context).brightness),
            ),
          ),

          // Level 1.5: Blueprint Watermark Decor (Top Right) & Bottom Wave
          Positioned(
            top: size.height * 0.1,
            right: -size.width * 0.05,
            child: Transform.rotate(
              angle: -15 * math.pi / 180,
              child: const Icon(
                Icons.architecture, // Placeholder for the SVG grid watermark
                size: 320,
                color: AppTheme.primaryOpacity4,
              ),
            ),
          ),
          const Positioned.fill(
            child: CustomPaint(
              painter: WavePainter(),
            ),
          ),

          // Level 2: Scrollable Main Content
          SafeArea(
            child: Column(
              children: [
                // Top Navigation Anchor
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back,
                            color: AppTheme.schemeOnSurfaceVariant(context)),
                        onPressed: () => Navigator.pop(context),
                        style: IconButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(40, 40),
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.home_work, color: AppTheme.primaryContainer),
                      const SizedBox(width: 8),
                      Text(
                        'Dorm Mate', 
                        style: textTheme.headlineMedium?.copyWith(
                          color: AppTheme.primary, 
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const Spacer(),
                      const SizedBox(width: 40), // Balances the back button
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Welcome Header
                        Text('Create your account', style: textTheme.headlineLarge),
                        const SizedBox(height: 8),
                        Text(
                          'Join your roommates and start organizing your shared space today.',
                          style: textTheme.bodyMedium?.copyWith(
                              color: AppTheme.schemeOnSurfaceVariant(context)),
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // Registration Card
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
                            children: [
                              _buildFilledInput(
                                label: 'Full Name',
                                hint: 'Alex Johnson',
                                icon: Icons.person,
                                controller: _nameController,
                              ),
                              const SizedBox(height: 16),
                              _buildFilledInput(
                                label: 'University Email',
                                hint: 'alex@university.edu',
                                icon: Icons.school,
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                              ),
                              const SizedBox(height: 16),
                              _buildFilledInput(
                                label: 'Password', 
                                hint: '••••••••', 
                                icon: Icons.lock, 
                                controller: _passwordController,
                                isPassword: true, 
                                obscureText: _obscurePassword,
                                onToggleVisibility: () => setState(() => _obscurePassword = !_obscurePassword),
                              ),
                              const SizedBox(height: 16),
                              _buildFilledInput(
                                label: 'Confirm Password', 
                                hint: '••••••••', 
                                icon: Icons.lock_reset, 
                                controller: _confirmPasswordController,
                                isPassword: true, 
                                obscureText: _obscureConfirmPassword,
                                onToggleVisibility: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                                textInputAction: TextInputAction.done,
                              ),
                              
                              const SizedBox(height: 24),
                              
                              // Terms and Privacy Checkbox
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: Checkbox(
                                      value: _agreeTerms,
                                      onChanged: (val) => setState(() => _agreeTerms = val ?? false),
                                      activeColor: AppTheme.primaryContainer,
                                      side: BorderSide(color: cs.outlineVariant),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: RichText(
                                      text: TextSpan(
                                        style: textTheme.labelMedium?.copyWith(
                                            color: AppTheme.schemeOnSurfaceVariant(context),
                                            fontWeight: FontWeight.w400),
                                        children: [
                                          const TextSpan(text: 'I agree to the '),
                                          TextSpan(text: 'Terms of Service', style: textTheme.labelMedium?.copyWith(color: AppTheme.primary, fontWeight: FontWeight.w600)),
                                          const TextSpan(text: ' and '),
                                          TextSpan(text: 'Privacy Policy', style: textTheme.labelMedium?.copyWith(color: AppTheme.primary, fontWeight: FontWeight.w600)),
                                          const TextSpan(text: '.'),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              
                              const SizedBox(height: 24),
                              
                              // Primary CTA
                              ElevatedButton(
                                onPressed: _isLoading ? null : _register,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primaryContainer,
                                  foregroundColor: Colors.white,
                                  minimumSize: const Size(double.infinity, 56),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  elevation: 2,
                                  shadowColor: AppTheme.primaryContainerOpacity40,
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
                                      const Icon(Icons.arrow_forward, size: 20),
                                      const SizedBox(width: 8),
                                    ],
                                    Text(
                                      _isLoading ? 'Creating account...' : 'Create Account',
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
                        
                        // Divider
                        Row(
                          children: [
                            Expanded(child: Divider(color: cs.outlineVariant)),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text('OR SIGN UP WITH',
                                  style: textTheme.labelSmall?.copyWith(
                                      letterSpacing: 1.5, color: cs.outline)),
                            ),
                            Expanded(child: Divider(color: cs.outlineVariant)),
                          ],
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Secondary Options (Social)
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {},
                                icon: Image.network(
                                  'https://lh3.googleusercontent.com/aida-public/AB6AXuBlTvi330AHARckrQom6yivl9Dd8f-CYzeUiPrr0dNCDejn8_G-Cnj9aUYpTLk1WBNku2LEqK1gUhG2zEcvNIkcDoUigsAP-khha5YYTDDFucqfazOCDUs09p6_-uOpDGzZD-eWlpFIzCnoAHajhPfd7NkfXFxj4rGdOvEUVXQpyrBN2jMEwFjsz3c2lm6rOUN7aPxipEL4Q9hE29XtkoXkNKf2Z4B5vs8RxcOSB0M9hBRO-0ZQUkgR1-7KAc2pqr8dlURJMo4aRi4',
                                  width: 16, 
                                  height: 16,
                                ),
                                label: Text('Google',
                                    style: textTheme.labelMedium?.copyWith(
                                        color: AppTheme.schemeOnSurfaceVariant(
                                            context))),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  side: BorderSide(color: cs.outlineVariant),
                                  backgroundColor: AppTheme.cardBackground(context),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {},
                                icon: Icon(Icons.apple,
                                    size: 20,
                                    color: AppTheme.schemeOnSurfaceVariant(context)),
                                label: Text('Apple',
                                    style: textTheme.labelMedium?.copyWith(
                                        color: AppTheme.schemeOnSurfaceVariant(
                                            context))),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  side: BorderSide(color: cs.outlineVariant),
                                  backgroundColor: AppTheme.cardBackground(context),
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // Footer Auth Prompt
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Already have an account?',
                                style: textTheme.bodyMedium?.copyWith(
                                    color: AppTheme.schemeOnSurfaceVariant(
                                        context))),
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text('Sign In', style: textTheme.bodyMedium?.copyWith(color: AppTheme.primary, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}