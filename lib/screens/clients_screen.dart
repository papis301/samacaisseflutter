import 'package:flutter/material.dart';
import '../models/client_model.dart';
import '../db/user_db_helper.dart';

class ClientListScreen extends StatefulWidget {
  const ClientListScreen({super.key});

  @override
  State<ClientListScreen> createState() => _ClientListScreenState();
}

class _ClientListScreenState extends State<ClientListScreen> {
  final db = UserDBHelper();
  List<ClientModel> clients = [];

  @override
  void initState() {
    super.initState();
    loadClients();
  }

  Future<void> loadClients() async {
    final data = await db.getAllClients();
    setState(() => clients = data);
  }

  void showClientDialog({ClientModel? client}) {
    final nameController = TextEditingController(text: client?.name ?? '');
    final phoneController = TextEditingController(text: client?.phone ?? '');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(client == null ? "Ajouter un client" : "Modifier le client"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Nom"),
            ),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: "Téléphone"),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text("Annuler"),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: const Text("Enregistrer"),
            onPressed: () async {
              final name = nameController.text.trim();
              final phone = phoneController.text.trim();
              if (name.isEmpty || phone.isEmpty) return;

              if (client == null) {
                await db.insertClient(ClientModel(name: name, phone: phone));
              } else {
                await db.updateClient(ClientModel(id: client.id, name: name, phone: phone));
              }

              Navigator.pop(context);
              loadClients();
            },
          )
        ],
      ),
    );
  }

  void deleteClient(ClientModel client) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Supprimer ce client ?"),
        content: Text("Voulez-vous vraiment supprimer ${client.name} ?"),
        actions: [
          TextButton(child: const Text("Annuler"), onPressed: () => Navigator.pop(context, false)),
          ElevatedButton(child: const Text("Supprimer"), onPressed: () => Navigator.pop(context, true)),
        ],
      ),
    );

    if (confirm == true) {
      await db.deleteClient(client.id!);
      loadClients();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gestion des clients"),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () => showClientDialog(),
            tooltip: "Ajouter un client",
          )
        ],
      ),
      body: clients.isEmpty
          ? const Center(child: Text("Aucun client enregistré."))
          : ListView.builder(
        itemCount: clients.length,
        itemBuilder: (_, index) {
          final c = clients[index];
          return ListTile(
            leading: const Icon(Icons.person),
            title: Text(c.name),
            subtitle: Text("Téléphone : ${c.phone}"),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(icon: const Icon(Icons.edit), onPressed: () => showClientDialog(client: c)),
                IconButton(icon: const Icon(Icons.delete), onPressed: () => deleteClient(c)),
              ],
            ),
          );
        },
      ),
    );
  }
}
