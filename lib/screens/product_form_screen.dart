import 'package:flutter/material.dart';
import '../db/app_db_helper.dart';
import '../models/product_model.dart';

class ProductFormScreen extends StatefulWidget {
  final ProductModel? product;

  const ProductFormScreen({super.key, this.product});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final nameController = TextEditingController();
  final quantityController = TextEditingController();
  final priceController = TextEditingController();
  final db = AppDatabaseHelper();

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      nameController.text = widget.product!.name;
      quantityController.text = widget.product!.quantity.toString();
      priceController.text = widget.product!.price.toString();
    }
  }

  void saveProduct() async {
    final name = nameController.text.trim();
    final quantity = int.tryParse(quantityController.text) ?? 0;
    final price = double.tryParse(priceController.text) ?? 0.0;
    final date = DateTime.now().toIso8601String();

    final product = ProductModel(
      id: widget.product?.id,
      name: name,
      quantity: quantity,
      price: price,
      date: widget.product?.date ?? date,
    );

    if (widget.product == null) {
      await db.insertProduct(product);
    } else {
      await db.updateProduct(product);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.product == null ? "Ajouter un produit" : "Modifier le produit")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Nom"),
            ),
            TextField(
              controller: quantityController,
              decoration: const InputDecoration(labelText: "Quantité"),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: priceController,
              decoration: const InputDecoration(labelText: "Prix"),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: saveProduct,
              child: const Text("Enregistrer"),
            )
          ],
        ),
      ),
    );
  }
}
