const express = require('express');
const router = express.Router();
const reviewController = require('../controllers/reviewController');
const { authenticateToken, authorizeRole } = require('../middleware/auth');
const asyncHandler = require('express-async-handler'); 

// POST /api/reviews - Submit a new review (Customer Only)
router.post('/', reviewController.submitReview);

// POST /api/products/reviews/approved - Get approved reviews for a product (Public)
router.post('/products/reviews/approved', reviewController.getApprovedReviewsByProductId);

// POST /api/products/reviews/moderation - Get all reviews for a product (Admin Only)
router.post('/products/reviews/moderation', reviewController.getAllReviewsForModeration);

// PUT /api/reviews/status - Update review status (Admin Only)
router.put('/status', reviewController.updateReviewStatus);

// POST /api/reviews/all - Get all reviews (Global Admin View, optional)
router.post('/all',  reviewController.getAllReviews);

module.exports = router;
