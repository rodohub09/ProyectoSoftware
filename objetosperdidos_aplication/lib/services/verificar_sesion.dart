import 'package:flutter/material.dart';
import 'package:objetosperdidos_aplication/Visuals/MenuReportes.dart';
import 'package:objetosperdidos_aplication/screens/VentanaMenu.dart';
import 'package:objetosperdidos_aplication/services/auth_service.dart';

class VerificarSesion extends StatelessWidget {
  const VerificarSesion({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: () async {
        // Ensure an admin exists on startup (creates default admin if none)
        await AuthService().ensureAdminExists();
        return AuthService().isLoggedIn();
      }(),
      builder: (context, snapshot) {
        // Tiene que esperar mientras verifica (si no va a petar)
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFFD48957)),
            ),
          );
        }
        if (snapshot.data == true) {
          return const MenuReportes();
        }
        return const VentanaMenu();
      },
    );
  }
}
