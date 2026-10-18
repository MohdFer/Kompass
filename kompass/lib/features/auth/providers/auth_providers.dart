import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/models/user_model.dart';
import '../data/repositories/auth_repository.dart';

part 'auth_providers.g.dart';

@riverpod
AuthRepository authRepository(AuthRepositoryRef ref) {
  return FirebaseAuthRepository(
    FirebaseAuth.instance,
    FirebaseFirestore.instance,
  );
}

@riverpod
Stream<User?> authStateChanges(AuthStateChangesRef ref) {
  return ref.watch(authRepositoryProvider).authStateChanges();
}

@riverpod
Future<UserModel?> currentUser(CurrentUserRef ref) async {
  final authUser = ref.watch(authStateChangesProvider).value;
  if (authUser == null) return null;
  return ref.watch(authRepositoryProvider).getUserData(authUser.uid);
}

final allUsersProvider = StreamProvider<List<UserModel>>((ref) {
  return ref.watch(authRepositoryProvider).watchAllUsers();
});

@riverpod
class AuthController extends _$AuthController {
  @override
  FutureOr<void> build() {}

  Future<void> signIn(String email, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).signInWithEmailAndPassword(email, password),
    );
  }

  Future<void> register(String name, String email, String password, String role) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).registerWithEmailAndPassword(name, email, password, role),
    );
  }

  Future<void> signOut() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => ref.read(authRepositoryProvider).signOut());
  }

  Future<void> sendPasswordResetEmail(String email) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).sendPasswordResetEmail(email),
    );
  }

  Future<void> updateProfile(UserModel updatedUser) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(authRepositoryProvider).updateUserProfile(updatedUser);
      ref.invalidate(currentUserProvider);
    });
  }
}
