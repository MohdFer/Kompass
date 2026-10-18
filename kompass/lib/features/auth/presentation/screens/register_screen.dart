import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/enums/user_role.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/app_toast.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/kompass_button.dart';
import '../../../../core/widgets/kompass_card.dart';
import '../../providers/auth_providers.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final UserRole _selectedRole = UserRole.participant;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      // Prompt phone/browser password manager (e.g. Google Password Manager) to save new credentials
      TextInput.finishAutofillContext(shouldSave: true);
      await ref.read(authControllerProvider.notifier).register(
            _nameController.text.trim(),
            _emailController.text.trim(),
            _passwordController.text.trim(),
            _selectedRole.label,
          );
      if (!ref.read(authControllerProvider).hasError) {
        AppToast.showSuccess('Welcome to Kompass! Account created.');
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'JOIN THE EXPEDITION',
                  style: AppTextStyles.displayMedium.copyWith(
                    color: AppColors.textPrimary,
                    letterSpacing: 2,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Create tours as a Guide or join any tour as a Participant',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
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
                              controller: _nameController,
                              decoration: const InputDecoration(
                                labelText: 'Full Name',
                                prefixIcon: Icon(Icons.person_outline),
                              ),
                              autofillHints: const [AutofillHints.name],
                              validator: Validators.validateName,
                              textInputAction: TextInputAction.next,
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: _emailController,
                              decoration: const InputDecoration(
                                labelText: 'Email',
                                prefixIcon: Icon(Icons.email_outlined),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              autofillHints: const [
                                AutofillHints.email,
                                AutofillHints.newUsername,
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
                              autofillHints: const [AutofillHints.newPassword],
                              enableSuggestions: false,
                              autocorrect: false,
                              validator: Validators.validatePassword,
                              textInputAction: TextInputAction.done,
                              onEditingComplete: () =>
                                  TextInput.finishAutofillContext(),
                              onFieldSubmitted: (_) => _submit(),
                            ),
                            const SizedBox(height: 32),
                            KompassButton(
                              label: 'CREATE ACCOUNT',
                              onPressed: _submit,
                              isLoading: isLoading,
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
