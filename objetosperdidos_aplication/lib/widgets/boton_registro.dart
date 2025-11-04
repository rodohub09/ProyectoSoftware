import 'package:flutter/material.dart';
import 'package:objetosperdidos_aplication/screens/PantallaRegistro.dart';

class BotonRegistro extends StatelessWidget {
  const BotonRegistro({super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const VentanaRegistro()),
        );
      },
      child: const Text(
        "¿No tienes cuenta? Regístrate",
        style: TextStyle(
          color: Color(0xFF6DBEB4),
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
    );
  }
}
