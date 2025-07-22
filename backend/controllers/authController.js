const User = require('../models/user');
const argon2 = require('argon2');
const jwt = require('jsonwebtoken');
const asyncHandler = require('express-async-handler');
require('dotenv').config();

const JWT_SECRET = process.env.JWT_SECRET;

const authController = {
    /**
     * Handles user login.
     */
    login: asyncHandler(async (req, res) => {
        const { email, password } = req.body;

        if (!email || !password) {
            res.status(400);
            throw new Error('Email and password are required.');
        }

        const user = await User.findByEmail(email);
        if (!user) {
            res.status(400);
            throw new Error('Invalid email or password.');
        }

        const isMatch = await argon2.verify(user.password, password);
        if (!isMatch) {
            res.status(400);
            throw new Error('Invalid email or password.');
        }

        const token = jwt.sign(
            { id: user.id, email: user.email, role: user.role },
            JWT_SECRET,
            { expiresIn: '1h' }
        );

        res.json({
            user: {
                id: user.id,
                name: user.name,
                email: user.email,
                role: user.role
            },
            token
        });
    }),

    /**
     * Handles user registration.
     */
    register: asyncHandler(async (req, res) => {
        const { email, password, name, role } = req.body;

        if (!email || !password || !name) {
            res.status(400);
            throw new Error('Email, password, and name are required for registration.');
        }

        try {
            const hashedPassword = await argon2.hash(password);

            const newUser = await User.create({
                email,
                password: hashedPassword,
                name,
                role
            });

            res.status(201).json({
                message: 'User registered successfully.',
                user: newUser
            });
        } catch (err) {
            if (err.message.includes('UNIQUE constraint failed')) {
                res.status(409);
                throw new Error('Email already registered.');
            }

            console.error("Registration error:", err);
            res.status(500);
            throw new Error('Server error during registration.');
        }
    })
};

module.exports = authController;
