import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/app_toast.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/kompass_button.dart';
import '../../../../core/widgets/kompass_card.dart';
import '../../../../routing/route_names.dart';
import '../../providers/auth_providers.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      // Trigger phone/browser password manager (Google Password Manager, Keychain, etc.) to save credentials
      TextInput.finishAutofillContext(shouldSave: true);
      await ref.read(authControllerProvider.notifier).signIn(
            _emailController.text.trim(),
            _passwordController.text.trim(),
          );
      if (!ref.read(authControllerProvider).hasError) {
        AppToast.showSuccess('Signed in successfully! Welcome back.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;

    ref.listen<AsyncValue<void>>(
      authControllerProvider,
      (_, state) {
        state.whenOrNull(
          error: (error, _) {
            AppToast.showError(
              error.toString(),
              context: context,
            );
          },
        );
      },
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 92,
                  height: 92,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryGold.withValues(alpha: 0.3),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: Image.asset(
                      'assets/images/logo.png',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.explore,
                        size: 80,
                        color: AppColors.primaryGold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'KOMPASS',
                  style: AppTextStyles.displayLarge.copyWith(
                    color: AppColors.textPrimary,
                    letterSpacing: 4,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Navigate Together, Explore Forever',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 36),
                KompassCard(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: AutofillGroup(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TextFormField(
                              controller: _emailController,
                              decoration: const InputDecoration(
                                labelText: 'Email',
                                prefixIcon: Icon(Icons.email_outlined),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              autofillHints: const [
                                AutofillHints.email,
                                AutofillHints.username,
                              ],
                              autocorrect: false,
                              enableSuggestions: true,
                              validator: Validators.validateEmail,
                              textInputAction: TextInputAction.next,
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: _passwordController,
                              decoration: InputDecoration(
                                labelText: 'Password',
                                prefixIcon: const Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                              ),
                              obscureText: _obscurePassword,
                              autofillHints: const [AutofillHints.password],
                              enableSuggestions: false,
                              autocorrect: false,
                              validator: Validators.validatePassword,
                              textInputAction: TextInputAction.done,
                              onEditingComplete: () =>
                                  TextInput.finishAutofillContext(),
                              onFieldSubmitted: (_) => _submit(),
                            ),
                            const SizedBox(height: 12),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: isLoading
                                    ? null
                                    : () => context.pushNamed(
                                          RouteNames.forgotPassword,
                                        ),
                                child: const Text(
                                  'Forgot Password?',
                                  style: TextStyle(color: AppColors.primaryGold),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            KompassButton(
                              label: 'LOG IN',
                              onPressed: _submit,
                              isLoading: isLoading,
                            ),
                            const SizedBox(height: 16),
                            OutlinedButton(
                              onPressed: isLoading
                                  ? null
                                  : () => context.pushNamed(RouteNames.register),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.textPrimary,
                                side: const BorderSide(
                                  color: AppColors.primaryGold,
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text('CREATE NEW ACCOUNT'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
