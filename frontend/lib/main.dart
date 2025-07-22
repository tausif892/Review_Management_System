import 'package:flutter/material.dart';
import 'screens/auth/login_screen.dart';
import 'screens/customer/order_history_screen.dart';
import 'screens/customer/write_review_screen.dart';
import 'screens/admin/admin_dashboard_screen.dart';
import 'screens/admin/review_management_screen.dart'; // Still present, but less central for product-based moderation
import 'screens/admin/add_product_screen.dart'; // New import
import 'screens/product/product_details_screen.dart';
import 'screens/product/products_screen.dart';
import 'models/user_model.dart';
import 'services/auth_service.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Product Review System',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: AuthWrapper(),
      routes: {
        '/login': (context) => LoginScreen(),
        '/customer/orders': (context) => OrderHistoryScreen(),
        '/customer/write-review': (context) => WriteReviewScreen(),
        '/admin/dashboard': (context) => AdminDashboardScreen(),
        '/admin/reviews': (context) => ReviewManagementScreen(),
        '/admin/add-product': (context) => AddProductScreen(), // New route
        '/products': (context) => ProductsScreen(),
        // Note: product_details_screen is navigated to directly via MaterialPageRoute
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User?>(
      future: AuthService().getCurrentUser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (snapshot.hasData && snapshot.data != null) {
          final user = snapshot.data!;
          // Both admin and customer land on ProductsScreen for this simplified flow
          return ProductsScreen();
        }

        return LoginScreen();
      },
    );
  }
}
