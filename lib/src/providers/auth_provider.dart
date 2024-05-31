import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final authStateChangesProvider = StreamProvider<User?>((ref) {
  final firebaseAuth = ref.watch(firebaseAuthProvider);
  return firebaseAuth.authStateChanges();
});

final authProvider = Provider<AuthenticationService>((ref) {
  final firebaseAuth = ref.watch(firebaseAuthProvider);
  return AuthenticationService(firebaseAuth);
});

final isSellerProvider = FutureProvider<bool>((ref) async {
  final firebaseAuth = ref.watch(firebaseAuthProvider);
  final user = firebaseAuth.currentUser;

  if (user != null) {
    final doc = await FirebaseFirestore.instance.collection('sellers').doc(user.uid).get();
    return doc.exists;
  }
  return false;
});

final isBuyerProvider = FutureProvider<bool>((ref) async {
  final firebaseAuth = ref.watch(firebaseAuthProvider);
  final user = firebaseAuth.currentUser;

  if (user != null) {
    final doc = await FirebaseFirestore.instance.collection('buyers').doc(user.uid).get();
    return doc.exists;
  }
  return false;
});

class AuthenticationService {
  final FirebaseAuth _firebaseAuth;

  AuthenticationService(this._firebaseAuth);

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> createUserWithEmailAndPassword(String email, String password) async {
    await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  Future<void> sendEmailVerification() async {
    final user = _firebaseAuth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  Future<void> reloadUser() async {
    final user = _firebaseAuth.currentUser;
    await user?.reload();
  }

  User? getCurrentUser() {
    return _firebaseAuth.currentUser;
  }
}
