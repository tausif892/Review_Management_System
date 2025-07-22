const Product = require('../models/product');

const productController = {
    getAllProducts: (req, res) => {
        Product.getAll((err, products) => {
            if (err) {
                console.error("Error getting all products:", err);
                return res.status(500).json({ message: 'Error retrieving products.' });
            }
            res.json(products);
        });
    },

    getProductById: (req, res) => {
        const id = req.body.id;
        Product.getById(id, (err, product) => {
            if (err) {
                console.error(`Error getting product ${id}:`, err);
                return res.status(500).json({ message: 'Error retrieving product.' });
            }
            if (!product) {
                return res.status(404).json({ message: 'Product not found.' });
            }
            res.json(product);
        });
    },

    /**
     * Creates a new product. (Admin Only)
     * @param {object} req - Express request object.
     * @param {object} res - Express response object.
     */
    createProduct: (req, res) => {
        const { name, description, price, imageUrl } = req.body;

        if (!name || !price) {
            return res.status(400).json({ message: 'Product name and price are required.' });
        }

        Product.create({ name, description, price, imageUrl }, (err, newProduct) => {
            if (err) {
                console.error("Error creating product:", err);
                return res.status(500).json({ message: 'Error adding product.' });
            }
            res.status(201).json(newProduct);
        });
    }
};

module.exports = productController;
