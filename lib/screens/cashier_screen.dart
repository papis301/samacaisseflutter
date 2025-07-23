import 'package:flutter/material.dart';
import 'package:samacaisse/screens/vente_recap_screen.dart';
import '../db/sales_db_helper.dart';
import '../db/user_db_helper.dart';
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
  String searchText = '';
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
    List<Map<String, dynamic>> venteItems = [];

    for (var entry in panier.entries) {
      final productId = entry.key;
      final quantityVendue = entry.value;

      final product = products.firstWhere((p) => p.id == productId);

      if (product.quantity < quantityVendue) {
        success = false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Stock insuffisant pour ${product.name}")),
        );
        break;
      }

      // Stocker les items vendus pour la fiche
      venteItems.add({'product': product, 'qty': quantityVendue});

      // Mise à jour du stock
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
      final now = DateTime.now();

      final saleDB = SalesDatabaseHelper();
      await saleDB.insertSale(
        user: widget.user.username,
        total: total,
        date: now.toIso8601String(),
        items: venteItems,
      );
      // Aller vers l’écran de fiche de vente
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VenteRecapScreen(
            user: widget.user,
            venteItems: venteItems,
            total: total,
            date: now,
          ),
        ),
      );

      setState(() {
        panier.clear();
      });
      loadProducts();
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

  void logout() async {
    final now = DateTime.now().toIso8601String();

    final updatedUser = UserModel(
      id: widget.user.id,
      username: widget.user.username,
      password: widget.user.password,
      role: widget.user.role,
      lastLogin: widget.user.lastLogin,
      lastLogout: now,
    );

    final userDb = UserDBHelper();
    await userDb.updateUser(updatedUser);

    Navigator.pushReplacementNamed(context, '/login'); // ou LoginScreen()
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
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: "Déconnexion",
            onPressed: logout,
          )
        ],
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(8),
            child: Text("Produits disponibles", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: "Rechercher un produit",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() => searchText = value.toLowerCase());
              },
            ),
          ),

          Expanded(
            child: Builder(
              builder: (context) {
                final filteredProducts = products.where((p) =>
                    p.name.toLowerCase().contains(searchText)).toList();

                return ListView.builder(
                  itemCount: filteredProducts.length,
                  itemBuilder: (_, index) {
                    final p = filteredProducts[index];
                    return ListTile(
                      title: Text(p.name),
                      subtitle: Text("Prix: ${p.price.toStringAsFixed(2)} FCFA • Stock: ${p.quantity}"),
                      trailing: ElevatedButton(
                        child: const Text("Ajouter"),
                        onPressed: () => addToCart(p),
                      ),
                    );
                  },
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
