import 'package:flutter/material.dart';
import 'package:samacaisse/screens/vente_recap_screen.dart';
import '../db/sales_db_helper.dart';
import '../db/user_db_helper.dart';
import '../models/client_model.dart';
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
  String? selectedClientId;
  List<ProductModel> products = [];
  Map<int, int> panier = {}; // productId -> quantity
  ClientModel? selectedClient;
  List<ClientModel> clients = [];

  Future<void> loadClients() async {
    final db = UserDBHelper();
    final result = await db.getAllClients();
    setState(() {
      clients = result;
    });
  }

  @override
  void initState() {
    super.initState();
    loadProducts();
    loadClients();
  }

  Widget _buildSearchField() {
    return Padding(
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
    );
  }

  Widget _buildProductList() {
    final filteredProducts = products
        .where((p) => p.name.toLowerCase().contains(searchText))
        .toList();

    return Expanded(
      child: ListView.builder(
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
      ),
    );
  }

  Widget _buildCartSummary() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Total : ${total.toStringAsFixed(2)} FCFA", style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.check),
              label: const Text("Valider"),
              onPressed: panier.isNotEmpty ? validerVente : null,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Flexible(
                child: DropdownButtonFormField<ClientModel?>(
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: "Choisir un client",
                    border: OutlineInputBorder(),
                  ),
                  value: selectedClient,
                  items: [
                    const DropdownMenuItem<ClientModel?>(
                      value: null,
                      child: Text("Aucun client"),
                    ),
                    ...clients.map((client) {
                      return DropdownMenuItem<ClientModel?>(
                        value: client,
                        child: Text("${client.name} (${client.phone})"),
                      );
                    }).toList(),
                  ],
                  onChanged: (ClientModel? newValue) {
                    setState(() {
                      selectedClient = newValue;
                    });
                  },
                ),
              ),

            ),
            if (selectedClient == null)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text("Aucun client sélectionné", style: TextStyle(color: Colors.grey)),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text("Client sélectionné : \${selectedClient!.name}", style: const TextStyle(fontWeight: FontWeight.w500)),
              ),
            const SizedBox(height: 20),
            const Text("Produits ajoutés :", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Expanded(
              child: ListView(
                children: panier.entries.map((entry) {
                  final product = products.firstWhere((p) => p.id == entry.key);
                  final qty = entry.value;
                  final controller = TextEditingController(text: qty.toString());

                  return ListTile(
                    title: Text(product.name),
                    subtitle: Text("Prix unitaire : ${product.price.toStringAsFixed(2)} FCFA"),
                    trailing: SizedBox(
                      width: 150,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Expanded(
                            child: TextField(
                              controller: controller,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                hintText: "Qté",
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              ),
                              onSubmitted: (val) {
                                final newQty = int.tryParse(val) ?? qty;
                                setState(() {
                                  if (newQty <= 0) {
                                    panier.remove(product.id);
                                  } else {
                                    panier[product.id!] = newQty;
                                  }
                                });
                              },
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              setState(() => panier.remove(product.id));
                            },
                          )
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
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
    final double totalVente = total;

    for (var entry in panier.entries) {
      final productId = entry.key;
      final quantityVendue = entry.value;

      final product = products.firstWhere((p) => p.id == productId);

      if (product.quantity < quantityVendue) {
        success = false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Stock insuffisant pour \${product.name}")),
        );
        break;
      }

      venteItems.add({'product': product, 'qty': quantityVendue});

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
        clientName: selectedClient?.name,
        total: total,
        date: now.toIso8601String(),
        items: venteItems,
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VenteRecapScreen(
            user: widget.user,
            venteItems: venteItems,
            total: totalVente,
            date: now,
            clientName: selectedClient?.name ?? '',
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
        title: Text("Ajouter \${product.name}"),
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

    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    bool isTablet = MediaQuery.of(context).size.width > 600;
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
      body: isTablet
          ? Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              children: [
                _buildSearchField(),
                _buildProductList(),
              ],
            ),
          ),
          const VerticalDivider(width: 1),
          Expanded(
            flex: 1,
            child: _buildCartSummary(),
          ),
        ],
      )
          : Column(
        children: [
          _buildSearchField(),
          Expanded(child: _buildProductList()),
          const Divider(),
          _buildCartSummary(),
        ],
      ),
    );
  }
}
