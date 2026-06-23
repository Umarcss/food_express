import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  AuthService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    bool firebaseEnabled = true,
  })  : _auth = auth,
        _firestore = firestore,
        _firebaseEnabled = firebaseEnabled;

  final FirebaseAuth? _auth;
  final FirebaseFirestore? _firestore;
  final bool _firebaseEnabled;

  FirebaseAuth get auth {
    if (!_firebaseEnabled) {
      throw StateError('Firebase is not configured for this platform.');
    }
    return _auth ?? FirebaseAuth.instance;
  }

  FirebaseFirestore get firestore {
    if (!_firebaseEnabled) {
      throw StateError('Firebase is not configured for this platform.');
    }
    return _firestore ?? FirebaseFirestore.instance;
  }

  Stream<User?> authStateChanges() {
    try {
      return auth.authStateChanges();
    } catch (error) {
      debugPrint('Auth state unavailable: $error');
      return Stream<User?>.value(null);
    }
  }

  Future<UserCredential> signIn(String email, String password) {
    if (!_firebaseEnabled) {
      throw StateError(
        'Firebase is not configured. Add FirebaseOptions for web or run on a configured Android build.',
      );
    }
    return auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<UserCredential> signUp({
    required String email,
    required String password,
    required String displayName,
    required String phone,
  }) async {
    if (!_firebaseEnabled) {
      throw StateError(
        'Firebase is not configured. Add FirebaseOptions for web or run on a configured Android build.',
      );
    }
    final credential = await auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    await credential.user?.updateDisplayName(displayName.trim());
    final uid = credential.user?.uid;
    if (uid != null) {
      await firestore.collection('users').doc(uid).set({
        'displayName': displayName.trim(),
        'email': email.trim(),
        'phone': phone.trim(),
        'photoUrl': null,
        'defaultAddress': '25 Abuja Road',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
    return credential;
  }

  Future<Map<String, dynamic>?> loadProfile(String uid) async {
    if (!_firebaseEnabled) return null;
    final snapshot = await firestore.collection('users').doc(uid).get();
    return snapshot.data();
  }

  Future<void> signOut() {
    if (!_firebaseEnabled) return Future<void>.value();
    return auth.signOut();
  }
}
