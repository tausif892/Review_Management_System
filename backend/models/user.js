const db = require('../db');
const argon2 = require('argon2');

const User = {
    // Find a user by email
    findByEmail: (email) => {
        return new Promise((resolve, reject) => {
            db.get("SELECT * FROM users WHERE email = ?", [email], (err, row) => {
                if (err) return reject(err);
                resolve(row);
            });
        });
    },

    // Find a user by ID
    findById: (id) => {
        return new Promise((resolve, reject) => {
            db.get("SELECT * FROM users WHERE id = ?", [id], (err, row) => {
                if (err) return reject(err);
                resolve(row);
            });
        });
    },

    // Create a new user (uses argon2 for password hashing)
    create: async (userData) => {
        try {
            const hashedPassword = await argon2.hash(userData.password);
            const { email, name, role } = userData;

            return new Promise((resolve, reject) => {
                db.run(
                    "INSERT INTO users (email, password, name, role) VALUES (?, ?, ?, ?)",
                    [email, hashedPassword, name, role || 'customer'],
                    function (err) {
                        if (err) return reject(err);
                        resolve({
                            id: this.lastID,
                            email,
                            name,
                            role: role || 'customer'
                        });
                    }
                );
            });
        } catch (err) {
            throw err; // allow the calling function to handle hashing errors
        }
    }
};

module.exports = User;
