import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_firebase_mastery_2023/component/button.dart';
import 'package:flutter_firebase_mastery_2023/component/textformfield.dart';
import 'package:flutter_firebase_mastery_2023/component/switchauth.dart';
import 'package:flutter_firebase_mastery_2023/core/utils/app_logger.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:awesome_alert/awesome_alert.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _rememberMe = false;
  bool _loading = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    // Load the OAuth client ID from .env — never hard-code secrets
    GoogleSignIn.instance.initialize(
      serverClientId: dotenv.env['GOOGLE_WEB_CLIENT_ID'] ?? '',
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _setLoading(bool value) {
    if (mounted) setState(() => _loading = value);
  }

  Future<void> _signInWithGoogle() async {
    try {
      _setLoading(true);
      await FirebaseAuth.instance.signInWithProvider(GoogleAuthProvider());
      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(context, 'home', (route) => false);
      }
    } on FirebaseAuthException catch (e) {
      AppLogger.w('Google Sign-In FirebaseAuthException', e);
      if (e.code != 'ERROR_ABORTED_BY_USER' && context.mounted) {
        _showErrorDialog('Google Sign-In failed: ${e.message}');
      }
    } catch (e) {
      AppLogger.e('Google Sign-In unexpected error', e);
      if (context.mounted) {
        _showErrorDialog('An unexpected error occurred. Please try again.');
      }
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _signInWithEmailPassword() async {
    if (!_formKey.currentState!.validate()) {
      AppLogger.d('Login form validation failed');
      return;
    }
    _formKey.currentState!.save();

    try {
      _setLoading(true);
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      if (!user.emailVerified) {
        _showEmailVerificationDialog(user);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Logged in successfully!')),
          );
          Navigator.pushReplacementNamed(context, 'home');
        }
      }
    } on FirebaseAuthException catch (e) {
      AppLogger.w('Login FirebaseAuthException: ${e.code}', e);
      _handleAuthException(e);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _sendPasswordReset() async {
    if (_emailController.text.trim().isEmpty) {
      _showErrorDialog('Please enter your email address first.');
      return;
    }
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: _emailController.text.trim(),
      );
      if (context.mounted) {
        AwesomeAlert.show(
          context,
          title: 'Email Sent',
          description: 'Password reset email sent. Check your inbox.',
          confirmText: 'OK',
          confirmAction: () => Navigator.of(context).pop(),
        );
      }
    } catch (e) {
      AppLogger.w('Password reset failed', e);
      _showErrorDialog('Failed to send reset email. Please check the address and try again.');
    }
  }

  void _showEmailVerificationDialog(User user) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.error,
      animType: AnimType.rightSlide,
      title: 'Email Not Verified',
      desc: 'Please verify your email address before logging in.',
      btnCancelText: 'Sign Out',
      btnCancelOnPress: () async {
        _setLoading(true);
        await FirebaseAuth.instance.signOut();
        AppLogger.i('User signed out — email not verified');
        if (context.mounted) {
          Navigator.pushNamedAndRemoveUntil(context, 'login', (route) => false);
        }
        _setLoading(false);
      },
      btnOkText: 'Resend Email',
      btnOkOnPress: () async {
        _setLoading(true);
        await user.sendEmailVerification();
        AppLogger.i('Verification email resent');
        if (context.mounted) {
          Navigator.pushNamedAndRemoveUntil(context, 'verifyemail', (route) => false);
        }
        _setLoading(false);
      },
    ).show();
  }

  void _handleAuthException(FirebaseAuthException e) {
    String message;
    switch (e.code) {
      case 'invalid-credential':
        message = 'Wrong email or password. Please try again.';
        break;
      case 'network-request-failed':
        message = 'No internet connection. Please check your network.';
        break;
      case 'user-disabled':
        message = 'This account has been disabled. Contact support.';
        break;
      case 'too-many-requests':
        message = 'Too many attempts. Please wait a moment and try again.';
        break;
      default:
        message = 'An error occurred [${e.code}]. Please try again.';
    }
    _showErrorDialog(message);
  }

  void _showErrorDialog(String message) {
    if (!context.mounted) return;
    AwesomeAlert.show(
      context,
      title: 'Error',
      description: message,
      confirmText: 'OK',
      confirmAction: () => Navigator.of(context).pop(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      key: _scaffoldKey,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          children: [
            const SizedBox(height: 48),
            // Avatar icon
            Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.note_alt_outlined,
                  size: 42,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text('Welcome back', style: theme.textTheme.headlineMedium),
            const SizedBox(height: 6),
            Text(
              'Sign in to continue to your notes.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 32),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  FormInput(
                    label: 'Email',
                    hintText: 'Enter your email',
                    controller: _emailController,
                  ),
                  const SizedBox(height: 8),
                  // Password with visibility toggle
                  FormInput(
                    label: 'Password',
                    hintText: 'Enter your password',
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: theme.colorScheme.primary,
                      ),
                      onPressed: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Checkbox(
                            value: _rememberMe,
                            onChanged: (value) {
                              setState(() => _rememberMe = value ?? false);
                            },
                            activeColor: theme.colorScheme.primary,
                          ),
                          Text('Remember me', style: theme.textTheme.bodyMedium),
                        ],
                      ),
                      TextButton(
                        onPressed: _sendPasswordReset,
                        child: const Text('Forgot password?'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (_loading) ...[
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                  ],
                  Button(
                    label: 'Login',
                    onPressed: _signInWithEmailPassword,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Switchauth(
              login: true,
              onGooglePressed: _signInWithGoogle,
            ),
          ],
        ),
      ),
    );
  }
}
