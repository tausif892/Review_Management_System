var db = require('../db');

var Product = {
    getAll: function(callback) {
        db.all("SELECT * FROM products", [], function(err, rows) {
            if (err) {
                return callback(err);
            }
            callback(null, rows);
        });
    },

    getById: function(id, callback) {
        db.get("SELECT * FROM products WHERE id = ?", [id], function(err, row) {
            if (err) {
                return callback(err);
            }
            callback(null, row);
        });
    },

    create: function(productData, callback) {
        var name = productData.name;
        var description = productData.description;
        var price = productData.price;
        var imageUrl = productData.imageUrl;

        db.run(
            "INSERT INTO products (name, description, price, image_url) VALUES (?, ?, ?, ?)",
            [name, description, price, imageUrl],
            function(err) {
                if (err) {
                    return callback(err);
                }
                callback(null, {
                    id: this.lastID,
                    name: name,
                    description: description,
                    price: price,
                    imageUrl: imageUrl
                });
            }
        );
    },

    updateRating: function(productId, callback) {
        db.get(
            "SELECT AVG(rating) AS avg_rating, COUNT(id) AS review_count FROM reviews WHERE product_id = ? AND status = 'approved'",
            [productId],
            function(err, row) {
                if (err) {
                    console.error("Error calculating rating for product " + productId + ":", err.message);
                    return callback(err);
                }

                var averageRating = row.avg_rating || 0.0;
                var reviewCount = row.review_count || 0;

                db.run(
                    "UPDATE products SET average_rating = ?, review_count = ? WHERE id = ?",
                    [averageRating, reviewCount, productId],
                    function(err) {
                        if (err) {
                            console.error("Error updating product rating for " + productId + ":", err.message);
                            return callback(err);
                        }
                        console.log("Product " + productId + " rating updated. Changes: " + this.changes);
                        callback(null, {
                            productId: productId,
                            averageRating: averageRating,
                            reviewCount: reviewCount
                        });
                    }
                );
            }
        );
    }
};

module.exports = Product;
