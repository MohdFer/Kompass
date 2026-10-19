import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/models/user_model.dart';
import '../data/repositories/auth_repository.dart';

part 'auth_providers.g.dart';

@Riverpod(keepAlive: true)
AuthRepository authRepository(AuthRepositoryRef ref) {
  return FirebaseAuthRepository(
    FirebaseAuth.instance,
    FirebaseFirestore.instance,
  );
}

@Riverpod(keepAlive: true)
Stream<User?> authStateChanges(AuthStateChangesRef ref) {
  return ref.watch(authRepositoryProvider).authStateChanges();
}

@Riverpod(keepAlive: true)
Future<UserModel?> currentUser(CurrentUserRef ref) async {
  final authUser = ref.watch(authStateChangesProvider).valueOrNull;
  if (authUser == null) return null;
  return ref.watch(authRepositoryProvider).getUserData(authUser.uid);
}

final allUsersProvider = StreamProvider<List<UserModel>>((ref) {
  return ref.watch(authRepositoryProvider).watchAllUsers();
});

@Riverpod(keepAlive: true)
class AuthController extends _$AuthController {
  bool _mounted = true;

  @override
  FutureOr<void> build() {
    _mounted = true;
    ref.onDispose(() {
      _mounted = false;
    });
  }

  Future<void> signIn(String email, String password) async {
    state = const AsyncValue.loading();
    final result = await AsyncValue.guard<void>(() async {
      await ref.read(authRepositoryProvider).signInWithEmailAndPassword(email, password);
    });
    if (_mounted) {
      state = result;
    }
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncValue.loading();
    final result = await AsyncValue.guard<void>(() async {
      await ref.read(authRepositoryProvider).signInWithGoogle();
      ref.invalidate(currentUserProvider);
    });
    if (_mounted) {
      state = result;
    }
  }

  Future<void> register(String name, String email, String password, String role) async {
    state = const AsyncValue.loading();
    final result = await AsyncValue.guard<void>(() async {
      await ref.read(authRepositoryProvider).registerWithEmailAndPassword(name, email, password, role);
    });
    if (_mounted) {
      state = result;
    }
  }

  Future<void> signOut() async {
    state = const AsyncValue.loading();
    final result = await AsyncValue.guard(() => ref.read(authRepositoryProvider).signOut());
    if (_mounted) {
      state = result;
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    state = const AsyncValue.loading();
    final result = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).sendPasswordResetEmail(email),
    );
    if (_mounted) {
      state = result;
    }
  }

  Future<void> sendEmailVerification() async {
    state = const AsyncValue.loading();
    final result = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).sendEmailVerification(),
    );
    if (_mounted) {
      state = result;
    }
  }

  Future<void> linkPassword(String newPassword) async {
    state = const AsyncValue.loading();
    final result = await AsyncValue.guard<void>(() async {
      await ref.read(authRepositoryProvider).linkPassword(newPassword);
      ref.invalidate(currentUserProvider);
    });
    if (_mounted) {
      state = result;
    }
  }

  Future<void> updateProfile(UserModel updatedUser) async {
    state = const AsyncValue.loading();
    final result = await AsyncValue.guard(() async {
      await ref.read(authRepositoryProvider).updateUserProfile(updatedUser);
      ref.invalidate(currentUserProvider);
    });
    if (_mounted) {
      state = result;
    }
  }
}
