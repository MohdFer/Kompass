import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/constants/firestore_constants.dart';
import '../../../../core/errors/app_exception.dart';
import '../models/user_model.dart';

/// Repository handling all Firebase Authentication and user profile operations.
class AuthRepository {
  AuthRepository({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  /// Returns the current Firebase Auth user, or null if not signed in.
  User? get currentUser => _auth.currentUser;

  /// Stream of auth state changes.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Register a new user with email and password.
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user!;

      final userModel = UserModel(
        userId: user.uid,
        name: name,
        email: email,
        role: role,
      );

      await _firestore
          .collection(FirestoreConstants.usersCollection)
          .doc(user.uid)
          .set(userModel.toFirestore());

      return userModel;
    } on FirebaseAuthException catch (e) {
      throw AuthException('Registration failed: ${e.message}');
    }
  }

  /// Sign in with email and password.
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return await getUserProfile(credential.user!.uid);
    } on FirebaseAuthException catch (e) {
      throw AuthException('Sign in failed: ${e.message}');
    }
  }

  /// Sign out the current user.
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Send a password reset email.
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw AuthException('Password reset failed: ${e.message}');
    }
  }

  /// Fetch a user profile from Firestore.
  Future<UserModel> getUserProfile(String userId) async {
    try {
      final doc = await _firestore
          .collection(FirestoreConstants.usersCollection)
          .doc(userId)
          .get();

      if (!doc.exists) {
        throw const AuthException('User profile not found');
      }

      return UserModel.fromFirestore(doc);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Failed to fetch user profile: $e');
    }
  }

  /// Update user profile fields.
  Future<void> updateProfile(UserModel user) async {
    try {
      await _firestore
          .collection(FirestoreConstants.usersCollection)
          .doc(user.userId)
          .update(user.toFirestore());
    } catch (e) {
      throw AuthException('Failed to update profile: $e');
    }
  }
}
