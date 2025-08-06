import 'package:flutter/material.dart';
import '../db/app_db_helper.dart';
import '../models/user_model.dart';
import 'login_screen.dart';

class CreateAdminScreen extends StatefulWidget {
  const CreateAdminScreen({super.key});

  @override
  State<CreateAdminScreen> createState() => _CreateAdminScreenState();
}

class _CreateAdminScreenState extends State<CreateAdminScreen> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final db = AppDatabaseHelper();

  void createAdmin() async {
    final username = usernameController.text.trim();
    final password = passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Tous les champs sont obligatoires")),
      );
      return;
    }

    final admin = UserModel(
      username: username,
      password: password,
      role: 'admin',
      lastLogin: '',
      lastLogout: '',
    );

    await db.insertUser(admin);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Compte admin créé avec succès")),
    );
    // ⏳ Petite pause pour que l'utilisateur voie le message
    await Future.delayed(const Duration(seconds: 1));
    // 🚀 Redirection vers la page de connexion
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Créer un compte Admin")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(labelText: "Nom d'utilisateur"),
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: "Mot de passe"),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green, // couleur du bouton
                foregroundColor: Colors.white, // couleur du texte
              ),
              onPressed: createAdmin,
              child: const Text("Créer l'admin"),
            )
          ],
        ),
      ),
    );
  }
}
