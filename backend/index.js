const express = require('express');
const bodyParser = require('body-parser');
require('dotenv').config(); // Load environment variables
require('./db'); // Initialize database and tables

const authRoutes = require('./routes/authRoutes');
const productRoutes = require('./routes/productRoutes');
const reviewRoutes = require('./routes/reviewsRoutes');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(express.json());
app.use(bodyParser.json()); // To parse JSON request bodies
app.use(bodyParser.urlencoded({ extended: true })); // To parse URL-encoded request bodies

// CORS (Cross-Origin Resource Sharing) - essential for frontend to communicate
app.use((req, res, next) => {
    res.setHeader('Access-Control-Allow-Origin', '*'); // Allow all origins for development
    res.setHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
    res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');
    if (req.method === 'OPTIONS') {
        return res.sendStatus(200);
    }
    next();
});

// Routes
app.use('/api/auth', authRoutes);
app.use('/api/products', productRoutes);
app.use('/api/reviews', reviewRoutes);

// Basic root route
app.get('/', (req, res) => {
    res.send('Product Review System Backend API is running!');
});

// Start the server
app.listen(PORT, () => {
    console.log(`Server is running on port ${PORT}`);
    console.log(`Access it at http://localhost:${PORT}`);
});
