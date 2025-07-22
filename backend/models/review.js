const db = require('../db');
const Product = require('./product'); // To update product rating

const Review = {
    // Create a new review
    create: (reviewData, callback) => {
        const { productId, customerId, customerName, rating, comment } = reviewData;
        const status = 'pending'; // Always pending on creation
        const createdAt = new Date().toISOString(); // ISO 8601 format

        db.run("INSERT INTO reviews (product_id, customer_id, customer_name, rating, comment, status, created_at) VALUES (?, ?, ?, ?, ?, ?, ?)",
            [productId, customerId, customerName, rating, comment, status, createdAt],
            function(err) {
                if (err) {
                    return callback(err);
                }
                // No need to update product rating immediately, as it's pending
                callback(null, { id: this.lastID, ...reviewData, status, createdAt });
            }
        );
    },

    // Get approved reviews for a specific product (for customer view)
    getApprovedByProductId: (productId, callback) => {
        db.all("SELECT * FROM reviews WHERE product_id = ? AND status = 'approved' ORDER BY created_at DESC",
            [productId],
            (err, rows) => {
                if (err) {
                    return callback(err);
                }
                callback(null, rows);
            }
        );
    },

    // Get all reviews for a specific product (for admin moderation)
    getAllByProductIdForModeration: (productId, callback) => {
        db.all("SELECT * FROM reviews WHERE product_id = ? ORDER BY created_at DESC",
            [productId],
            (err, rows) => {
                if (err) {
                    return callback(err);
                }
                callback(null, rows);
            }
        );
    },

    // Get all reviews (global list for admin)
    getAll: (statusFilter, callback) => {
        let query = "SELECT * FROM reviews";
        const params = [];
        if (statusFilter && statusFilter !== 'all') {
            query += " WHERE status = ?";
            params.push(statusFilter);
        }
        query += " ORDER BY created_at DESC";

        db.all(query, params, (err, rows) => {
            if (err) {
                return callback(err);
            }
            callback(null, rows);
        });
    },

    // Update review status
    updateStatus: (reviewId, newStatus, callback) => {
        db.run("UPDATE reviews SET status = ? WHERE id = ?",
            [newStatus, reviewId],
            function(err) {
                if (err) {
                    return callback(err);
                }
                if (this.changes === 0) {
                    return callback(new Error("Review not found or status not changed."));
                }
                // After updating review status, update the product's average rating and count
                db.get("SELECT product_id FROM reviews WHERE id = ?", [reviewId], (err, row) => {
                    if (err || !row) {
                        console.error("Could not find product_id for review:", err);
                        return callback(null, { message: "Review status updated, but product rating not recalculated." });
                    }
                    Product.updateRating(row.product_id, (err, result) => {
                        if (err) {
                            console.error("Failed to update product rating after review status change:", err);
                        } else {
                            console.log("Product rating recalculated:", result);
                        }
                        callback(null, { id: reviewId, status: newStatus, changes: this.changes });
                    });
                });
            }
        );
    }
};

module.exports = Review;
