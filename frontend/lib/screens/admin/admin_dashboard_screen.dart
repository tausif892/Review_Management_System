import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

// This screen is less central in the new simplified flow,
// as admin moderation is primarily done from ProductDetailsScreen.
// However, it can still serve as a hub if more admin features are added.
class AdminDashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await AuthService().logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.admin_panel_settings,
                size: 100,
                color: Theme.of(context).primaryColor,
              ),
              SizedBox(height: 24),
              Text(
                'Welcome, Admin!',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 40),
              // Option to go to products (which is now the main entry for moderation)
              SizedBox(
                width: 250,
                height: 60,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushReplacementNamed(
                      context,
                      '/products',
                    ); // Go to products list
                  },
                  icon: Icon(Icons.store),
                  label: Text('View Products', style: TextStyle(fontSize: 18)),
                ),
              ),
              SizedBox(height: 20),
              // Still keep the global review management option if desired
              SizedBox(
                width: 250,
                height: 60,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/admin/reviews',
                    ); // Go to global review list
                  },
                  icon: Icon(Icons.rate_review),
                  label: Text(
                    'Manage All Reviews (Global)',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
              // Add more admin functionalities here if needed
            ],
          ),
        ),
      ),
    );
  }
}
