import 'package:flutter/material.dart';
import 'package:samacaisse/screens/product_list_screen.dart';
import 'clients_screen.dart';
import 'historique_ventes_screen.dart';
import 'user_list_screen.dart';
//import 'product_list_screen.dart';
import 'login_screen.dart';
import '../models/user_model.dart';
import '../db/user_db_helper.dart';

class AdminDashboardScreen extends StatelessWidget {
  final UserModel user; // ✅ utilisateur connecté

  const AdminDashboardScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final db = UserDBHelper();

    void logout() async {
      final logoutTime = DateTime.now().toIso8601String();

      final updatedUser = UserModel(
        id: user.id,
        username: user.username,
        password: user.password,
        role: user.role,
        lastLogin: user.lastLogin,
        lastLogout: logoutTime,
      );

      await db.updateUser(updatedUser);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Tableau de bord - Admin"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Déconnexion',
            onPressed: logout,
          )
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.people),
                label: const Text("Gestion des utilisateurs"),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const UserListScreen()),
                  );
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.inventory),
                label: const Text("Gestion des produits"),
                onPressed: () {
                  final loginTime = DateTime.now().toIso8601String();
                  final updatedUser = UserModel(
                    id: user.id,
                    username: user.username,
                    password: user.password,
                    role: user.role,
                    lastLogin: loginTime,
                    lastLogout: user.lastLogout,
                  );
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ProductListScreen(user: updatedUser, user1: user,)),
                  );
                },
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.history),
                label: const Text("Historique des ventes"),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const HistoriqueVentesScreen()),
                  );
                },
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ClientListScreen()),
                  );
                },
                child: const Text("Gérer les clients"),
              ),

            ],
          ),
        ),
      ),
    );
  }
}
