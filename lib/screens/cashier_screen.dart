import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../db/product_db_helper.dart';
import '../models/user_model.dart';

class CashierScreen extends StatefulWidget {
  final UserModel user;

  const CashierScreen({super.key, required this.user});

  @override
  State<CashierScreen> createState() => _CashierScreenState();
}

class _CashierScreenState extends State<CashierScreen> {
  final db = ProductDatabaseHelper();
  List<ProductModel> products = [];
  Map<int, int> panier = {}; // productId -> quantity

  @override
  void initState() {
    super.initState();
    loadProducts();
  }

  Future<void> loadProducts() async {
    final data = await db.getAllProducts();
    setState(() => products = data);
  }

  double get total => panier.entries.fold(0.0, (sum, entry) {
    final product = products.firstWhere((p) => p.id == entry.key);
    return sum + (product.price * entry.value);
  });

  void validerVente() async {
    bool success = true;

    for (var entry in panier.entries) {
      final productId = entry.key;
      final quantityVendue = entry.value;

      // Trouver le produit original
      final product = products.firstWhere((p) => p.id == productId);

      // Vérifier le stock
      if (product.quantity < quantityVendue) {
        success = false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Stock insuffisant pour ${product.name}")),
        );
        break;
      }

      // Réduire le stock
      final updatedProduct = ProductModel(
        id: product.id,
        name: product.name,
        quantity: product.quantity - quantityVendue,
        price: product.price,
        date: product.date,
      );

      await db.updateProduct(updatedProduct);
    }

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vente enregistrée avec succès")),
      );
      setState(() {
        panier.clear();
      });
      loadProducts(); // mettre à jour les stocks affichés
    }
  }


  void addToCart(ProductModel product) async {
    final controller = TextEditingController(text: "1");

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Ajouter ${product.name}"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: "Quantité"),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annuler")),
          ElevatedButton(
            onPressed: () {
              final qty = int.tryParse(controller.text) ?? 1;
              setState(() {
                panier.update(product.id!, (old) => old + qty, ifAbsent: () => qty);
              });
              Navigator.pop(context);
            },
            child: const Text("Ajouter"),
          ),
        ],
      ),
    );
  }

  void clearCart() {
    setState(() => panier.clear());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Caisse"),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear_all),
            tooltip: "Vider le panier",
            onPressed: panier.isNotEmpty ? clearCart : null,
          )
        ],
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(8),
            child: Text("Produits disponibles", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: products.length,
              itemBuilder: (_, index) {
                final p = products[index];
                return ListTile(
                  title: Text(p.name),
                  subtitle: Text("Prix: ${p.price.toStringAsFixed(2)} FCFA • Stock: ${p.quantity}"),
                  trailing: ElevatedButton(
                    child: const Text("Ajouter"),
                    onPressed: () => addToCart(p),
                  ),
                );
              },
            ),
          ),
          const Divider(),
    Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
    Text("Total : ${total.toStringAsFixed(2)} FCFA", style: const TextStyle(fontSize: 20)),
    ElevatedButton.icon(
    icon: const Icon(Icons.check),
    label: const Text("Valider"),
    onPressed: panier.isNotEmpty ? validerVente : null,
    ),
    ],
    ),
    ),

        ],
      ),
    );
  }
}
