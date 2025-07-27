import 'package:flutter/material.dart';
import '../db/app_db_helper.dart';
import '../models/user_model.dart';

class UserFormScreen extends StatefulWidget {
  final UserModel? user;
  const UserFormScreen({super.key, this.user});

  @override
  State<UserFormScreen> createState() => _UserFormScreenState();
}

class _UserFormScreenState extends State<UserFormScreen> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  String role = "employe";
  final db = AppDatabaseHelper();

  @override
  void initState() {
    super.initState();
    if (widget.user != null) {
      usernameController.text = widget.user!.username;
      passwordController.text = widget.user!.password;
      role = widget.user!.role;
    }
  }

  void saveUser() async {
    final username = usernameController.text.trim();
    final password = passwordController.text.trim();
    if (username.isEmpty || password.isEmpty) return;

    final newUser = UserModel(
      id: widget.user?.id,
      username: username,
      password: password,
      role: role,
    );

    if (widget.user == null) {
      await db.insertUser(newUser);
    } else {
      await db.updateUser(newUser);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.user == null ? "Ajouter" : "Modifier")),
      body: Padding(
        padding: const EdgeInsets.all(16),
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
            DropdownButton<String>(
              value: role,
              onChanged: (value) => setState(() => role = value!),
              items: [ "employe"].map((r) {
                return DropdownMenuItem(value: r, child: Text(r));
              }).toList(),
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: saveUser, child: const Text("Enregistrer")),
          ],
        ),
      ),
    );
  }
}
