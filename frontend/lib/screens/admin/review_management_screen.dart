import 'package:flutter/material.dart';
import '../../models/review_model.dart';
import '../../services/api_service.dart';
import '../../widgets/star_rating.dart';
import '../../screens/product/product_details_screen.dart';

// This screen provides a global list of reviews for admin,
// supplementary to product-specific moderation on ProductDetailsScreen.
class ReviewManagementScreen extends StatefulWidget {
  @override
  _ReviewManagementScreenState createState() => _ReviewManagementScreenState();
}

class _ReviewManagementScreenState extends State<ReviewManagementScreen> {
  List<Review> _reviews = [];
  bool _isLoading = true;
  String _currentFilter = 'pending'; // 'pending', 'approved', 'rejected', 'all'

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final reviews = await ApiService().getReviews(status: _currentFilter);
      setState(() {
        _reviews = reviews;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading reviews: ${e.toString()}')),
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
        _loadReviews(); // Reload reviews after update
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
    return Scaffold(
      appBar: AppBar(title: Text('Manage Reviews (Global View)')),
      body: Column(
        children: [
          _buildFilterChips(),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _reviews.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.rate_review_outlined,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text('No reviews found for this filter.'),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: _reviews.length,
                    itemBuilder: (context, index) {
                      final review = _reviews[index];
                      return AdminReviewCard(
                        // Reusing AdminReviewCard from product_details_screen
                        review: review,
                        onApprove: _updateReviewStatus,
                        onReject: _updateReviewStatus,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Wrap(
        spacing: 8.0,
        children: [
          FilterChip(
            label: Text('Pending'),
            selected: _currentFilter == 'pending',
            onSelected: (selected) {
              if (selected) {
                setState(() {
                  _currentFilter = 'pending';
                });
                _loadReviews();
              }
            },
          ),
          FilterChip(
            label: Text('Approved'),
            selected: _currentFilter == 'approved',
            onSelected: (selected) {
              if (selected) {
                setState(() {
                  _currentFilter = 'approved';
                });
                _loadReviews();
              }
            },
          ),
          FilterChip(
            label: Text('Rejected'),
            selected: _currentFilter == 'rejected',
            onSelected: (selected) {
              if (selected) {
                setState(() {
                  _currentFilter = 'rejected';
                });
                _loadReviews();
              }
            },
          ),
          FilterChip(
            label: Text('All Reviews'),
            selected: _currentFilter == 'all',
            onSelected: (selected) {
              if (selected) {
                setState(() {
                  _currentFilter = 'all';
                });
                _loadReviews();
              }
            },
          ),
        ],
      ),
    );
  }
}
