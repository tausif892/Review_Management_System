import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user_model.dart';
import '../models/product_model.dart';
import '../models/review_model.dart';
import '../models/order_model.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final String _baseUrl = 'https://review-management-system-3qt5.onrender.com';
  final _storage = FlutterSecureStorage();

  Future<Map<String, String>> _setHeaders() async {
    final authToken = await _storage.read(key: 'authToken');
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (authToken != null) 'Authorization': 'Bearer $authToken',
    };
  }

  // Login
  Future<User?> login(String email, String password) async {
    final url = Uri.parse('$_baseUrl/auth/login');
    try {
      final response = await http.post(
        url,
        headers: await _setHeaders(),
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        await _storage.write(key: 'authToken', value: data['token']);
        await _storage.write(key: 'userRole', value: data['user']['role']);
        return User.fromJson(data['user']);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to log in');
      }
    } catch (e) {
      print('Login API Error: $e');
      rethrow;
    }
  }

  Future<User?> getCurrentUser() async {
    final token = await _storage.read(key: 'authToken');
    final role = await _storage.read(key: 'userRole');

    if (token != null && role != null) {
      return User(
        id: 'mock_id',
        name: 'Logged In User',
        email: 'logged@example.com',
        role: role,
      );
    }
    return null;
  }

  Future<void> logout() async {
    await _storage.delete(key: 'authToken');
    await _storage.delete(key: 'userRole');
  }

  Future<List<Product>> getProducts() async {
    final url = Uri.parse('$_baseUrl/products/');
    try {
      final response = await http.get(url, headers: await _setHeaders());
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Product.fromJson(json)).toList();
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to load products');
      }
    } catch (e) {
      print('Get Products API Error: $e');
      rethrow;
    }
  }

  Future<Product> getProduct(String productId) async {
    final url = Uri.parse('$_baseUrl/products/details');
    try {
      final response = await http.post(
        url,
        headers: await _setHeaders(),
        body: jsonEncode({'id': int.parse(productId)}),
      );

      if (response.statusCode == 200) {
        return Product.fromJson(jsonDecode(response.body));
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(
          errorData['message'] ?? 'Failed to load product details',
        );
      }
    } catch (e) {
      print('Get Product API Error: $e');
      rethrow;
    }
  }

  Future<bool> addProduct({
    required String name,
    required String description,
    required double price,
    String imageUrl = 'lib/assets/images/product_image.png',
  }) async {
    final url = Uri.parse('$_baseUrl/products');
    try {
      final response = await http.post(
        url,
        headers: await _setHeaders(),
        body: jsonEncode({
          'name': name,
          'description': description,
          'price': price,
          'imageUrl': imageUrl,
        }),
      );

      return response.statusCode == 201;
    } catch (e) {
      print('Add Product API Error: $e');
      rethrow;
    }
  }

  Future<bool> submitReview({
    required String productId,
    required int rating,
    required String comment,
  }) async {
    final url = Uri.parse('$_baseUrl/reviews');
    try {
      final response = await http.post(
        url,
        headers: await _setHeaders(),
        body: jsonEncode({
          'productId': productId,
          'rating': rating,
          'comment': comment,
        }),
      );
      return response.statusCode == 201;
    } catch (e) {
      print('Submit Review API Error: $e');
      rethrow;
    }
  }

  Future<List<Review>> getProductReviews(String productId) async {
    final url = Uri.parse('$_baseUrl/reviews/products/reviews/approved');
    try {
      final response = await http.post(
        url,
        headers: await _setHeaders(),
        body: jsonEncode({'productId': int.parse(productId)}),
      );
      if (response.statusCode == 200) {
        final List<dynamic> reviewsJson = jsonDecode(response.body);
        return reviewsJson.map((json) => Review.fromJson(json)).toList();
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(
          errorData['message'] ?? 'Failed to load approved reviews',
        );
      }
    } catch (e) {
      print('Get Approved Reviews API Error: $e');
      rethrow;
    }
  }

  Future<List<Review>> getReviewsForModeration(String productId) async {
    final url = Uri.parse('$_baseUrl/reviews/products/reviews/moderation');
    final token = await _storage.read(key: 'authToken');
    print("Token before going in moderation is $token");
    try {
      final response = await http.post(
        url,
        headers: await _setHeaders(),
        body: jsonEncode({'productId': int.parse(productId)}),
      );
      if (response.statusCode == 200) {
        final List<dynamic> reviewsJson = jsonDecode(response.body);
        return reviewsJson.map((json) => Review.fromJson(json)).toList();
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(
          errorData['message'] ?? 'Failed to load moderation reviews',
        );
      }
    } catch (e) {
      print('Get Moderation Reviews API Error: $e');
      rethrow;
    }
  }

  Future<bool> updateReviewStatus(String reviewId, String status) async {
    final url = Uri.parse('$_baseUrl/reviews/status');
    try {
      final response = await http.put(
        url,
        headers: await _setHeaders(),
        body: jsonEncode({'reviewId': reviewId, 'status': status}),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Update Review Status API Error: $e');
      rethrow;
    }
  }

  Future<List<Review>> getReviews({String? status}) async {
    final url = Uri.parse('$_baseUrl/reviews/all');
    try {
      final response = await http.post(
        url,
        headers: await _setHeaders(),
        body: jsonEncode({'statusFilter': status}),
      );
      if (response.statusCode == 200) {
        final List<dynamic> reviewsJson = jsonDecode(response.body);
        return reviewsJson.map((json) => Review.fromJson(json)).toList();
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(
          errorData['message'] ?? 'Failed to load global reviews',
        );
      }
    } catch (e) {
      print('Get Global Reviews API Error: $e');
      rethrow;
    }
  }

  Future<List<Order>> getCustomerOrders(String customerId) async {
    print(
      'getCustomerOrders called, but order history is removed from frontend.',
    );
    return [];
  }
}
