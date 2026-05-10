import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = credential.user;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
      await _auth.signOut();
      throw FirebaseAuthException(
        code: 'email-not-verified',
        message:
            'Please verify your email first. We sent a new verification link.',
      );
    }
    return credential;
  }

  Future<UserCredential> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = credential.user;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'user-null',
        message: 'Unable to create user at the moment.',
      );
    }

    await user.updateDisplayName(fullName);
    await _firestore.collection('users').doc(user.uid).set({
      'uid': user.uid,
      'fullName': fullName,
      'email': email,
      'createdAt': FieldValue.serverTimestamp(),
    });
    await user.sendEmailVerification();
    await _auth.signOut();

    return credential;
  }

  Future<void> sendPasswordResetEmail({required String email}) {
    return _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> resendVerificationForCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'user-not-signed-in',
        message: 'You need to sign in first.',
      );
    }
    await user.sendEmailVerification();
  }

  Future<void> signOut() => _auth.signOut();

  /// Updates display name in Auth and `fullName` in Firestore `users/{uid}`.
  Future<void> updateFullName(String fullName) async {
    final trimmed = fullName.trim();
    if (trimmed.isEmpty) {
      throw Exception('Name cannot be empty.');
    }
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('You need to be logged in.');
    }
    await user.updateDisplayName(trimmed);
    await _firestore.collection('users').doc(user.uid).update({
      'fullName': trimmed,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
