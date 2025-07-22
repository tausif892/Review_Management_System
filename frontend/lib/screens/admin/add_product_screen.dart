import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({Key? key}) : super(key: key);

  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _imageUrlController =
      TextEditingController(); // Optional, can be auto-generated placeholder
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill with a placeholder image URL for easy testing
    _imageUrlController.text =
        'https://via.placeholder.com/300x300?text=NewProduct';
  }

  Future<void> _addProduct() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      try {
        final success = await ApiService().addProduct(
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          price: double.parse(_priceController.text.trim()),
          imageUrl: _imageUrlController.text.trim().isEmpty
              ? 'https://via.placeholder.com/300x300?text=NewProduct'
              : _imageUrlController.text.trim(),
        );

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Product added successfully!')),
          );
          Navigator.pop(context); // Go back to products list
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Failed to add product.')));
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding product: ${e.toString()}')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add New Product')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Product Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a product name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(
                  labelText: 'Price',
                  border: OutlineInputBorder(),
                  prefixText: '\$',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a price';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _imageUrlController,
                decoration: InputDecoration(
                  labelText: 'Image URL (optional)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.url,
              ),
              SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _addProduct,
                  child: _isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text('Add Product'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }
}
