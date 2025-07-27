import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../models/user_model.dart';
import 'package:share_plus/share_plus.dart';


class VenteRecapScreen extends StatelessWidget {
  final UserModel user;
  final List<Map<String, dynamic>> venteItems; // contient product + qty
  final double total;
  final DateTime date;
  final String? clientName;

  const VenteRecapScreen({
    super.key,
    required this.user,
    required this.venteItems,
    required this.total,
    required this.date,
    this.clientName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Fiche de vente")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Employé : ${user.username}", style: const TextStyle(fontSize: 18)),
            Text("Date : ${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}"),
            const SizedBox(height: 20),
            if (clientName != null && clientName!.isNotEmpty)
              Text("Client : $clientName", style: const TextStyle(fontSize: 16)),

            const SizedBox(height: 20),
            const Text("Produits vendus :", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: venteItems.length,
                itemBuilder: (_, index) {
                  final item = venteItems[index];
                  final product = item['product'] as ProductModel;
                  final qty = item['qty'] as int;

                  return ListTile(
                    title: Text(product.name),
                    subtitle: Text("Quantité : $qty • Prix unitaire : ${product.price} FCFA"),
                    trailing: Text("${(product.price * qty).toStringAsFixed(2)} FCFA"),
                  );
                },
              ),
            ),
            const Divider(),
            Text("TOTAL : ${total.toStringAsFixed(2)} FCFA", style: const TextStyle(fontSize: 20)),

            const SizedBox(height: 20),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.done),
                    label: const Text("Retour"),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 16), // espacement entre les boutons
                  ElevatedButton.icon(
                    icon: const Icon(Icons.share),
                    label: const Text("Partager"),
                    onPressed: () => partagerVente(context),
                  ),
                ],
              ),
            )

          ],
        ),
      ),
    );
  }


  void partagerVente(BuildContext context) {
    final StringBuffer buffer = StringBuffer();
    buffer.writeln("🧾 Fiche de vente");
    buffer.writeln("Employé : ${user.username}");
    buffer.writeln("Date : ${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}");
    if (clientName!.isNotEmpty) {
      buffer.writeln("Client : $clientName");
    }
    buffer.writeln("\n📦 Produits :");

    for (var item in venteItems) {
      final product = item['product'] as ProductModel;
      final qty = item['qty'] as int;
      buffer.writeln("- ${product.name} x$qty : ${(product.price * qty).toStringAsFixed(2)} FCFA");
    }

    buffer.writeln("\n💰 TOTAL : ${total.toStringAsFixed(2)} FCFA");

    Share.share(buffer.toString());
  }

}
