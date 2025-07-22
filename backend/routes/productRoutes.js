const express = require('express');
const router = express.Router();
const productController = require('../controllers/productController');
const { authenticateToken, authorizeRole } = require('../middleware/auth');
const asyncHandler = require('express-async-handler'); // Import asyncHandler

// GET /api/products - Get all products (Public)
// Logic handled by productController.getAllProducts, which uses asyncHandler
router.get('/', productController.getAllProducts);

// POST /api/products/details - Get a single product by ID (expects ID in body)
// Using POST for ID in body as GET with body is not standard and can cause issues.
// Logic handled by productController.getProductById, which uses asyncHandler
router.post('/details', productController.getProductById);

// POST /api/products - Add a new product (Admin Only)
// Protected by authenticateToken and authorizeRole middleware
// Logic handled by productController.createProduct, which uses asyncHandler
router.post('/', authenticateToken, authorizeRole(['admin']), productController.createProduct);

module.exports = router;
