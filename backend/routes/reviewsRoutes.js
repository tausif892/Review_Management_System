const express = require('express');
const router = express.Router();
const reviewController = require('../controllers/reviewController');
const { authenticateToken, authorizeRole } = require('../middleware/auth');
const asyncHandler = require('express-async-handler'); // Import asyncHandler

// POST /api/reviews - Submit a new review (Customer Only)
// Expects productId, rating, comment in req.body. Customer ID/Name from token.
// Protected by authenticateToken and authorizeRole middleware
// Logic handled by reviewController.submitReview, which uses asyncHandler
router.post('/', reviewController.submitReview);

// POST /api/products/reviews/approved - Get approved reviews for a product (Public)
// Expects productId in req.body.
// Logic handled by reviewController.getApprovedReviewsByProductId, which uses asyncHandler
// Note: Changed from GET with path param to POST with body param for consistency with req.body requirement
router.post('/products/reviews/approved', reviewController.getApprovedReviewsByProductId);

// POST /api/products/reviews/moderation - Get all reviews for a product (Admin Only)
// Expects productId in req.body.
// Protected by authenticateToken and authorizeRole middleware
// Logic handled by reviewController.getAllReviewsForModeration, which uses asyncHandler
// Note: Changed from GET with path param to POST with body param for consistency with req.body requirement
router.post('/products/reviews/moderation', reviewController.getAllReviewsForModeration);

// PUT /api/reviews/status - Update review status (Admin Only)
// Expects reviewId and status in req.body.
// Protected by authenticateToken and authorizeRole middleware
// Logic handled by reviewController.updateReviewStatus, which uses asyncHandler
// Note: Changed from PUT with path param to PUT with body param for reviewId for consistency with req.body requirement
router.put('/status', reviewController.updateReviewStatus);

// POST /api/reviews/all - Get all reviews (Global Admin View, optional)
// Expects statusFilter in req.body (optional).
// Protected by authenticateToken and authorizeRole middleware
// Logic handled by reviewController.getAllReviews, which uses asyncHandler
// Note: Changed from GET with query param to POST with body param for consistency with req.body requirement
router.post('/all',  reviewController.getAllReviews);

module.exports = router;
