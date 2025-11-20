import 'package:flutter/material.dart';
import 'package:objetosperdidos_aplication/screens/VentanaMenu.dart';
import 'package:objetosperdidos_aplication/screens/menu_inicial.dart';
import 'package:objetosperdidos_aplication/services/auth_service.dart';

class BotonLogin extends StatelessWidget {
  final TextEditingController usuarioController;
  final TextEditingController passwordController;

  const BotonLogin({
    super.key,
    required this.usuarioController,
    required this.passwordController,
  });

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

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
        onPressed: () async {
          final usuario = usuarioController.text.trim();
          final password = passwordController.text.trim();

          if (usuario.isEmpty || password.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Por favor completa todos los campos'),
                backgroundColor: Colors.red,
              ),
            );
            return;
          }

          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFD48957),
              ),
            ),
          );

          final resultado = await authService.iniciarSesion(
            usuario: usuario,
            password: password,
          );

          if (context.mounted) {
            Navigator.pop(context);
          }

          if (resultado['success']) {
            if (context.mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const MenuInicial()),
              );
            }
          } else {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(resultado['message']),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
        child: const Text(
          "Iniciar Sesión",
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
