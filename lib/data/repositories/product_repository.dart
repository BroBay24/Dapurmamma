import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';

class ProductRepository {
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;
  static const String _collection = 'products';

  // Real-time stream untuk user app (semua produk aktif, tanpa orderBy untuk menghindari index)
  Stream<List<ProductModel>> getActiveProductsStream() {
    return _firestore
        .collection(_collection)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
          final products = snapshot.docs
              .map((doc) => ProductModel.fromFirestore(doc))
              .toList();
          // Sort di client side
          products.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return products;
        });
  }

  // Stream semua produk untuk admin (tanpa filter, tanpa perlu index)
  Stream<List<ProductModel>> getAllProductsStream() {
    return _firestore
        .collection(_collection)
        .snapshots()
        .map((snapshot) {
          final products = snapshot.docs
              .map((doc) => ProductModel.fromFirestore(doc))
              .toList();
          // Sort di client side
          products.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return products;
        });
  }

  // Stream produk by category (filter di client side untuk menghindari composite index)
  Stream<List<ProductModel>> getProductsByCategoryStream(String category) {
    return _firestore
        .collection(_collection)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
          final products = snapshot.docs
              .map((doc) => ProductModel.fromFirestore(doc))
              .where((p) => p.category == category)
              .toList();
          // Sort di client side
          products.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return products;
        });
  }

  // Get single product
  Future<ProductModel?> getProduct(String id) async {
    final doc = await _firestore.collection(_collection).doc(id).get();
    if (!doc.exists) return null;
    if (!doc.exists) return null;
    return ProductModel.fromFirestore(doc);
  }

  // Stream single product
  Stream<ProductModel?> getProductStream(String id) {
    return _firestore.collection(_collection).doc(id).snapshots().map((doc) {
      if (!doc.exists) return null;
      return ProductModel.fromFirestore(doc);
    });
  }

  // Create product with auto-generated productId
  Future<String> createProduct(ProductModel product) async {
    // Generate productId (PRD-XXXXXX)
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final productId = 'PRD-${timestamp.substring(timestamp.length - 6)}';
    
    final docRef = await _firestore.collection(_collection).add({
      'productId': productId,
      'name': product.name,
      'description': product.description,
      'price': product.price,
      'stock': product.stock,
      'category': product.category,
      'imageUrl': product.imageUrl,
      'isActive': product.isActive,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return docRef.id;
  }

  // Update product
  Future<void> updateProduct(ProductModel product) async {
    await _firestore.collection(_collection).doc(product.id).update({
      'productId': product.productId,
      'name': product.name,
      'description': product.description,
      'price': product.price,
      'stock': product.stock,
      'category': product.category,
      'imageUrl': product.imageUrl,
      'isActive': product.isActive,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Update stock
  Future<void> updateStock(String id, int newStock) async {
    await _firestore.collection(_collection).doc(id).update({
      'stock': newStock,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Toggle active status
  Future<void> toggleProductActive(String id, bool isActive) async {
    await _firestore.collection(_collection).doc(id).update({
      'isActive': isActive,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Delete product
  Future<void> deleteProduct(String id) async {
    await _firestore.collection(_collection).doc(id).delete();
  }

  // Get categories
  Future<List<String>> getCategories() async {
    final snapshot = await _firestore.collection(_collection).get();
    final categories = snapshot.docs
        .map((doc) => (doc.data())['category'] as String? ?? 'Uncategorized')
        .toSet()
        .toList();
    categories.sort();
    return categories;
  }
}
