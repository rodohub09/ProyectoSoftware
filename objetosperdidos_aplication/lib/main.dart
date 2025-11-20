import 'package:flutter/material.dart';
import 'package:objetosperdidos_aplication/services/verificar_sesion.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: VerificarSesion(),
    );
  }
}
