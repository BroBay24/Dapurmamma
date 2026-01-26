import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/banner_model.dart';

class BannerRepository {
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;
  static const String _collection = 'banners';

  // Real-time stream untuk user app (tanpa composite index)
  Stream<List<BannerModel>> getActiveBannersStream() {
    return _firestore
        .collection(_collection)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
          final banners = snapshot.docs
              .map((doc) => BannerModel.fromFirestore(doc))
              .toList();
          // Sort di client side
          banners.sort((a, b) => a.order.compareTo(b.order));
          return banners;
        });
  }

  // Stream semua banner untuk admin (tanpa index)
  Stream<List<BannerModel>> getAllBannersStream() {
    return _firestore
        .collection(_collection)
        .snapshots()
        .map((snapshot) {
          final banners = snapshot.docs
              .map((doc) => BannerModel.fromFirestore(doc))
              .toList();
          // Sort di client side
          banners.sort((a, b) => a.order.compareTo(b.order));
          return banners;
        });
  }

  // Get single banner
  Future<BannerModel?> getBanner(String id) async {
    final doc = await _firestore.collection(_collection).doc(id).get();
    if (!doc.exists) return null;
    return BannerModel.fromFirestore(doc);
  }

  // Create banner
  Future<String> createBanner(BannerModel banner) async {
    final docRef = await _firestore.collection(_collection).add({
      'title': banner.title,
      'imageUrl': banner.imageUrl,
      'linkUrl': banner.linkUrl,
      'order': banner.order,
      'isActive': banner.isActive,
      'startDate': banner.startDate != null
          ? Timestamp.fromDate(banner.startDate!)
          : null,
      'endDate':
          banner.endDate != null ? Timestamp.fromDate(banner.endDate!) : null,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return docRef.id;
  }

  // Update banner
  Future<void> updateBanner(BannerModel banner) async {
    await _firestore.collection(_collection).doc(banner.id).update({
      'title': banner.title,
      'imageUrl': banner.imageUrl,
      'linkUrl': banner.linkUrl,
      'order': banner.order,
      'isActive': banner.isActive,
      'startDate': banner.startDate != null
          ? Timestamp.fromDate(banner.startDate!)
          : null,
      'endDate':
          banner.endDate != null ? Timestamp.fromDate(banner.endDate!) : null,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Toggle active status
  Future<void> toggleBannerActive(String id, bool isActive) async {
    await _firestore.collection(_collection).doc(id).update({
      'isActive': isActive,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Delete banner
  Future<void> deleteBanner(String id) async {
    await _firestore.collection(_collection).doc(id).delete();
  }

  // Reorder banners
  Future<void> reorderBanners(List<BannerModel> banners) async {
    final batch = _firestore.batch();
    for (int i = 0; i < banners.length; i++) {
      batch.update(
        _firestore.collection(_collection).doc(banners[i].id),
        {'order': i, 'updatedAt': FieldValue.serverTimestamp()},
      );
    }
    await batch.commit();
  }
}
