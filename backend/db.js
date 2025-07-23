const sqlite3 = require('sqlite3').verbose();
const bcrypt = require('bcryptjs');
require('dotenv').config(); 
const DB_FILE = process.env.DB_FILE || './data/my_application.db';
const saltRounds = 10; 

const db = new sqlite3.Database(DB_FILE, (err) => {
    if (err) {
        console.error(`Error connecting to database: ${err.message}`);
    } else {
        console.log(`Connected to SQLite database: ${DB_FILE}`);
        db.serialize(() => {
            db.run(`
                CREATE TABLE IF NOT EXISTS users (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    email TEXT NOT NULL UNIQUE,
                    password TEXT NOT NULL,
                    name TEXT NOT NULL,
                    role TEXT NOT NULL DEFAULT 'customer'
                );
            `, (err) => {
                if (err) {
                    console.error("Error creating users table:", err.message);
                } else {
                    console.log("Users table created or already exists.");
                    const insertUser = db.prepare("INSERT OR IGNORE INTO users (email, password, name, role) VALUES (?, ?, ?, ?)");

                    bcrypt.hash('password123', saltRounds, (err, hash) => {
                        if (err) console.error("Error hashing password:", err.message);
                        insertUser.run('admin@example.com', hash, 'Admin User', 'admin', function(err) {
                            if (err) {
                                if (err.message.includes('UNIQUE constraint failed')) {
                                    console.log('Admin user already exists.');
                                } else {
                                    console.error("Error seeding admin user:", err.message);
                                }
                            } else if (this.changes > 0) {
                                console.log('Admin user seeded.');
                            }
                        });
                        insertUser.run('customer@example.com', hash, 'Customer User', 'customer', function(err) {
                            if (err) {
                                if (err.message.includes('UNIQUE constraint failed')) {
                                    console.log('Customer user already exists.');
                                } else {
                                    console.error("Error seeding customer user:", err.message);
                                }
                            } else if (this.changes > 0) {
                                console.log('Customer user seeded.');
                            }
                        });
                        insertUser.finalize();
                    });
                }
            });

            db.run(`
                CREATE TABLE IF NOT EXISTS products (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    name TEXT NOT NULL,
                    description TEXT,
                    price REAL NOT NULL,
                    image_url TEXT,
                    average_rating REAL DEFAULT 0.0,
                    review_count INTEGER DEFAULT 0
                );
            `, (err) => {
                if (err) {
                    console.error("Error creating products table:", err.message);
                } else {
                    console.log("Products table created or already exists.");
                    const insertProduct = db.prepare("INSERT OR IGNORE INTO products (id, name, description, price, image_url, average_rating, review_count) VALUES (?, ?, ?, ?, ?, ?, ?)");
                    
                    insertProduct.run(1, 'Wireless Headphones', 'High-quality wireless headphones with noise cancellation', 99.99, 'https://via.placeholder.com/300x300?text=Headphones', 4.5, 120);
                    insertProduct.run(2, 'Smartphone X', 'Latest smartphone with advanced camera features and AI', 599.99, 'https://via.placeholder.com/300x300?text=Smartphone', 4.2, 89);
                    insertProduct.run(3, 'Smart Watch Pro', 'Fitness tracker and smartwatch with long battery life', 199.99, 'https://via.placeholder.com/300x300?text=SmartWatch', 3.8, 45);
                    insertProduct.finalize();
                    console.log("Initial products seeded (if not already present).");
                }
            });

            db.run(`
                CREATE TABLE IF NOT EXISTS reviews (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    product_id INTEGER NOT NULL,
                    customer_id INTEGER ,
                    customer_name TEXT NOT NULL,
                    rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
                    comment TEXT,
                    status TEXT NOT NULL DEFAULT 'pending', -- 'pending', 'approved', 'rejected'
                    created_at TEXT NOT NULL,
                    FOREIGN KEY (product_id) REFERENCES products (id),
                    FOREIGN KEY (customer_id) REFERENCES users (id)
                );
            `, (err) => {
                if (err) {
                    console.error("Error creating reviews table:", err.message);
                } else {
                    console.log("Reviews table created or already exists.");
                    const insertReview = db.prepare("INSERT OR IGNORE INTO reviews (id, product_id, customer_id, customer_name, rating, comment, status, created_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?)");
                    insertReview.run(1, 1, 2, 'Jane Smith', 5, 'Excellent product! Highly recommended, great sound.', 'approved', new Date().toISOString());
                    insertReview.run(2, 1, 2, 'Bob Johnson', 4, 'Good headphones, comfortable but bass could be stronger.', 'pending', new Date(Date.now() - 2 * 24 * 60 * 60 * 1000).toISOString()); // 2 days ago
                    insertReview.run(3, 1, 2, 'Alice Green', 2, 'Broke after a week, very disappointed with the build quality.', 'rejected', new Date(Date.now() - 5 * 24 * 60 * 60 * 1000).toISOString()); // 5 days ago
                    insertReview.run(4, 2, 1, 'John Doe', 5, 'The Smartphone X is incredible! Best camera on the market.', 'approved', new Date(Date.now() - 3 * 24 * 60 * 60 * 1000).toISOString()); // 3 days ago
                    insertReview.finalize();
                    console.log("Initial reviews seeded (if not already present).");
                }
            });
        });
    }
});

module.exports = db; 
