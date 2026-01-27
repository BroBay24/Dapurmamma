import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order_model.dart';

class OrderRepository {
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;
  static const String _collection = 'orders';

  // Real-time stream untuk admin (semua order)
  Stream<List<OrderModel>> getAllOrdersStream() {
    return _firestore
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => OrderModel.fromFirestore(doc))
            .toList());
  }

  // Stream order by status
  Stream<List<OrderModel>> getOrdersByStatusStream(OrderStatus status) {
    return _firestore
        .collection(_collection)
        .where('status', isEqualTo: OrderModel.statusToString(status))
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => OrderModel.fromFirestore(doc))
            .toList());
  }

  // Stream order by user (untuk user app)
  Stream<List<OrderModel>> getUserOrdersStream(String userId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          final orders = snapshot.docs
              .map((doc) => OrderModel.fromFirestore(doc))
              .toList();
          // Sort di client side untuk menghindari composite index
          orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return orders;
        });
  }

  // Get single order
  Future<OrderModel?> getOrder(String id) async {
    final doc = await _firestore.collection(_collection).doc(id).get();
    if (!doc.exists) return null;
    return OrderModel.fromFirestore(doc);
  }

  // Create order (dari user app)
  Future<String> createOrder(OrderModel order) async {
    // Generate human-readable order ID
    final count = await _getOrderCount();
    final orderId = 'ORD-${(count + 1).toString().padLeft(5, '0')}';

    final docRef = await _firestore.collection(_collection).add({
      'orderId': orderId,
      'userId': order.userId,
      'customerName': order.customerName,
      'items': order.items.map((e) => e.toMap()).toList(),
      'total': order.total,
      'paymentMethod': order.paymentMethod,
      'status': OrderModel.statusToString(OrderStatus.pending),
      'note': order.note,
      'adminNote': order.adminNote,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return docRef.id;
  }

  // Update order status (admin action)
  Future<void> updateOrderStatus(String id, OrderStatus status,
      {String? adminNote}) async {
    final updates = <String, dynamic>{
      'status': OrderModel.statusToString(status),
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (adminNote != null) {
      updates['adminNote'] = adminNote;
    }
    await _firestore.collection(_collection).doc(id).update(updates);
  }

  // Delete order (admin action)
  Future<void> deleteOrder(String id) async {
    await _firestore.collection(_collection).doc(id).delete();
  }

  // Get order count for ID generation
  Future<int> _getOrderCount() async {
    final countDoc =
        await _firestore.collection('_metadata').doc('orderCount').get();
    if (!countDoc.exists) {
      await _firestore
          .collection('_metadata')
          .doc('orderCount')
          .set({'count': 0});
      return 0;
    }
    final count = (countDoc.data())?['count'] ?? 0;

    // Increment count
    await _firestore
        .collection('_metadata')
        .doc('orderCount')
        .update({'count': FieldValue.increment(1)});

    return count;
  }

  // Get statistics (untuk dashboard)
  Future<Map<String, int>> getOrderStatistics() async {
    final snapshot = await _firestore.collection(_collection).get();

    int pending = 0;
    int processing = 0;
    int completed = 0;
    int cancelled = 0;
    int totalRevenue = 0;

    for (final doc in snapshot.docs) {
      final data = doc.data();
      final status = data['status'] as String?;
      final total = data['total'] as int? ?? 0;

      switch (status) {
        case 'pending':
          pending++;
          break;
        case 'processing':
          processing++;
          break;
        case 'completed':
          completed++;
          totalRevenue += total;
          break;
        case 'cancelled':
          cancelled++;
          break;
      }
    }

    return {
      'pending': pending,
      'processing': processing,
      'completed': completed,
      'cancelled': cancelled,
      'totalOrders': snapshot.docs.length,
      'totalRevenue': totalRevenue,
    };
  }
}
