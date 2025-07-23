const express = require('express');
const router = express.Router();
const productController = require('../controllers/productController');
const { authenticateToken, authorizeRole } = require('../middleware/auth');
const asyncHandler = require('express-async-handler'); // Import asyncHandler

// GET /api/products - Get all products (Public)
router.get('/', productController.getAllProducts);

// POST /api/products/details - Get a single product by ID (expects ID in body)
router.post('/details', productController.getProductById);

// POST /api/products - Add a new product (Admin Only)
router.post('/', productController.createProduct);

module.exports = router;
