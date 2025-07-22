import 'package:flutter/material.dart';
import '../../models/product_model.dart';
import '../../models/review_model.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart'; // Import for role checking
import '../../widgets/star_rating.dart';
import '../customer/write_review_screen.dart'; // Import for writing reviews

class ProductDetailsScreen extends StatefulWidget {
  final String productId;

  const ProductDetailsScreen({Key? key, required this.productId})
    : super(key: key);

  @override
  _ProductDetailsScreenState createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  Product? _product;
  List<Review> _reviews = [];
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadProductDetails();
  }

  Future<void> _loadProductDetails() async {
    final user = AuthService().currentUser;
    final isAdmin = user?.role == 'admin';

    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    try {
      final product = await ApiService().getProduct(widget.productId);
      List<Review> fetchedReviews;

      if (isAdmin) {
        // Admin gets all reviews for moderation
        fetchedReviews = await ApiService().getReviewsForModeration(
          widget.productId,
        );
      } else {
        // Customer only sees approved reviews
        fetchedReviews = await ApiService().getProductReviews(widget.productId);
      }

      setState(() {
        _product = product;
        _reviews = fetchedReviews;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading product details: ${e.toString()}'),
        ),
      );
    }
  }

  Future<void> _updateReviewStatus(String reviewId, String status) async {
    setState(() {
      _isLoading = true; // Show loading indicator while updating
    });
    try {
      final success = await ApiService().updateReviewStatus(reviewId, status);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Review status updated to $status!')),
        );
        _loadProductDetails(); // Reload reviews after update
      } else {
        throw Exception('Failed to update review status.');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating review status: ${e.toString()}'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;
    final isAdmin = user?.role == 'admin';

    return Scaffold(
      appBar: AppBar(title: Text(_product?.name ?? 'Product Details')),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _hasError
          ? Center(
              child: Text('Failed to load product details. Please try again.'),
            )
          : _product == null
          ? Center(child: Text('Product not found.'))
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProductInfoCard(),
                  SizedBox(height: 24),

                  // Customer "Write a Review" option
                  if (!isAdmin) // Only for customers
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    WriteReviewScreen(product: _product!),
                              ),
                            );
                            _loadProductDetails(); // Reload to see new pending review
                          },
                          icon: Icon(Icons.rate_review),
                          label: Text('Write a Review'),
                        ),
                      ),
                    ),

                  // Admin: Pending Reviews section
                  if (isAdmin) ...[
                    Text(
                      'Pending Reviews (${_reviews.where((r) => r.status == 'pending').length})',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    SizedBox(height: 16),
                    if (_reviews.where((r) => r.status == 'pending').isEmpty)
                      Center(
                        child: Text('No pending reviews for this product.'),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: _reviews
                            .where((r) => r.status == 'pending')
                            .length,
                        itemBuilder: (context, index) {
                          final review = _reviews
                              .where((r) => r.status == 'pending')
                              .toList()[index];
                          return AdminReviewCard(
                            // Use AdminReviewCard for moderation
                            review: review,
                            onApprove: _updateReviewStatus,
                            onReject: _updateReviewStatus,
                          );
                        },
                      ),
                    Divider(height: 32),
                  ],

                  // Approved Reviews (both customer and admin see these)
                  Text(
                    'Approved Reviews (${_reviews.where((r) => r.status == 'approved').length})',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  SizedBox(height: 16),
                  if (_reviews.where((r) => r.status == 'approved').isEmpty)
                    Center(child: Text('No approved reviews yet.'))
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: _reviews
                          .where((r) => r.status == 'approved')
                          .length,
                      itemBuilder: (context, index) {
                        final review = _reviews
                            .where((r) => r.status == 'approved')
                            .toList()[index];
                        return ReviewCard(
                          review: review,
                        ); // Standard review card
                      },
                    ),

                  // Admin: Rejected Reviews section (optional, for admin transparency)
                  if (isAdmin) ...[
                    Divider(height: 32),
                    Text(
                      'Rejected Reviews (${_reviews.where((r) => r.status == 'rejected').length})',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    SizedBox(height: 16),
                    if (_reviews.where((r) => r.status == 'rejected').isEmpty)
                      Center(
                        child: Text('No rejected reviews for this product.'),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: _reviews
                            .where((r) => r.status == 'rejected')
                            .length,
                        itemBuilder: (context, index) {
                          final review = _reviews
                              .where((r) => r.status == 'rejected')
                              .toList()[index];
                          return ReviewCard(
                            review: review,
                          ); // Standard review card
                        },
                      ),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildProductInfoCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  _product!.imageUrl,
                  width: 200,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 200,
                      height: 200,
                      color: Colors.grey[200],
                      child: Icon(
                        Icons.image_not_supported,
                        size: 80,
                        color: Colors.grey,
                      ),
                    );
                  },
                ),
              ),
            ),
            SizedBox(height: 16),
            Text(
              _product!.name,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            SizedBox(height: 8),
            Text(
              _product!.description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '\$${_product!.price.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
            Divider(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Average Rating:',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    SizedBox(height: 4),
                    StarRating(rating: _product!.averageRating, size: 30),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Total Reviews:',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    SizedBox(height: 4),
                    Text(
                      _product!.reviewCount.toString(),
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Standard Review Card for display (used by both customer and admin for approved/rejected)
class ReviewCard extends StatelessWidget {
  final Review review;

  const ReviewCard({Key? key, required this.review}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  review.customerName ?? '',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                StarRating(rating: review.rating.toDouble(), size: 18),
              ],
            ),
            SizedBox(height: 8),
            Text(
              review.comment ?? '',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            SizedBox(height: 8),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                'Reviewed on: ${review.createdAt.toString().split(' ')[0]}',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Admin Specific Review Card for moderation (only for pending reviews on ProductDetailsScreen)
class AdminReviewCard extends StatelessWidget {
  final Review review;
  final Function(String reviewId, String status) onApprove;
  final Function(String reviewId, String status) onReject;

  const AdminReviewCard({
    Key? key,
    required this.review,
    required this.onApprove,
    required this.onReject,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 2,
      color: Colors.orange[50], // Highlight pending reviews
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  review.customerName ?? '',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Chip(
                  label: Text(review.status.toUpperCase()),
                  backgroundColor: Colors.orange[100],
                  labelStyle: TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                StarRating(rating: review.rating.toDouble(), size: 20),
                SizedBox(width: 8),
                Text('for Product ID: ${review.productId}'),
              ],
            ),
            SizedBox(height: 8),
            Text(
              review.comment ?? '',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            SizedBox(height: 8),
            Text(
              'Submitted on: ${review.createdAt.toString().split(' ')[0]}',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () => onReject(review.id, 'rejected'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: BorderSide(color: Colors.red),
                  ),
                  child: Text('Reject'),
                ),
                SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () => onApprove(review.id, 'approved'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: Text('Approve'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
