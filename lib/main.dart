import 'package:flutter/material.dart';
import 'package:samacaisse/screens/initial_screen.dart';
import 'package:samacaisse/screens/login_screen.dart';



void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter POS',
      debugShowCheckedModeBanner: false,
      routes: {
        '/login': (_) => const LoginScreen(),
        // autres routes...
      },
      home: const InitialScreen(), // 👈 point d'entrée conditionnel
    );
  }
}
