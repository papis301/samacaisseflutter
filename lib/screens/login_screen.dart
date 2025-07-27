import 'package:flutter/material.dart';
import 'package:samacaisse/screens/product_list_screen.dart';
import '../db/app_db_helper.dart';
import '../models/user_model.dart';
import 'admin_dashboard_screen.dart';
import 'cashier_screen.dart';
import 'user_list_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final db = AppDatabaseHelper();
  bool showError = false;

  void login() async {
    final username = usernameController.text.trim();
    final password = passwordController.text.trim();

    final users = await db.getAllUsers();
    final user = users.firstWhere(
          (u) => u.username == username && u.password == password,
      orElse: () => UserModel(id: -1, username: '', password: '', role: ''),
    );

    if (user.id != -1) {
      if (user.role == 'admin') {
        final loginTime = DateTime.now().toIso8601String();
        final updatedUser = UserModel(
          id: user.id,
          username: user.username,
          password: user.password,
          role: user.role,
          lastLogin: loginTime,
          lastLogout: user.lastLogout,
        );
        await db.updateUser(updatedUser);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => AdminDashboardScreen(user: updatedUser,)),
        );
      } else {
        // TODO: Écran employé à afficher ici
        final loginTime = DateTime.now().toIso8601String();
        final updatedUser = UserModel(
          id: user.id,
          username: user.username,
          password: user.password,
          role: user.role,
          lastLogin: loginTime,
          lastLogout: user.lastLogout,
        );
        await db.updateUser(updatedUser);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) =>  CashierScreen(user: user,))
          //MaterialPageRoute(builder: (_) => ProductListScreen(user: updatedUser, user1: user,)),
        );
      }
    } else {
      setState(() => showError = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Connexion")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
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
              onPressed: login,
              child: const Text("Se connecter"),
            ),
            if (showError)
              const Padding(
                padding: EdgeInsets.only(top: 12),
                child: Text("Identifiants invalides", style: TextStyle(color: Colors.red)),
              ),
          ],
        ),
      ),
    );
  }
}
