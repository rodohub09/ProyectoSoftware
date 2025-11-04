import 'package:flutter/material.dart';
import 'package:objetosperdidos_aplication/screens/VentanaMenu.dart';

class BotonRegistrarse extends StatelessWidget {
  const BotonRegistrarse({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFD48957),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 3,
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const VentanaMenu()), //A ver si cambia con Navigator.pop
          );
        },
        child: const Text(
          "Regístrate",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
