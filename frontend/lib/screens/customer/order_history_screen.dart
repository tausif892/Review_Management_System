import 'package:flutter/material.dart';
import '../../models/order_model.dart';
import '../../models/product_model.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import 'write_review_screen.dart';

class OrderHistoryScreen extends StatefulWidget {
  @override
  _OrderHistoryScreenState createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  List<Order> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    try {
      final user = AuthService().currentUser;
      if (user != null) {
        final orders = await ApiService().getCustomerOrders(user.id);
        setState(() {
          _orders = orders;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading orders: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order History'),
        actions: [
          IconButton(
            icon: Icon(Icons.store),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/products');
            },
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await AuthService().logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _orders.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_bag_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text('No orders found'),
                ],
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: _orders.length,
              itemBuilder: (context, index) {
                final order = _orders[index];
                return OrderCard(order: order);
              },
            ),
    );
  }
}

class OrderCard extends StatelessWidget {
  final Order order;

  const OrderCard({Key? key, required this.order}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order #${order.id}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Chip(
                  label: Text(order.status.toUpperCase()),
                  backgroundColor: order.status == 'delivered'
                      ? Colors.green[100]
                      : Colors.orange[100],
                ),
              ],
            ),
            SizedBox(height: 8),
            Text('Order Date: ${order.orderDate.toString().split(' ')[0]}'),
            if (order.deliveryDate != null)
              Text(
                'Delivered: ${order.deliveryDate!.toString().split(' ')[0]}',
              ),
            SizedBox(height: 16),
            ...order.items
                .map(
                  (item) => OrderItemCard(
                    item: item,
                    canReview: order.status == 'delivered',
                  ),
                )
                .toList(),
          ],
        ),
      ),
    );
  }
}

class OrderItemCard extends StatelessWidget {
  final OrderItem item;
  final bool canReview;

  const OrderItemCard({Key? key, required this.item, required this.canReview})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              item.product.imageUrl,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 60,
                  height: 60,
                  color: Colors.grey[200],
                  child: Icon(Icons.image_not_supported),
                );
              },
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                Text('Qty: ${item.quantity}'),
                Text('\$${item.price.toStringAsFixed(2)}'),
              ],
            ),
          ),
          if (canReview && !item.hasReview)
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        WriteReviewScreen(product: item.product),
                  ),
                );
              },
              child: Text('Write Review'),
            ),
          if (item.hasReview)
            Text(
              'Review Submitted',
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
    );
  }
}
