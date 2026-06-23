import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:food_express/services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider({
    AuthService? authService,
    bool firebaseEnabled = true,
  }) : _authService =
            authService ?? AuthService(firebaseEnabled: firebaseEnabled);

  final AuthService _authService;
  StreamSubscription<User?>? _subscription;
  User? _user;
  Map<String, dynamic>? _profile;
  bool _isLoading = true;
  String? _errorMessage;

  User? get user => _user;
  Map<String, dynamic>? get profile => _profile;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;
  String? get errorMessage => _errorMessage;

  String get displayName {
    return _profile?['displayName'] as String? ??
        _user?.displayName ??
        _user?.email?.split('@').first ??
        'Guest';
  }

  String get email => _user?.email ?? _profile?['email'] as String? ?? '';
  String get phone => _profile?['phone'] as String? ?? '';
  String get defaultAddress =>
      _profile?['defaultAddress'] as String? ?? '25 Abuja Road';

  Future<void> initialize() async {
    _subscription = _authService.authStateChanges().listen((user) async {
      _user = user;
      if (user != null) {
        try {
          _profile = await _authService.loadProfile(user.uid);
        } catch (error) {
          debugPrint('Unable to load profile: $error');
        }
      } else {
        _profile = null;
      }
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<bool> signIn(String email, String password) async {
    return _runAuthAction(() => _authService.signIn(email, password));
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String displayName,
    required String phone,
  }) async {
    return _runAuthAction(
      () => _authService.signUp(
        email: email,
        password: password,
        displayName: displayName,
        phone: phone,
      ),
    );
  }

  Future<bool> _runAuthAction(Future<Object?> Function() action) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await action();
      return true;
    } on FirebaseAuthException catch (error) {
      _errorMessage = error.message ?? 'Authentication failed';
      return false;
    } catch (error) {
      _errorMessage = 'Authentication is not available yet: $error';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
