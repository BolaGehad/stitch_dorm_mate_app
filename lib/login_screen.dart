import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:firebase_auth/firebase_auth.dart';
import 'theme.dart';
import 'splash_screen.dart'; // Importing for BlueprintPainter reuse
import 'register_screen.dart';
import 'forgot_password_screen.dart';
import 'auth_gate.dart';
import 'services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, this.initialMessage});

  final String? initialMessage;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _isLoading = false;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _showMessage(widget.initialMessage!);
      });
    }
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showMessage('Please enter your email and password.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await AuthService.instance.signIn(
        email: email,
        password: password,
      );

      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const AuthGate()),
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
        return 'تسجيل الدخول بالإيميل/الباسورد مش متفعّل في Firebase Auth. فعّله من الـ Console.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Invalid email or password.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'email-not-verified':
        return 'Email is not verified. We sent a new verification link.';
      default:
        return e.message ?? 'Login failed. Please try again.';
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: AppTheme.schemeSurface(context),
      body: Stack(
        children: [
          // Background Blueprint Grid Layer
          Positioned.fill(
            child: CustomPaint(
              painter: BlueprintPainter(brightness: Theme.of(context).brightness),
            ),
          ),

          // Scrollable Content
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: 32.0),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight -
                          64.0, // Accounts for vertical padding
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Spacer(),

                          // Header Cluster: Logo
                          Transform.rotate(
                            angle: -3 * math.pi / 180,
                            child: Container(
                              width: 64,
                              height: 64,
                              decoration: const BoxDecoration(
                                color: AppTheme.primaryContainer,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(16)),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.primaryContainerOpacity12,
                                    blurRadius: 20,
                                    offset: Offset(0, 4),
                                  )
                                ],
                              ),
                              child: const Icon(Icons.home_work,
                                  color: Colors.white, size: 32),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Header Cluster: Text
                          Text(
                            'Welcome to Dorm Mate',
                            style:
                                textTheme.headlineLarge?.copyWith(fontSize: 28),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Your shared living, perfectly synchronized.',
                            style: textTheme.bodyMedium?.copyWith(
                                color: AppTheme.schemeOnSurfaceVariant(context)),
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 32),

                          // Main Form Card
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
                                // Email Input
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
                                  textInputAction: TextInputAction.next,
                                  style: textTheme.bodyLarge?.copyWith(
                                      color: cs.onSurface),
                                  decoration: InputDecoration(
                                    hintText: 'name@university.edu',
                                    prefixIcon:
                                        const Icon(Icons.alternate_email),
                                  ).applyDefaults(
                                      Theme.of(context).inputDecorationTheme),
                                ),

                                const SizedBox(height: 16),

                                // Password Input
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 4.0, bottom: 8.0),
                                  child: Text('Password',
                                      style: textTheme.labelMedium?.copyWith(
                                          color: AppTheme.schemeOnSurfaceVariant(
                                              context))),
                                ),
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: _obscurePassword,
                                  textInputAction: TextInputAction.done,
                                  onFieldSubmitted: (_) =>
                                      _isLoading ? null : _login(),
                                  style: textTheme.bodyLarge?.copyWith(
                                      color: cs.onSurface,
                                      letterSpacing: _obscurePassword ? 2 : 0),
                                  decoration: InputDecoration(
                                    hintText: '••••••••',
                                    hintStyle: textTheme.bodyMedium?.copyWith(
                                      letterSpacing: 2.0,
                                    ),
                                    prefixIcon: const Icon(Icons.lock),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword
                                            ? Icons.visibility
                                            : Icons.visibility_off,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscurePassword = !_obscurePassword;
                                        });
                                      },
                                    ),
                                  ).applyDefaults(
                                      Theme.of(context).inputDecorationTheme),
                                ),

                                const SizedBox(height: 12),

                                // Options Row (Remember me & Forgot Password)
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: Checkbox(
                                        value: _rememberMe,
                                        onChanged: (val) => setState(
                                            () => _rememberMe = val ?? false),
                                        activeColor: AppTheme.primaryContainer,
                                        side: BorderSide(
                                            color: cs.outlineVariant),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(4)),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text('Remember me',
                                        style: textTheme.bodyMedium?.copyWith(
                                            color: AppTheme.schemeOnSurfaceVariant(
                                                context))),
                                    const Spacer(),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const ForgotPasswordScreen()),
                                        );
                                      },
                                      style: TextButton.styleFrom(
                                        padding: EdgeInsets.zero,
                                        minimumSize: Size.zero,
                                        tapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      child: Text('Forgot Password?',
                                          style: textTheme.labelMedium
                                              ?.copyWith(
                                                  color: AppTheme
                                                      .primaryContainer)),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 24),

                                // Login Button
                                ElevatedButton(
                                  onPressed: _isLoading ? null : _login,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.primaryContainer,
                                    foregroundColor: Colors.white,
                                    minimumSize:
                                        const Size(double.infinity, 56),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
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
                                        const Icon(Icons.arrow_forward, size: 20),
                                        const SizedBox(width: 8),
                                      ],
                                      Text(
                                        _isLoading ? 'Logging in...' : 'Login',
                                        style: textTheme.bodyLarge?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 24),

                                // Divider Row
                                Row(
                                  children: [
                                    Expanded(
                                        child: Divider(color: cs.outlineVariant)),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16),
                                      child: Text('NEW TO THE HOUSE?',
                                          style: textTheme.labelSmall?.copyWith(
                                              letterSpacing: 1.5,
                                              color: cs.outline)),
                                    ),
                                    Expanded(
                                        child: Divider(color: cs.outlineVariant)),
                                  ],
                                ),

                                const SizedBox(height: 24),

                                // Create Account Button
                                OutlinedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const RegisterScreen()),
                                    );
                                  },
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppTheme.primaryContainer,
                                    side: const BorderSide(
                                        color:
                                            AppTheme.primaryContainerOpacity20,
                                        width: 2),
                                    minimumSize:
                                        const Size(double.infinity, 56),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    backgroundColor:
                                        AppTheme.cardBackground(context),
                                  ),
                                  child: Text('Create Account',
                                      style: textTheme.bodyLarge?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.primaryContainer)),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 32),

                          // Partner Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: cs.surfaceContainer.withValues(alpha: 0.55),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: cs.outlineVariant),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Image.network(
                                  'https://lh3.googleusercontent.com/aida-public/AB6AXuDg0zuVpvhTzfmPpm5dvDXv0bLjyqksFUw1iDRMXbmN09ESaspN8oZavrlCHKEtb50IWw9OidT31QA2PV_fsYhI_mP1vYD7mQRuENSrZMWXGOgqdHf-XLd_6mPXLkTgEzIdw5CtDBMGh03U115vHp3vojA0x3tdNSDyL1e8bhUKgTBHQWA5ff_gJZpnt6p84cZf0_Du8SlNV7t16wjf1RDjd3yRagqXzEXmQJh7Cix15FmPOHRtuNZQfGFIdjoG6xaMuYGLV2e_16Q',
                                  width: 24,
                                  height: 24,
                                ),
                                const SizedBox(width: 8),
                                Text('Partnered with 200+ Campuses',
                                    style: textTheme.labelSmall?.copyWith(
                                        color: AppTheme.schemeOnSurfaceVariant(
                                            context))),
                              ],
                            ),
                          ),

                          const Spacer(),

                          // Footer Links
                          Padding(
                            padding:
                                const EdgeInsets.only(top: 32.0, bottom: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Privacy Policy',
                                    style: textTheme.labelSmall?.copyWith(
                                        color: AppTheme.schemeOnSurfaceVariant(
                                            context))),
                                const SizedBox(width: 12),
                                Container(
                                    width: 4,
                                    height: 4,
                                    decoration: BoxDecoration(
                                        color: cs.outlineVariant,
                                        shape: BoxShape.circle)),
                                const SizedBox(width: 12),
                                Text('Terms of Service',
                                    style: textTheme.labelSmall?.copyWith(
                                        color: AppTheme.schemeOnSurfaceVariant(
                                            context))),
                                const SizedBox(width: 12),
                                Container(
                                    width: 4,
                                    height: 4,
                                    decoration: BoxDecoration(
                                        color: cs.outlineVariant,
                                        shape: BoxShape.circle)),
                                const SizedBox(width: 12),
                                Text('Help Center',
                                    style: textTheme.labelSmall?.copyWith(
                                        color: AppTheme.schemeOnSurfaceVariant(
                                            context))),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
