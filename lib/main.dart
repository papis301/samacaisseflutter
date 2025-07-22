import 'package:flutter/material.dart';
import 'package:samacaisse/screens/login_screen.dart';

import 'db/user_db_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final db = UserDBHelper();     // Crée une instance
  await db.seedAdminUser();      // Appelle le seed admin

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Gestion Utilisateurs',
        theme: ThemeData(primarySwatch: Colors.blue),
        //home: const UserListScreen(),
        home: LoginScreen()
    );
  }
}
