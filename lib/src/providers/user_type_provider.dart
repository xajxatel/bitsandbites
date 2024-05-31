import 'package:bitsandbites/src/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

final userTypeProvider = StreamProvider<Map<String, dynamic>?>((ref) async* {
  final authState = ref.watch(authStateChangesProvider);
  final user = authState.value;
  if (user != null) {
    final userTypeData = await UserTypeService().getUserType(user.uid);
    yield userTypeData;
  } else {
    yield null;
  }
});

class UserTypeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>?> getUserType(String uid) async {
    final userDoc = await _firestore.collection('users').doc(uid).get();
    if (userDoc.exists) {
      return userDoc.data();
    }
    return null;
  }

  Future<void> updateUserVerificationStatus(String uid, bool isVerified) async {
    await _firestore.collection('users').doc(uid).update({
      'emailVerified': isVerified,
    });
  }
}
