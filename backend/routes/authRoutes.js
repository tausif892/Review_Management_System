const express = require('express');
const router = express.Router();
const authController = require('../controllers/authController'); 
const asyncHandler = require('express-async-handler'); 

router.post('/login', authController.login);

router.post('/register', authController.register);

module.exports = router;
