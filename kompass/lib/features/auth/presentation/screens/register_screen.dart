import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/country_codes.dart';
import '../../../../core/enums/user_role.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/app_toast.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/kompass_button.dart';
import '../../../../core/widgets/kompass_card.dart';
import '../../../../core/widgets/phone_input_field.dart';
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
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _ageController = TextEditingController();
  final _emergencyNameController = TextEditingController();
  final _emergencyPhoneController = TextEditingController();
  String? _selectedGender;
  String _selectedCountryCode = CountryCodes.defaultCode;
  String _emergencyCountryCode = CountryCodes.defaultCode;
  final UserRole _selectedRole = UserRole.participant;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _ageController.dispose();
    _emergencyNameController.dispose();
    _emergencyPhoneController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      final phone = CountryCodes.formatFull(
        _selectedCountryCode,
        _phoneController.text.trim(),
      );
      final emergencyPhone = CountryCodes.formatFull(
        _emergencyCountryCode,
        _emergencyPhoneController.text.trim(),
      );

      // Prompt phone/browser password manager (e.g. Google Password Manager) to save new credentials
      TextInput.finishAutofillContext(shouldSave: true);
      final age = int.tryParse(_ageController.text.trim());

      await ref.read(authControllerProvider.notifier).register(
            name: _nameController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
            role: _selectedRole.label,
            phoneNumber: phone,
            isPhoneVerified: phone.isNotEmpty,
            address: _addressController.text.trim(),
            gender: _selectedGender ?? '',
            age: age,
            emergencyContact: emergencyPhone,
            emergencyContactName: _emergencyNameController.text.trim(),
            isEmergencyContactVerified: false,
          );
      if (!mounted) return;
      if (!ref.read(authControllerProvider).hasError) {
        AppToast.showSuccess(
          'Account created! A verification link was sent to your email.',
        );
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    await ref.read(authControllerProvider.notifier).signInWithGoogle();
    if (!mounted) return;
    if (!ref.read(authControllerProvider).hasError) {
      AppToast.showSuccess('Welcome to Kompass! Signed in with Google.');
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
                            const SizedBox(height: 20),
                            Theme(
                              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceVariant.withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: ExpansionTile(
                                  initiallyExpanded: false,
                                  tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                  childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                  leading: const Icon(Icons.badge_outlined, color: AppColors.primaryGold),
                                  title: const Text(
                                    'Personal & Safety Info (Optional)',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  subtitle: const Text(
                                    'Helps your Tour Guide with contacts, address, age & emergency safety',
                                    style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                  ),
                                  children: [
                                    const SizedBox(height: 8),
                                    // Contact Phone Number with Country Code
                                    PhoneInputField(
                                      controller: _phoneController,
                                      selectedCountryCode: _selectedCountryCode,
                                      onCountryCodeChanged: (code) =>
                                          setState(() => _selectedCountryCode = code),
                                      labelText: 'Personal Contact Number',
                                      prefixIcon: Icons.phone_outlined,
                                    ),
                                    const SizedBox(height: 16),
                                    // Address
                                    TextFormField(
                                      controller: _addressController,
                                      decoration: const InputDecoration(
                                        labelText: 'Address',
                                        hintText: 'City, State or Residential Address',
                                        prefixIcon: Icon(Icons.location_on_outlined),
                                      ),
                                      keyboardType: TextInputType.streetAddress,
                                    ),
                                    const SizedBox(height: 16),
                                    // Gender & Age Row
                                    Row(
                                      children: [
                                        Expanded(
                                          flex: 3,
                                          child: DropdownButtonFormField<String>(
                                            value: _selectedGender,
                                            decoration: const InputDecoration(
                                              labelText: 'Gender',
                                              prefixIcon: Icon(Icons.wc_outlined),
                                            ),
                                            items: const [
                                              DropdownMenuItem(value: 'Male', child: Text('Male')),
                                              DropdownMenuItem(value: 'Female', child: Text('Female')),
                                              DropdownMenuItem(value: 'Non-binary', child: Text('Non-binary')),
                                              DropdownMenuItem(value: 'Other', child: Text('Other')),
                                              DropdownMenuItem(value: 'Prefer not to say', child: Text('Prefer not to say')),
                                            ],
                                            onChanged: (val) => setState(() => _selectedGender = val),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          flex: 2,
                                          child: TextFormField(
                                            controller: _ageController,
                                            decoration: const InputDecoration(
                                              labelText: 'Age',
                                              hintText: 'e.g. 28',
                                              prefixIcon: Icon(Icons.cake_outlined),
                                            ),
                                            keyboardType: TextInputType.number,
                                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    // Emergency Contact Section
                                    Row(
                                      children: [
                                        const Icon(Icons.emergency_outlined, color: AppColors.sosRed, size: 16),
                                        const SizedBox(width: 6),
                                        Text(
                                          'Emergency Contact',
                                          style: AppTextStyles.labelSmall.copyWith(
                                            color: AppColors.sosRed,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    TextFormField(
                                      controller: _emergencyNameController,
                                      decoration: const InputDecoration(
                                        labelText: 'Contact Name / Relationship',
                                        hintText: 'e.g. Jane Doe (Spouse) or Parent',
                                        prefixIcon: Icon(Icons.person_pin_outlined),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    PhoneInputField(
                                      controller: _emergencyPhoneController,
                                      selectedCountryCode: _emergencyCountryCode,
                                      onCountryCodeChanged: (code) =>
                                          setState(() => _emergencyCountryCode = code),
                                      labelText: 'Emergency Phone Number',
                                      prefixIcon: Icons.contact_phone_outlined,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 32),
                            KompassButton(
                              label: 'CREATE ACCOUNT',
                              onPressed: _submit,
                              isLoading: isLoading,
                            ),
                            const SizedBox(height: 18),
                            Row(
                              children: [
                                const Expanded(child: Divider(color: AppColors.border)),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 14),
                                  child: Text(
                                    'OR',
                                    style: AppTextStyles.labelSmall.copyWith(
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const Expanded(child: Divider(color: AppColors.border)),
                              ],
                            ),
                            const SizedBox(height: 18),
                            ElevatedButton(
                              onPressed: isLoading ? null : _signInWithGoogle,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1E1E1E),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                side: const BorderSide(color: Color(0xFF3E3E3E), width: 1.2),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SvgPicture.string(
                                    '''<svg viewBox="0 0 48 48" width="22" height="22">
                                      <path fill="#EA4335" d="M24 9.5c3.54 0 6.71 1.22 9.21 3.6l6.85-6.85C35.9 2.38 30.47 0 24 0 14.62 0 6.51 5.38 2.56 13.22l7.98 6.19C12.43 13.72 17.74 9.5 24 9.5z"/>
                                      <path fill="#4285F4" d="M46.98 24.55c0-1.57-.15-3.09-.38-4.55H24v9.02h12.94c-.58 2.96-2.26 5.48-4.78 7.18l7.73 6c4.51-4.18 7.09-10.36 7.09-17.65z"/>
                                      <path fill="#FBBC05" d="M10.53 28.59c-.48-1.45-.76-2.99-.76-4.59s.27-3.14.76-4.59l-7.98-6.19C.92 16.46 0 20.12 0 24c0 3.88.92 7.54 2.56 10.78l7.97-6.19z"/>
                                      <path fill="#34A853" d="M24 48c6.48 0 11.93-2.13 15.89-5.81l-7.73-6c-2.15 1.45-4.92 2.3-8.16 2.3-6.26 0-11.57-4.22-13.47-9.91l-7.98 6.19C6.51 42.62 14.62 48 24 48z"/>
                                    </svg>''',
                                    width: 22,
                                    height: 22,
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    'Continue with Google',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
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
          ),
        ),
      ),
    );
  }
}
