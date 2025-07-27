import 'package:flutter/material.dart';
import '../db/app_db_helper.dart';
import '../models/user_model.dart';
import 'user_form_screen.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});
  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  List<UserModel> users = [];
  final userDb = AppDatabaseHelper();

  void loadUsers() async {
    final data = await userDb.getAllUsers();
    //affichage de tous les users y compris l'admin
    //setState(() => users = data);
    //affichage de tous les users sauf l'admin
    setState(() {
      users = data.where((u) => u.username != 'admin').toList();
    });
  }

  void deleteUser(int id) async {
    await userDb.deleteUser(id);
    loadUsers();
  }

  @override
  void initState() {
    super.initState();
    loadUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Utilisateurs")),
      body: ListView.builder(
        itemCount: users.length,
        itemBuilder: (_, index) {
          final user = users[index];
          return ListTile(
            title: Text(user.username),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Rôle : ${user.role}"),
                if (user.lastLogin != null)
                  Text("Dernière connexion : ${_formatDate(user.lastLogin!)}"),
                if (user.lastLogout != null)
                  Text("Dernière déconnexion : ${_formatDate(user.lastLogout!)}"),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => UserFormScreen(user: user)),
                    );
                    loadUsers();
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => deleteUser(user.id!),
                ),
              ],
            ),
          );

        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const UserFormScreen()),
          );
          loadUsers();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

String _formatDate(String isoDate) {
  final date = DateTime.tryParse(isoDate);
  if (date == null) return '---';
  return "${date.day.toString().padLeft(2, '0')}/"
      "${date.month.toString().padLeft(2, '0')}/"
      "${date.year} à ${date.hour}:${date.minute.toString().padLeft(2, '0')}";
}

