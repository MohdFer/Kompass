import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/constants/firestore_constants.dart';
import '../../../../core/errors/app_exception.dart';
import '../models/user_model.dart';

abstract class AuthRepository {
  Stream<User?> authStateChanges();
  User? get currentUser;
  Future<UserModel> signInWithEmailAndPassword(String email, String password);
  Future<UserModel> registerWithEmailAndPassword(String name, String email, String password, String role);
  Future<void> signOut();
  Future<void> sendPasswordResetEmail(String email);
  Future<UserModel?> getUserData(String uid);
}

class FirebaseAuthRepository implements AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  FirebaseAuthRepository(this._auth, this._firestore);

  @override
  Stream<User?> authStateChanges() => _auth.authStateChanges();

  @override
  User? get currentUser => _auth.currentUser;

  @override
  Future<UserModel> signInWithEmailAndPassword(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      final userData = await getUserData(userCredential.user!.uid);
      if (userData == null) {
        throw const DatabaseException('User data not found in database.');
      }
      return userData;
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Authentication failed');
    } catch (e) {
      throw const DatabaseException('An unexpected error occurred during sign in.');
    }
  }

  @override
  Future<UserModel> registerWithEmailAndPassword(String name, String email, String password, String role) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final userModel = UserModel(
        userId: userCredential.user!.uid,
        name: name,
        email: email,
        role: role,
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection(FirestoreConstants.usersCollection)
          .doc(userModel.userId)
          .set(userModel.toFirestore());

      return userModel;
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Registration failed');
    } catch (e) {
      throw const DatabaseException('An unexpected error occurred during registration.');
    }
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Failed to send reset email');
    }
  }

  @override
  Future<UserModel?> getUserData(String uid) async {
    try {
      final doc = await _firestore.collection(FirestoreConstants.usersCollection).doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw const DatabaseException('Failed to fetch user data');
    }
  }
}
