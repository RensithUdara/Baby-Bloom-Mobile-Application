import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../data/firebase_content_repository.dart';
import '../theme/app_theme.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _signup = false;
  bool _loading = false;
  bool _hidePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      final auth = FirebaseAuth.instance;
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      if (_signup) {
        final credential = await auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        final displayName = _nameController.text.trim();
        if (displayName.isNotEmpty) {
          await credential.user?.updateDisplayName(displayName);
        }
        await FirebaseContentRepository.saveUserAccount(
          displayName: displayName,
        );
      } else {
        await auth.signInWithEmailAndPassword(email: email, password: password);
        await FirebaseContentRepository.saveUserAccount();
      }
    } on FirebaseAuthException catch (error) {
      _showError(_authMessage(error));
    } catch (_) {
      _showError('Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _authMessage(FirebaseAuthException error) {
    switch (error.code) {
      case 'email-already-in-use':
        return 'This email already has an account.';
      case 'invalid-email':
        return 'Enter a valid email address.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Email or password is incorrect.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'network-request-failed':
        return 'Check your internet connection and try again.';
      default:
        return error.message ?? 'Authentication failed.';
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.overdue),
    );
  }

  void _toggleMode() {
    setState(() {
      _signup = !_signup;
      _formKey.currentState?.reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 36,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 108,
                          height: 108,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(
                                  alpha: 0.18,
                                ),
                                blurRadius: 24,
                                offset: const Offset(0, 12),
                              ),
                            ],
                          ),
                          child: Image.asset('assets/images/logo.png'),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          _signup ? 'Create your account' : 'Welcome back',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 30,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _signup
                              ? 'Save baby, mother, vaccine, and clinic records securely in Firebase.'
                              : 'Login to continue with your saved BabyBloom records.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                            height: 1.45,
                          ),
                        ),
                        const SizedBox(height: 26),
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: AppColors.cardBackground,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: AppColors.divider),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 18,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                if (_signup)
                                  _field(
                                    controller: _nameController,
                                    label: 'Full name',
                                    icon: Icons.person_rounded,
                                    validator: (value) =>
                                        value == null || value.trim().isEmpty
                                        ? 'Name is required'
                                        : null,
                                  ),
                                _field(
                                  controller: _emailController,
                                  label: 'Email',
                                  icon: Icons.email_rounded,
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (value) {
                                    final email = value?.trim() ?? '';
                                    if (email.isEmpty)
                                      return 'Email is required';
                                    if (!email.contains('@')) {
                                      return 'Enter a valid email';
                                    }
                                    return null;
                                  },
                                ),
                                _field(
                                  controller: _passwordController,
                                  label: 'Password',
                                  icon: Icons.lock_rounded,
                                  obscureText: _hidePassword,
                                  suffixIcon: IconButton(
                                    onPressed: () => setState(
                                      () => _hidePassword = !_hidePassword,
                                    ),
                                    icon: Icon(
                                      _hidePassword
                                          ? Icons.visibility_rounded
                                          : Icons.visibility_off_rounded,
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Password is required';
                                    }
                                    if (value.length < 6) {
                                      return 'Use at least 6 characters';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 4),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: _loading ? null : _submit,
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    child: _loading
                                        ? const SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : Text(_signup ? 'Sign Up' : 'Login'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        TextButton(
                          onPressed: _loading ? null : _toggleMode,
                          child: Text(
                            _signup
                                ? 'Already have an account? Login'
                                : 'New here? Create account',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String? Function(String?) validator,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
          suffixIcon: suffixIcon,
          filled: true,
          fillColor: const Color(0xFFF7F8FA),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.06)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: AppColors.primary, width: 1.4),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: AppColors.overdue.withValues(alpha: 0.7),
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: AppColors.overdue, width: 1.4),
          ),
        ),
      ),
    );
  }
}
