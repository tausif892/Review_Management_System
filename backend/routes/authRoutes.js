const express = require('express');
const router = express.Router();
const authController = require('../controllers/authController'); // Import the new controller
const asyncHandler = require('express-async-handler'); // Import asyncHandler

// POST /api/auth/login
// Login logic is handled by authController.login, which uses asyncHandler
router.post('/login', authController.login);

// POST /api/auth/register (Optional - for testing, not directly used by current frontend)
// Registration logic is handled by authController.register, which uses asyncHandler
router.post('/register', authController.register);

module.exports = router;
