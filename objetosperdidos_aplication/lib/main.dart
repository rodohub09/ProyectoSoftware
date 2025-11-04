import 'package:flutter/material.dart';
import 'package:objetosperdidos_aplication/screens/VentanaMenu.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: VentanaMenu());
  }
}
