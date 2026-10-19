import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/country_codes.dart';
import '../theme/app_colors.dart';
import '../utils/validators.dart';

/// A reusable phone input widget with a country code dropdown and localized validation.
class PhoneInputField extends StatelessWidget {
  final TextEditingController controller;
  final String selectedCountryCode;
  final ValueChanged<String> onCountryCodeChanged;
  final String labelText;
  final String? hintText;
  final bool isRequired;
  final IconData prefixIcon;
  final FormFieldValidator<String>? validator;

  const PhoneInputField({
    super.key,
    required this.controller,
    required this.selectedCountryCode,
    required this.onCountryCodeChanged,
    this.labelText = 'Phone Number',
    this.hintText,
    this.isRequired = false,
    this.prefixIcon = Icons.phone_outlined,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    // Ensure selectedCountryCode exists in items, otherwise fallback to +91
    final effectiveCode = CountryCodes.all.any((c) => c.code == selectedCountryCode)
        ? selectedCountryCode
        : CountryCodes.defaultCode;

    final defaultHint = effectiveCode == '+91' ? '98765 43210' : '1234567890';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Country Code Dropdown Container
        Container(
          height: 56,
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          alignment: Alignment.center,
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: effectiveCode,
              dropdownColor: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              icon: const Icon(
                Icons.arrow_drop_down,
                color: AppColors.textSecondary,
                size: 20,
              ),
              items: CountryCodes.all.map((item) {
                return DropdownMenuItem<String>(
                  value: item.code,
                  child: Text(
                    item.shortLabel,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  onCountryCodeChanged(val);
                }
              },
            ),
          ),
        ),

        // Phone Number Text Field
        Expanded(
          child: TextFormField(
            controller: controller,
            decoration: InputDecoration(
              labelText: labelText,
              hintText: hintText ?? defaultHint,
              prefixIcon: Icon(prefixIcon),
            ),
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(effectiveCode == '+91' ? 10 : 15),
            ],
            validator: validator ??
                (val) => Validators.validatePhoneNumber(
                      val,
                      countryCode: effectiveCode,
                      isRequired: isRequired,
                    ),
          ),
        ),
      ],
    );
  }
}
