import 'package:cloud_firestore/cloud_firestore.dart';

class FavoriteRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection reference
  CollectionReference get _users => _firestore.collection('users');

  // Add item to favorites
  Future<void> addFavorite(String userId, String productId) async {
    // Add to subcollection 'favorites'
    // Using productId as document ID to prevent duplicates
    await _users.doc(userId).collection('favorites').doc(productId).set({
      'productId': productId,
      'addedAt': FieldValue.serverTimestamp(),
    });
  }

  // Remove item from favorites
  Future<void> removeFavorite(String userId, String productId) async {
    await _users.doc(userId).collection('favorites').doc(productId).delete();
  }

  // Get stream of favorite product IDs
  Stream<List<String>> getFavoriteIdsStream(String userId) {
    return _users.doc(userId).collection('favorites').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => doc.id).toList();
    });
  }
}
