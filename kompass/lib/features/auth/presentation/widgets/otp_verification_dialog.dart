import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/app_toast.dart';
import '../../../../services/otp/otp_verification_service.dart';

class OtpVerificationDialog extends StatefulWidget {
  final String phoneNumber;
  final String title;

  const OtpVerificationDialog({
    super.key,
    required this.phoneNumber,
    this.title = 'Verify Phone Number',
  });

  /// Convenient static launcher to show the dialog and await boolean verification result.
  static Future<bool> show(
    BuildContext context, {
    required String phoneNumber,
    String title = 'Verify Phone Number',
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => OtpVerificationDialog(
        phoneNumber: phoneNumber,
        title: title,
      ),
    );
    return result ?? false;
  }

  @override
  State<OtpVerificationDialog> createState() => _OtpVerificationDialogState();
}

class _OtpVerificationDialogState extends State<OtpVerificationDialog> {
  final _codeController = TextEditingController();
  bool _isSending = false;
  bool _isVerifying = false;
  String? _simulatedOtp;
  int _resendCountdown = 30;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _sendOtp();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _codeController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _resendCountdown = 30);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCountdown > 0) {
        if (mounted) setState(() => _resendCountdown--);
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _sendOtp() async {
    setState(() => _isSending = true);
    try {
      final reqState = await OtpVerificationService.instance.requestOtp(
        widget.phoneNumber,
        onCodeSent: (_) {
          if (mounted) {
            AppToast.showSuccess('SMS verification code dispatched!');
          }
        },
        onVerificationFailed: (err) {
          if (mounted) {
            AppToast.showWarning('Carrier SMS error: $err');
          }
        },
      );
      if (mounted) {
        setState(() {
          _simulatedOtp = reqState.simulatedOtp;
          _isSending = false;
        });
        _startTimer();
        if (kIsWeb) {
          AppToast.showInfo(
            'Web mode: Tap "Use Test Token" or "Use Code (${reqState.simulatedOtp})" to verify.',
            duration: const Duration(seconds: 5),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSending = false);
        AppToast.showError('Failed to send OTP: $e');
      }
    }
  }

  Future<void> _verifyOtp() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      AppToast.showWarning('Please enter the verification code or test token.');
      return;
    }

    setState(() => _isVerifying = true);
    try {
      final success = await OtpVerificationService.instance.verifyOtp(
        phoneNumber: widget.phoneNumber,
        inputCode: code,
      );
      if (success && mounted) {
        AppToast.showSuccess('Phone number verified successfully!');
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isVerifying = false);
        AppToast.showError(e.toString().replaceFirst('Exception: ', ''));
      }
    }
  }

  void _useTestToken() {
    _codeController.text = OtpVerificationService.testToken;
    setState(() {});
    AppToast.showInfo('Project test token applied.');
  }

  void _useSimulatedCode() {
    if (_simulatedOtp != null) {
      _codeController.text = _simulatedOtp!;
      setState(() {});
      AppToast.showInfo('Test code applied.');
    } else {
      _codeController.text = '123456';
      setState(() {});
      AppToast.showInfo('Standard test code (123456) applied.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryGold.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.phonelink_lock_rounded,
              color: AppColors.primaryGold,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              widget.title,
              style: AppTextStyles.headlineMedium,
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'A verification code is required to confirm and save your contact number:',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.phone_iphone_rounded,
                    size: 18,
                    color: AppColors.primaryGold,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.phoneNumber,
                      style: AppTextStyles.labelLarge.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            if (kIsWeb)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primaryGold.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.3)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline, size: 16, color: AppColors.primaryGold),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Carrier SMS is not sent on web browsers. Tap "Use Test Token" or "Use Code" below to verify immediately.',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.primaryGold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // OTP Input
            TextField(
              controller: _codeController,
              decoration: InputDecoration(
                labelText: 'Enter 6-Digit OTP or Test Token',
                hintText: 'e.g. 123456 or test token',
                prefixIcon: const Icon(Icons.lock_clock_outlined),
                suffixIcon: _codeController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _codeController.clear();
                          setState(() {});
                        },
                      )
                    : null,
              ),
              keyboardType: TextInputType.text,
              autocorrect: false,
              enableSuggestions: false,
              onChanged: (_) => setState(() {}),
              onSubmitted: (_) => _verifyOtp(),
            ),
            const SizedBox(height: 12),

            // Quick Test helper badges
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                ActionChip(
                  avatar: const Icon(Icons.key, size: 14, color: AppColors.primaryGold),
                  label: const Text('Use Test Token', style: TextStyle(fontSize: 11)),
                  backgroundColor: AppColors.surfaceVariant,
                  side: const BorderSide(color: AppColors.primaryGold, width: 0.8),
                  onPressed: _useTestToken,
                ),
                ActionChip(
                  avatar: const Icon(Icons.bolt, size: 14, color: AppColors.primaryNeonGreen),
                  label: Text(
                    _simulatedOtp != null ? 'Use Code ($_simulatedOtp)' : 'Use Code (123456)',
                    style: const TextStyle(fontSize: 11),
                  ),
                  backgroundColor: AppColors.surfaceVariant,
                  side: const BorderSide(color: AppColors.primaryNeonGreen, width: 0.8),
                  onPressed: _useSimulatedCode,
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Resend timer row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_resendCountdown > 0)
                  Text(
                    'Resend code in ${_resendCountdown}s',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  )
                else
                  TextButton.icon(
                    onPressed: _isSending ? null : _sendOtp,
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text(
                      'Resend Code',
                      style: TextStyle(
                        color: AppColors.primaryGold,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isVerifying
              ? null
              : () => Navigator.of(context).pop(false),
          child: const Text(
            'Cancel',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryGold,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
          onPressed: _isVerifying ? null : _verifyOtp,
          child: _isVerifying
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.black,
                  ),
                )
              : const Text(
                  'Verify & Confirm',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
        ),
      ],
    );
  }
}
