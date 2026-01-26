import 'package:cloud_firestore/cloud_firestore.dart';

enum OrderStatus { pending, processing, completed, cancelled }

class OrderItemModel {
  final String productId;
  final String productName;
  final int quantity;
  final int price;

  OrderItemModel({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
  });

  factory OrderItemModel.fromMap(Map<String, dynamic> data) {
    return OrderItemModel(
      productId: data['productId'] ?? '',
      productName: data['productName'] ?? '',
      quantity: data['quantity'] ?? 0,
      price: data['price'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'price': price,
    };
  }
}

class OrderModel {
  final String id;
  final String oderId; // Human-readable ID like "ID-01"
  final String userId;
  final String customerName;
  final List<OrderItemModel> items;
  final int total;
  final String paymentMethod;
  final OrderStatus status;
  final String? note;
  final String? adminNote;
  final DateTime createdAt;
  final DateTime updatedAt;

  OrderModel({
    required this.id,
    required this.oderId,
    required this.userId,
    required this.customerName,
    required this.items,
    required this.total,
    required this.paymentMethod,
    required this.status,
    this.note,
    this.adminNote,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final itemsList = (data['items'] as List<dynamic>?)
            ?.map((e) => OrderItemModel.fromMap(e as Map<String, dynamic>))
            .toList() ??
        [];

    return OrderModel(
      id: doc.id,
      oderId: data['orderId'] ?? '',
      userId: data['userId'] ?? '',
      customerName: data['customerName'] ?? '',
      items: itemsList,
      total: data['total'] ?? 0,
      paymentMethod: data['paymentMethod'] ?? '',
      status: _parseStatus(data['status']),
      note: data['note'],
      adminNote: data['adminNote'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  static OrderStatus _parseStatus(String? status) {
    switch (status) {
      case 'processing':
        return OrderStatus.processing;
      case 'completed':
        return OrderStatus.completed;
      case 'cancelled':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.pending;
    }
  }

  static String statusToString(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'pending';
      case OrderStatus.processing:
        return 'processing';
      case OrderStatus.completed:
        return 'completed';
      case OrderStatus.cancelled:
        return 'cancelled';
    }
  }

  static String statusToLabel(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'Menunggu';
      case OrderStatus.processing:
        return 'Diproses';
      case OrderStatus.completed:
        return 'Selesai';
      case OrderStatus.cancelled:
        return 'Dibatalkan';
    }
  }

  Map<String, dynamic> toFirestore() {
    return {
      'orderId': oderId,
      'userId': userId,
      'customerName': customerName,
      'items': items.map((e) => e.toMap()).toList(),
      'total': total,
      'paymentMethod': paymentMethod,
      'status': statusToString(status),
      'note': note,
      'adminNote': adminNote,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  OrderModel copyWith({
    String? id,
    String? oderId,
    String? userId,
    String? customerName,
    List<OrderItemModel>? items,
    int? total,
    String? paymentMethod,
    OrderStatus? status,
    String? note,
    String? adminNote,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return OrderModel(
      id: id ?? this.id,
      oderId: oderId ?? this.oderId,
      userId: userId ?? this.userId,
      customerName: customerName ?? this.customerName,
      items: items ?? this.items,
      total: total ?? this.total,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      note: note ?? this.note,
      adminNote: adminNote ?? this.adminNote,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
