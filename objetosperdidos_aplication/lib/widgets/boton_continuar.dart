import 'package:flutter/material.dart';
import 'package:objetosperdidos_aplication/Visuals/MenuReportes.dart';


class BotonContinuar extends StatelessWidget {
  const BotonContinuar({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 45,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFFD48957), width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MenuReportes()),
          );
        },
        child: const Text(
          "Continuar sin iniciar sesión",
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFFD48957),
          ),
        ),
      ),
    );
  }
}
