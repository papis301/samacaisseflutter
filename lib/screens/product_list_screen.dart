import 'package:flutter/material.dart';
import 'package:samacaisse/models/user_model.dart';
import '../db/product_db_helper.dart';
import '../models/product_model.dart';
import 'product_form_screen.dart';

class ProductListScreen extends StatefulWidget {
  final UserModel user1;
  const ProductListScreen({super.key, required UserModel user, required this.user1});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  List<ProductModel> products = [];
  final db = ProductDatabaseHelper();

  @override
  void initState() {
    super.initState();
    loadProducts();
  }

  Future<void> loadProducts() async {
    final data = await db.getAllProducts();
    setState(() => products = data);
  }

  void deleteProduct(int id) async {
    await db.deleteProduct(id);
    loadProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Produits")),
      body: ListView.builder(
        itemCount: products.length,
        itemBuilder: (_, index) {
          final p = products[index];
          return ListTile(
            title: Text(p.name),
            subtitle: Text("Qté: ${p.quantity}, Prix: ${p.price.toStringAsFixed(2)} FCFA\nAjouté: ${p.date.split("T")[0]}"),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ProductFormScreen(product: p)),
                    );
                    loadProducts();
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => deleteProduct(p.id!),
                ),
              ],
            ),
          );
        },
      ),
        floatingActionButton: widget.user1.role == 'admin'
            ? FloatingActionButton(
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProductFormScreen()),
            );
            loadProducts();
          },
          child: const Icon(Icons.add),
        )
            : null,
    );
  }
}
