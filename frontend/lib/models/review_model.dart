class Review {
  final String id;
  final String productId;
  final String customerId;
  final String? customerName; // Nullable
  final int rating;
  final String? comment; // Nullable
  final String status;
  final DateTime createdAt;

  Review({
    required this.id,
    required this.productId,
    required this.customerId,
    this.customerName,
    this.comment,
    required this.rating,
    required this.status,
    required this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    print('Review JSON: $json'); // helpful debug
    return Review(
      id: json['id'].toString(),
      productId: json['product_id'].toString(),
      customerId: json['customer_id'].toString(),
      customerName: json['customer_name']?.toString() ?? 'Anonymous',
      comment: json['comment']?.toString() ?? '',
      rating: json['rating'] is int
          ? json['rating']
          : int.tryParse(json['rating'].toString()) ?? 0,
      status: json['status'].toString(),
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
