import '../models/user_model.dart'; // Corrected import path for User model

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  User? _currentUser;

  User? get currentUser => _currentUser;

  Future<User?> getCurrentUser() async {
    // Simulate API call
    await Future.delayed(Duration(seconds: 1));
    // Return mock user for demo - replace with actual API call
    // For a cleaner demo of the new functionality, let's default to customer
    // to easily access order history for reviews.
    _currentUser = User(
      id: '1',
      name: 'John Doe',
      email: 'john@example.com',
      role: 'customer',
    );
    return _currentUser;
  }

  Future<bool> login(String email, String password) async {
    // Simulate login API call
    await Future.delayed(Duration(seconds: 2));

    // Mock login logic - replace with actual API call
    if (email == 'admin@example.com') {
      _currentUser = User(
        id: '1',
        name: 'Admin User',
        email: email,
        role: 'admin',
      );
    } else {
      _currentUser = User(
        id: '2',
        name: 'Customer User',
        email: email,
        role: 'customer',
      );
    }
    return true;
  }

  Future<void> logout() async {
    _currentUser = null;
  }
}
