class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final double averageRating;
  final int reviewCount;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.averageRating,
    required this.reviewCount,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    print("Product JSON : $json");
    return Product(
      id: json['id'].toString() ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      imageUrl: json['imageUrl'] ?? 'https://via.placeholder.com/300x300',
      averageRating: (json['averageRating'] ?? 0).toDouble(),
      reviewCount: json['reviewCount'] ?? 0,
    );
  }
}
