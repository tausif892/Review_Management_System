import 'product_model.dart'; // Import Product model

class Order {
  final String id;
  final String customerId;
  final List<OrderItem> items;
  final String status;
  final DateTime orderDate;
  final DateTime? deliveryDate;

  Order({
    required this.id,
    required this.customerId,
    required this.items,
    required this.status,
    required this.orderDate,
    this.deliveryDate,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['_id'],
      customerId: json['customerId'],
      items: (json['items'] as List)
          .map((item) => OrderItem.fromJson(item))
          .toList(),
      status: json['status'],
      orderDate: DateTime.parse(json['orderDate']),
      deliveryDate: json['deliveryDate'] != null
          ? DateTime.parse(json['deliveryDate'])
          : null,
    );
  }
}

class OrderItem {
  final String productId;
  final Product product;
  final int quantity;
  final double price;
  final bool hasReview;

  OrderItem({
    required this.productId,
    required this.product,
    required this.quantity,
    required this.price,
    required this.hasReview,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: json['productId'],
      product: Product.fromJson(json['product']),
      quantity: json['quantity'],
      price: json['price'].toDouble(),
      hasReview: json['hasReview'] ?? false,
    );
  }
}
