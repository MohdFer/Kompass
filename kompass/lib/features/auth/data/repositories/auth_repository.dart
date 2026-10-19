import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';
import '../../../../core/constants/firestore_constants.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../services/storage/hive_service.dart';
import '../models/user_model.dart';

abstract class AuthRepository {
  Stream<User?> authStateChanges();
  User? get currentUser;
  Future<UserModel> signInWithEmailAndPassword(String email, String password);
  Future<UserModel> signInWithGoogle();
  Future<UserModel> registerWithEmailAndPassword(String name, String email, String password, String role);
  Future<void> signOut();
  Future<void> sendPasswordResetEmail(String email);
  Future<UserModel?> getUserData(String uid);
  Future<void> updateUserProfile(UserModel user);
  Stream<List<UserModel>> watchAllUsers();
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
      await HiveService.instance.cacheUserProfile(userData.toJson());
      return userData;
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Authentication failed');
    } catch (e) {
      if (e is AppException) rethrow;
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

      await HiveService.instance.cacheUserProfile(userModel.toJson());
      return userModel;
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Registration failed');
    } catch (e) {
      throw const DatabaseException('An unexpected error occurred during registration.');
    }
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    try {
      UserCredential userCredential;
      if (kIsWeb) {
        final googleProvider = GoogleAuthProvider();
        googleProvider.addScope('email');
        googleProvider.addScope('profile');
        userCredential = await _auth.signInWithPopup(googleProvider);
      } else {
        final GoogleSignIn googleSignIn = GoogleSignIn(
          serverClientId:
              '802033087048-ngvotubu6od1ltrk4sutcr4tj2t4rkiv.apps.googleusercontent.com',
        );
        final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
        if (googleUser == null) {
          throw const AuthException('Google sign-in was cancelled.');
        }
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        userCredential = await _auth.signInWithCredential(credential);
      }

      final user = userCredential.user;
      if (user == null) {
        throw const AuthException('Failed to retrieve user from Google account.');
      }

      // 1. Check if user profile already exists in Firestore
      final existingUser = await getUserData(user.uid);
      if (existingUser != null) {
        await HiveService.instance.cacheUserProfile(existingUser.toJson());
        return existingUser;
      }

      // 2. First-time Google user: create user document in Firestore with participant role
      final newUser = UserModel(
        userId: user.uid,
        name: user.displayName?.isNotEmpty == true
            ? user.displayName!
            : 'Explorer',
        email: user.email ?? '',
        role: 'participant',
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection(FirestoreConstants.usersCollection)
          .doc(newUser.userId)
          .set(newUser.toFirestore());

      await HiveService.instance.cacheUserProfile(newUser.toJson());
      return newUser;
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Google authentication failed.');
    } catch (e) {
      if (e is AppException) rethrow;
      throw DatabaseException('Failed to complete Google sign-in: $e');
    }
  }

  @override
  Future<void> signOut() async {
    await HiveService.instance.clearAll();
    try {
      if (!kIsWeb) {
        await GoogleSignIn().signOut();
      }
    } catch (_) {}
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
        final model = UserModel.fromFirestore(doc);
        if (_auth.currentUser?.uid == uid) {
          await HiveService.instance.cacheUserProfile(model.toJson());
        }
        return model;
      }
      return null;
    } catch (e) {
      final cached = HiveService.instance.getCachedUserProfile();
      if (cached != null && cached['userId'] == uid) {
        return UserModel.fromJson(Map<String, dynamic>.from(cached));
      }
      throw const DatabaseException('Failed to fetch user data');
    }
  }

  @override
  Future<void> updateUserProfile(UserModel user) async {
    try {
      await _firestore
          .collection(FirestoreConstants.usersCollection)
          .doc(user.userId)
          .update(user.toFirestore());
      await HiveService.instance.cacheUserProfile(user.toJson());
    } catch (e) {
      throw DatabaseException('Failed to update profile: $e');
    }
  }

  @override
  Stream<List<UserModel>> watchAllUsers() {
    return _firestore
        .collection(FirestoreConstants.usersCollection)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map(UserModel.fromFirestore).toList());
  }
}
