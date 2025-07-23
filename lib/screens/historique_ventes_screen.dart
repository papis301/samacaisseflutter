import 'package:flutter/material.dart';
import '../db/sales_db_helper.dart';

class HistoriqueVentesScreen extends StatefulWidget {
  const HistoriqueVentesScreen({super.key});

  @override
  State<HistoriqueVentesScreen> createState() => _HistoriqueVentesScreenState();
}

class _HistoriqueVentesScreenState extends State<HistoriqueVentesScreen> {
  final db = SalesDatabaseHelper();
  List<Map<String, dynamic>> ventes = [];

  @override
  void initState() {
    super.initState();
    chargerVentes();
  }

  Future<void> chargerVentes() async {
    final data = await db.getAllSales();
    setState(() => ventes = data);
  }

  void afficherDetails(int saleId) async {
    final items = await db.getSaleItems(saleId);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Détail de la vente"),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: items.length,
            itemBuilder: (_, index) {
              final item = items[index];
              return ListTile(
                title: Text(item['product_name']),
                subtitle: Text("Qté : ${item['quantity']} × ${item['unit_price']} FCFA"),
                trailing: Text("${(item['quantity'] * item['unit_price']).toStringAsFixed(2)} FCFA"),
              );
            },
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Fermer"))
        ],
      ),
    );
  }

  String formatDate(String iso) {
    final d = DateTime.parse(iso);
    return "${d.day}/${d.month}/${d.year} ${d.hour}:${d.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Historique des ventes")),
      body: ventes.isEmpty
          ? const Center(child: Text("Aucune vente enregistrée"))
          : ListView.builder(
        itemCount: ventes.length,
        itemBuilder: (_, index) {
          final v = ventes[index];
          return ListTile(
            title: Text("Employé : ${v['user']}"),
            subtitle: Text("Le ${formatDate(v['date'])}"),
            trailing: Text("${v['total'].toStringAsFixed(2)} FCFA"),
            onTap: () => afficherDetails(v['id']),
          );
        },
      ),
    );
  }
}
