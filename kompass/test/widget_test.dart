import 'package:flutter_test/flutter_test.dart';
import 'package:kompass/features/auth/data/models/user_model.dart';

void main() {
  test('App smoke test: models instantiate cleanly', () {
    const user = UserModel(
      userId: 'test_uid',
      name: 'Guide Alice',
      email: 'alice@kompass.app',
      role: 'guide',
    );
    expect(user.userId, equals('test_uid'));
    expect(user.isGuide, isTrue);
  });
}
