import 'package:flutter_test/flutter_test.dart';
import 'package:kompass/core/constants/country_codes.dart';
import 'package:kompass/core/utils/validators.dart';
import 'package:kompass/features/auth/data/models/user_model.dart';
import 'package:kompass/features/tour/data/models/tour_model.dart';
import 'package:kompass/services/otp/otp_verification_service.dart';

void main() {
  group('UserModel Personal & Emergency Details Tests', () {
    test('UserModel default constructor initializes personal fields', () {
      const user = UserModel(
        userId: 'user_123',
        name: 'John Explorer',
        email: 'john@example.com',
        role: 'participant',
        phoneNumber: '+15551234567',
        isPhoneVerified: true,
        address: '123 Basecamp Way, Aspen, CO',
        gender: 'Male',
        age: 29,
        emergencyContact: '+15559876543',
        emergencyContactName: 'Jane (Spouse)',
        isEmergencyContactVerified: true,
      );

      expect(user.contact, equals('+15551234567'));
      expect(user.phoneNumber, equals('+15551234567'));
      expect(user.isPhoneVerified, isTrue);
      expect(user.address, equals('123 Basecamp Way, Aspen, CO'));
      expect(user.gender, equals('Male'));
      expect(user.age, equals(29));
      expect(user.emergencyContact, equals('+15559876543'));
      expect(user.emergencyContactName, equals('Jane (Spouse)'));
      expect(user.isEmergencyContactVerified, isTrue);
      expect(user.hasContact, isTrue);
      expect(user.hasEmergencyContact, isTrue);
      expect(user.hasAddress, isTrue);
    });

    test('UserModel serialization to/from JSON works correctly', () {
      final json = {
        'userId': 'user_456',
        'name': 'Sarah Traveler',
        'email': 'sarah@example.com',
        'role': 'participant',
        'profileImage': 'https://example.com/avatar.png',
        'phoneNumber': '+447911123456',
        'isPhoneVerified': true,
        'address': '45 Baker St, London',
        'gender': 'Female',
        'age': 34,
        'emergencyContact': '+447911999888',
        'emergencyContactName': 'Parent',
        'isEmergencyContactVerified': false,
      };

      final model = UserModel.fromJson(json);
      expect(model.name, equals('Sarah Traveler'));
      expect(model.phoneNumber, equals('+447911123456'));
      expect(model.address, equals('45 Baker St, London'));
      expect(model.gender, equals('Female'));
      expect(model.age, equals(34));
      expect(model.emergencyContact, equals('+447911999888'));
      expect(model.isEmergencyContactVerified, isFalse);

      final exportedJson = model.toJson();
      expect(exportedJson['phoneNumber'], equals('+447911123456'));
      expect(exportedJson['address'], equals('45 Baker St, London'));
      expect(exportedJson['age'], equals(34));
    });
  });

  group('OtpVerificationService Verification Tests', () {
    test('normalizes phone numbers to digits and leading plus', () {
      expect(
        OtpVerificationService.normalizePhoneNumber('(555) 123-4567'),
        equals('5551234567'),
      );
      expect(
        OtpVerificationService.normalizePhoneNumber('+1 (555) 123-4567'),
        equals('+15551234567'),
      );
    });

    test('validates successfully against the official project test token', () async {
      final verified = await OtpVerificationService.instance.verifyOtp(
        phoneNumber: '+15551234567',
        inputCode: OtpVerificationService.testToken,
      );
      expect(verified, isTrue);
    });

    test('validates successfully against standard test code 123456', () async {
      final verified = await OtpVerificationService.instance.verifyOtp(
        phoneNumber: '+15551234567',
        inputCode: '123456',
      );
      expect(verified, isTrue);
    });

    test('generates and validates session simulated OTP', () async {
      const phone = '+19998887777';
      final session = await OtpVerificationService.instance.requestOtp(phone);
      expect(session.simulatedOtp.length, equals(6));

      // Valid session code passes
      final verified = await OtpVerificationService.instance.verifyOtp(
        phoneNumber: phone,
        inputCode: session.simulatedOtp,
      );
      expect(verified, isTrue);

      // Wrong code throws exception
      expect(
        () => OtpVerificationService.instance.verifyOtp(
          phoneNumber: phone,
          inputCode: '000111',
        ),
        throwsException,
      );
    });
  });

  group('CountryCodes & Phone Validation Tests', () {
    test('CountryCodes defaults to India +91', () {
      expect(CountryCodes.defaultCode, equals('+91'));
      final parsed = CountryCodes.parse('');
      expect(parsed.code, equals('+91'));
      expect(parsed.number, equals(''));
    });

    test('CountryCodes parses +91 correctly', () {
      final parsed = CountryCodes.parse('+919876543210');
      expect(parsed.code, equals('+91'));
      expect(parsed.number, equals('9876543210'));
    });

    test('CountryCodes parses other international codes correctly', () {
      final parsedUS = CountryCodes.parse('+15551234567');
      expect(parsedUS.code, equals('+1'));
      expect(parsedUS.number, equals('5551234567'));

      final parsedUAE = CountryCodes.parse('+971501234567');
      expect(parsedUAE.code, equals('+971'));
      expect(parsedUAE.number, equals('501234567'));
    });

    test('CountryCodes.formatFull formats properly', () {
      expect(CountryCodes.formatFull('+91', '9876543210'), equals('+919876543210'));
      expect(CountryCodes.formatFull('+91', ''), equals(''));
    });

    test('Validators.validatePhoneNumber validates Indian numbers', () {
      // Empty is valid if optional
      expect(Validators.validatePhoneNumber('', countryCode: '+91'), isNull);
      expect(Validators.validatePhoneNumber(null, countryCode: '+91'), isNull);

      // Valid 10-digit Indian numbers starting with 6, 7, 8, 9
      expect(Validators.validatePhoneNumber('9876543210', countryCode: '+91'), isNull);
      expect(Validators.validatePhoneNumber('8123456789', countryCode: '+91'), isNull);
      expect(Validators.validatePhoneNumber('7000000000', countryCode: '+91'), isNull);
      expect(Validators.validatePhoneNumber('6333333333', countryCode: '+91'), isNull);

      // Invalid lengths
      expect(Validators.validatePhoneNumber('98765', countryCode: '+91'), isNotNull);
      expect(Validators.validatePhoneNumber('987654321012', countryCode: '+91'), isNotNull);

      // Invalid leading digit (e.g. 5 or 1)
      expect(Validators.validatePhoneNumber('5876543210', countryCode: '+91'), isNotNull);
    });

    test('Validators.validatePhoneNumber validates international numbers', () {
      expect(Validators.validatePhoneNumber('5551234567', countryCode: '+1'), isNull);
      expect(Validators.validatePhoneNumber('123', countryCode: '+1'), isNotNull);
    });
  });

  group('Participant Personal Details Privacy & Authorization Tests', () {
    const tour = TourModel(
      tourId: 'tour_abc',
      name: 'Himalayan Trek',
      guideId: 'guide_1',
      guestGuideIds: ['guest_guide_2'],
      participantIds: ['participant_3', 'participant_4'],
    );

    const adminUser = UserModel(
      userId: 'admin_root',
      name: 'System Admin',
      email: 'admin@kompass.io',
      role: 'Admin',
    );

    const primaryGuideUser = UserModel(
      userId: 'guide_1',
      name: 'Sherpa Guide',
      email: 'guide@kompass.io',
      role: 'Guide',
    );

    const guestGuideUser = UserModel(
      userId: 'guest_guide_2',
      name: 'Assistant Guide',
      email: 'guest@kompass.io',
      role: 'Participant',
    );

    const participantA = UserModel(
      userId: 'participant_3',
      name: 'Alice Traveler',
      email: 'alice@example.com',
      role: 'Participant',
      phoneNumber: '+919876543210',
      address: '42 Baker St, London',
      gender: 'Female',
      age: 26,
      emergencyContact: '+919123456780',
      emergencyContactName: 'Bob (Brother)',
    );

    const participantB = UserModel(
      userId: 'participant_4',
      name: 'Charlie Explorer',
      email: 'charlie@example.com',
      role: 'Participant',
    );

    bool canViewPersonalDetails({
      required UserModel viewer,
      required UserModel targetUser,
      required TourModel tour,
    }) {
      final isSelf = viewer.userId == targetUser.userId;
      final isAdmin = viewer.isAdmin;
      final canManage = tour.canManageTour(viewer.userId) || isAdmin;
      return canManage || isSelf;
    }

    test('Admin can view participant personal details', () {
      expect(
        canViewPersonalDetails(
          viewer: adminUser,
          targetUser: participantA,
          tour: tour,
        ),
        isTrue,
      );
    });

    test('Primary Tour Guide can view participant personal details', () {
      expect(
        canViewPersonalDetails(
          viewer: primaryGuideUser,
          targetUser: participantA,
          tour: tour,
        ),
        isTrue,
      );
    });

    test('Guest Guide can view participant personal details', () {
      expect(
        canViewPersonalDetails(
          viewer: guestGuideUser,
          targetUser: participantA,
          tour: tour,
        ),
        isTrue,
      );
    });

    test('Participant can view their own personal details', () {
      expect(
        canViewPersonalDetails(
          viewer: participantA,
          targetUser: participantA,
          tour: tour,
        ),
        isTrue,
      );
    });

    test('Other participants CANNOT view participant personal details', () {
      expect(
        canViewPersonalDetails(
          viewer: participantB,
          targetUser: participantA,
          tour: tour,
        ),
        isFalse,
      );
    });
  });
}

