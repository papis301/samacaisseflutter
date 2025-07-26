import 'package:flutter/material.dart';
import '../db/user_db_helper.dart';
import 'create_admin_screen.dart';
import 'login_screen.dart';

class InitialScreen extends StatefulWidget {
  const InitialScreen({super.key});

  @override
  State<InitialScreen> createState() => _InitialScreenState();
}

class _InitialScreenState extends State<InitialScreen> {
  final userDb = UserDBHelper();

  @override
  void initState() {
    super.initState();
    checkIfAdminExists();
  }

  Future<void> checkIfAdminExists() async {
    final users = await userDb.getAllUsers();
    final adminExists = users.any((u) => u.role == 'admin');

    if (adminExists) {
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const CreateAdminScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
