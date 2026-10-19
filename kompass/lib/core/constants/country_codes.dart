/// Country code items and helpers for phone number formatting and parsing.
library;

class CountryCodeItem {
  final String code;
  final String name;
  final String flag;

  const CountryCodeItem({
    required this.code,
    required this.name,
    required this.flag,
  });

  String get displayLabel => '$flag $code ($name)';
  String get shortLabel => '$flag $code';
}

class CountryCodes {
  CountryCodes._();

  static const String defaultCode = '+91';

  static const List<CountryCodeItem> all = [
    CountryCodeItem(code: '+91', name: 'India', flag: '🇮🇳'),
    CountryCodeItem(code: '+1', name: 'USA / Canada', flag: '🇺🇸'),
    CountryCodeItem(code: '+44', name: 'United Kingdom', flag: '🇬🇧'),
    CountryCodeItem(code: '+971', name: 'UAE', flag: '🇦🇪'),
    CountryCodeItem(code: '+966', name: 'Saudi Arabia', flag: '🇸🇦'),
    CountryCodeItem(code: '+65', name: 'Singapore', flag: '🇸🇬'),
    CountryCodeItem(code: '+60', name: 'Malaysia', flag: '🇲🇾'),
    CountryCodeItem(code: '+61', name: 'Australia', flag: '🇦🇺'),
    CountryCodeItem(code: '+49', name: 'Germany', flag: '🇩🇪'),
    CountryCodeItem(code: '+33', name: 'France', flag: '🇫🇷'),
    CountryCodeItem(code: '+81', name: 'Japan', flag: '🇯🇵'),
    CountryCodeItem(code: '+86', name: 'China', flag: '🇨🇳'),
    CountryCodeItem(code: '+974', name: 'Qatar', flag: '🇶🇦'),
    CountryCodeItem(code: '+968', name: 'Oman', flag: '🇴🇲'),
    CountryCodeItem(code: '+965', name: 'Kuwait', flag: '🇰🇼'),
    CountryCodeItem(code: '+973', name: 'Bahrain', flag: '🇧🇭'),
    CountryCodeItem(code: '+92', name: 'Pakistan', flag: '🇵🇰'),
    CountryCodeItem(code: '+880', name: 'Bangladesh', flag: '🇧🇩'),
    CountryCodeItem(code: '+977', name: 'Nepal', flag: '🇳🇵'),
    CountryCodeItem(code: '+94', name: 'Sri Lanka', flag: '🇱🇰'),
  ];

  /// Parses a stored full phone string like '+919876543210' into code and national number.
  static ({String code, String number}) parse(String? fullPhone) {
    if (fullPhone == null || fullPhone.trim().isEmpty) {
      return (code: defaultCode, number: '');
    }

    final clean = fullPhone.replaceAll(RegExp(r'[^0-9+]'), '').trim();
    if (clean.isEmpty) {
      return (code: defaultCode, number: '');
    }

    // Sort by code length descending to match longest prefix first (e.g. +880 before +88)
    final sorted = [...all]..sort((a, b) => b.code.length.compareTo(a.code.length));
    for (final item in sorted) {
      if (clean.startsWith(item.code)) {
        return (code: item.code, number: clean.substring(item.code.length));
      }
    }

    // If starts with + but unknown code, extract digits
    if (clean.startsWith('+')) {
      final match = RegExp(r'^\+(\d{1,4})(\d+)$').firstMatch(clean);
      if (match != null) {
        return (code: '+${match.group(1)}', number: match.group(2) ?? '');
      }
    }

    // Default to India +91
    return (code: defaultCode, number: clean);
  }

  /// Combine country code and local number cleanly, e.g. '+919876543210'
  static String formatFull(String code, String? number) {
    if (number == null) return '';
    final digits = number.replaceAll(RegExp(r'\D'), '').trim();
    if (digits.isEmpty) return '';
    final prefix = code.startsWith('+') ? code : '+$code';
    return '$prefix$digits';
  }
}
