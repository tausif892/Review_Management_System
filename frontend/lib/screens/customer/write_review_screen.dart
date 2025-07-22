import 'package:flutter/material.dart';
import '../../models/product_model.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../widgets/interactive_star_rating.dart';

class WriteReviewScreen extends StatefulWidget {
  final Product? product;

  const WriteReviewScreen({Key? key, this.product}) : super(key: key);

  @override
  _WriteReviewScreenState createState() => _WriteReviewScreenState();
}

class _WriteReviewScreenState extends State<WriteReviewScreen> {
  final _commentController = TextEditingController();
  int _rating = 5;
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    if (widget.product == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Write Review')),
        body: Center(child: Text('Product not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Write Review')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        widget.product!.imageUrl,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 80,
                            height: 80,
                            color: Colors.grey[200],
                            child: Icon(Icons.image_not_supported),
                          );
                        },
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.product!.name,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          SizedBox(height: 8),
                          Text('\$${widget.product!.price.toStringAsFixed(2)}'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),
            Text('Your Rating', style: Theme.of(context).textTheme.titleMedium),
            SizedBox(height: 8),
            InteractiveStarRating(
              initialRating: _rating,
              onRatingChanged: (rating) {
                setState(() {
                  _rating = rating;
                });
              },
            ),
            SizedBox(height: 24),
            Text('Your Review', style: Theme.of(context).textTheme.titleMedium),
            SizedBox(height: 8),
            TextField(
              controller: _commentController,
              decoration: InputDecoration(
                hintText: 'Share your experience with this product...',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
            SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitReview,
                child: _isSubmitting
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text('Submit Review'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitReview() async {
    if (_commentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please write a review')));
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final user = AuthService().currentUser;
      if (user != null) {
        final success = await ApiService().submitReview(
          productId: widget.product!.id,
          rating: _rating,
          comment: _commentController.text.trim(),
        );

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Review submitted successfully! It will appear after admin approval.',
              ),
            ),
          );
          Navigator.pop(
            context,
          ); // Go back to product details or previous screen
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting review: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
}
