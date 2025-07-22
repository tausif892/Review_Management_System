const Review = require('../models/review');
const Product = require('../models/product'); // For updating rating after approval
const asyncHandler = require('express-async-handler');

const reviewController = {
  // ✅ Submit a new review (No auth required)
  submitReview: asyncHandler((req, res) => {
    const { productId, customerName = 'Anonymous', rating, comment } = req.body;

    if (!productId || !rating || !comment) {
      res.status(400);
      throw new Error('Product ID, rating, and comment are required.');
    }

    if (rating < 1 || rating > 5) {
      res.status(400);
      throw new Error('Rating must be between 1 and 5.');
    }
    console.log(`This message is before going into making new review`);
    // Use null for customerId if not needed
    Review.create({ productId, customerId: null, customerName, rating, comment }, (err, newReview) => {
      if (err) return res.status(500).json({ message: 'Failed to submit review', error: err.message });
      res.status(201).json(newReview);
    });
    console.log(`This comment is after going into making new review`);
  }),

  // ✅ Get approved reviews for a product (Public)
  getApprovedReviewsByProductId: asyncHandler((req, res) => {
    const { productId } = req.body;

    if (!productId) {
      res.status(400);
      throw new Error('Product ID is required in the request body.');
    }

    Review.getApprovedByProductId(productId, (err, reviews) => {
      if (err) return res.status(500).json({ message: 'Failed to fetch approved reviews', error: err.message });
      res.json(reviews);
    });
  }),

  // ✅ Get all reviews for moderation (Admin use)
  getAllReviewsForModeration: asyncHandler((req, res) => {
    const { productId } = req.body;

    if (!productId) {
      res.status(400);
      throw new Error('Product ID is required in the request body.');
    }

    Review.getAllByProductIdForModeration(productId, (err, reviews) => {
      if (err) return res.status(500).json({ message: 'Failed to fetch reviews', error: err.message });
      res.json(reviews);
    });
  }),

  // ✅ Update review status (Admin use)
  updateReviewStatus: asyncHandler((req, res) => {
    const { reviewId, status } = req.body;

    if (!reviewId || !status) {
      res.status(400);
      throw new Error('Review ID and status are required in the request body.');
    }

    const allowedStatuses = ['pending', 'approved', 'rejected'];
    if (!allowedStatuses.includes(status)) {
      res.status(400);
      throw new Error('Invalid status. Must be pending, approved, or rejected.');
    }

    Review.updateStatus(reviewId, status, (err, result) => {
      if (err) return res.status(500).json({ message: 'Failed to update status', error: err.message });
      res.json({ message: 'Review status updated successfully.', reviewId, newStatus: status });
    });
  }),

  // ✅ Get all reviews globally (Admin use)
  getAllReviews: asyncHandler((req, res) => {
    const { statusFilter } = req.body;

    Review.getAll(statusFilter, (err, reviews) => {
      if (err) return res.status(500).json({ message: 'Failed to fetch reviews', error: err.message });
      res.json(reviews);
    });
  })
};

module.exports = reviewController;
