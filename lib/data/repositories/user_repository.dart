import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Get current user stream
  Stream<DocumentSnapshot<Map<String, dynamic>>> getUserStream() {
    final uid = currentUserId;
    if (uid == null) {
      return const Stream.empty();
    }
    return _firestore.collection('users').doc(uid).snapshots();
  }

  // Update user profile
  Future<void> updateProfile({
    required String name,
    String? photoUrl,
  }) async {
    final uid = currentUserId;
    if (uid == null) throw Exception('No user logged in');

    final data = <String, dynamic>{
      'name': name,
    };
    if (photoUrl != null) {
      data['photoUrl'] = photoUrl;
    }

    // Update Firestore
    await _firestore.collection('users').doc(uid).set(data, SetOptions(merge: true));

    // Update FirebaseAuth profile (optional but good for caching)
    await _auth.currentUser?.updateDisplayName(name);
    if (photoUrl != null) {
      await _auth.currentUser?.updatePhotoURL(photoUrl);
    }
  }

  // Create user profile if not exists (call after registration)
  Future<void> createUserProfile(String uid, String name, String email) async {
    await _firestore.collection('users').doc(uid).set({
      'name': name,
      'email': email,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
