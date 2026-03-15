import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import 'firestore_service.dart';

class AuthService extends ChangeNotifier {
  final FirestoreService _firestore = FirestoreService();

  UserModel? _currentUserModel;
  bool _isLoading = false;
  bool _isDemoMode = false;
  
  UserModel? get currentUserModel => _currentUserModel;
  bool get isLoading => _isLoading;
  bool get isDemoMode => _isDemoMode;

  String? _verificationId;
  int? _resendToken;

  void enableDemoMode() {
    _isDemoMode = true;
    _currentUserModel = UserModel(
      uid: 'demo_user_123',
      phoneNumber: '+923004563428',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    notifyListeners();
  }

  AuthService() {
    _initAuthListener();
  }

  // Safe getter for FirebaseAuth instance
  FirebaseAuth? get _auth {
    try {
      if (Firebase.apps.isEmpty) return null;
      return FirebaseAuth.instance;
    } catch (e) {
      debugPrint('AuthService: Firebase not initialized: $e');
      return null;
    }
  }

  void _initAuthListener() {
    final auth = _auth;
    if (auth == null) return;

    try {
      auth.authStateChanges().listen((User? user) async {
        if (user != null) {
          await _fetchUserModel(user.uid);
        } else {
          _currentUserModel = null;
        }
        notifyListeners();
      }, onError: (e) {
        debugPrint('AuthService: authStateChanges error: $e');
      });
    } catch (e) {
      debugPrint('AuthService: Could not listen to auth changes: $e');
    }
  }

  bool get isAuthenticated {
    if (_isDemoMode) return true;
    try {
      return _auth?.currentUser != null;
    } catch (e) {
      return false;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> _fetchUserModel(String uid) async {
    try {
      _currentUserModel = await _firestore.getUser(uid);
      
      // Create user document if it doesn't exist
      if (_currentUserModel == null) {
        final auth = _auth;
        final newUser = UserModel(
          uid: uid,
          phoneNumber: auth?.currentUser?.phoneNumber ?? '',
          email: auth?.currentUser?.email ?? '',
          displayName: auth?.currentUser?.displayName ?? '',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await _firestore.createUser(newUser);
        _currentUserModel = newUser;
      }
    } catch (e) {
      debugPrint('Error fetching user: $e');
    }
  }

  Future<void> sendOTP(String phoneNumber, Function(String) onError, Function() onCodeSent) async {
    final auth = _auth;
    if (auth == null) {
      onError('Firebase not initialized. Please configure google-services.json');
      return;
    }

    try {
      _setLoading(true);
      
      await auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        
        verificationCompleted: (PhoneAuthCredential credential) async {
          await auth.signInWithCredential(credential);
          _setLoading(false);
        },
        
        verificationFailed: (FirebaseAuthException e) {
          _setLoading(false);
          onError(e.message ?? 'Verification failed');
        },
        
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          _resendToken = resendToken;
          _setLoading(false);
          onCodeSent();
        },
        
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
        
        forceResendingToken: _resendToken,
      );
    } catch (e) {
      _setLoading(false);
      onError(e.toString());
    }
  }

  Future<void> verifyOTP(String otp, Function(String) onError, Function() onSuccess) async {
    final auth = _auth;
    if (auth == null) {
      onError('Firebase not initialized');
      return;
    }

    if (_verificationId == null) {
      onError('Verification ID is null. Please request OTP again.');
      return;
    }
    
    try {
      _setLoading(true);
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otp,
      );
      
      await auth.signInWithCredential(credential);
      _setLoading(false);
      onSuccess();
      
    } on FirebaseAuthException catch (e) {
      _setLoading(false);
      onError(e.message ?? 'Invalid OTP code');
    } catch (e) {
      _setLoading(false);
      onError('An error occurred. Please try again.');
    }
  }

  Future<void> signInWithEmail(String email, String password, Function(String) onError, Function() onSuccess) async {
    final auth = _auth;
    if (auth == null) {
      onError('Firebase not initialized');
      return;
    }

    try {
      _setLoading(true);
      await auth.signInWithEmailAndPassword(email: email, password: password);
      _setLoading(false);
      onSuccess();
    } on FirebaseAuthException catch (e) {
      _setLoading(false);
      onError(e.message ?? 'Login failed');
    } catch (e) {
      _setLoading(false);
      onError('An error occurred. Please try again.');
    }
  }

  Future<void> signUpWithEmail(String email, String password, String name, Function(String) onError, Function() onSuccess) async {
    final auth = _auth;
    if (auth == null) {
      if (_isDemoMode) {
         onSuccess(); // Allow demo flow
         return;
      }
      onError('Firebase not initialized');
      return;
    }

    try {
      _setLoading(true);
      final credential = await auth.createUserWithEmailAndPassword(email: email, password: password);
      
      if (credential.user != null) {
        // Update display name in Firebase Auth
        await credential.user!.updateDisplayName(name);
        
        // Explicitly create user in Firestore
        final newUser = UserModel(
          uid: credential.user!.uid,
          phoneNumber: '',
          email: email,
          displayName: name,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await _firestore.createUser(newUser);
        _currentUserModel = newUser;
      }
      
      _setLoading(false);
      onSuccess();
    } on FirebaseAuthException catch (e) {
      _setLoading(false);
      onError(e.message ?? 'Sign up failed');
    } catch (e) {
      _setLoading(false);
      onError('An error occurred. Please try again.');
    }
  }

  Future<void> resetPassword(String email, Function(String) onError, Function() onSuccess) async {
    final auth = _auth;
    if (auth == null) {
      onError('Firebase not initialized');
      return;
    }

    try {
      _setLoading(true);
      await auth.sendPasswordResetEmail(email: email);
      _setLoading(false);
      onSuccess();
    } on FirebaseAuthException catch (e) {
      _setLoading(false);
      onError(e.message ?? 'Reset link could not be sent');
    } catch (e) {
      _setLoading(false);
      onError('An error occurred. Please try again.');
    }
  }

  Future<void> signOut() async {
    _isDemoMode = false;
    final auth = _auth;
    if (auth == null) {
      _currentUserModel = null;
      notifyListeners();
      return;
    }

    try {
      _setLoading(true);
      await auth.signOut();
      _currentUserModel = null;
      _setLoading(false);
    } catch (e) {
      _setLoading(false);
      debugPrint('Error signing out: $e');
    }
  }
}
