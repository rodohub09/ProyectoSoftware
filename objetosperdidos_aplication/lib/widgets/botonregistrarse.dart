import 'package:flutter/material.dart';
import 'package:objetosperdidos_aplication/screens/VentanaMenu.dart';
import 'package:objetosperdidos_aplication/services/auth_service.dart';

class BotonRegistrarse extends StatelessWidget {
  final TextEditingController userIdController;
  final TextEditingController userNameController;
  final TextEditingController userEmailController;
  final TextEditingController userPasswordController;
  final TextEditingController userRutController;
  
  const BotonRegistrarse({
    super.key,
    required this.userIdController,
    required this.userNameController,
    required this.userEmailController,
    required this.userPasswordController,
    required this.userRutController,
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
          final userId = userIdController.text.trim();
          final userName = userNameController.text.trim();
          final userEmail = userEmailController.text.trim();
          final userPassword = userPasswordController.text.trim();
          final userRut = userRutController.text.trim();

          // Validar que los campos no estén vacíos
          if (userId.isEmpty || userName.isEmpty || userEmail.isEmpty|| userPassword.isEmpty||userRut.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Por favor completa todos los campos'),
                backgroundColor: Colors.red,
              ),
            );
            return;
          }

          // REGISTRAR USUARIO (esto guarda en SharedPreferences)
          bool registroExitoso = await authService.registrarUsuario(
            userId: userId,
            userName: userName,
            userEmail: userEmail,
            password: userPassword,
            rut: userRut,
          );

          if (registroExitoso) {
            // Navegar al menú
            if (context.mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const VentanaMenu()),
              );
            }
          } else {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('El Usuario o Matrícula ya están registrados'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
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

void main() {
  runApp(MaterialApp(
    home: Scaffold(
      body: Center(
        child: BotonRegistrarse(
          userIdController: TextEditingController(),
          userNameController: TextEditingController(),
          userEmailController: TextEditingController(),
          userPasswordController: TextEditingController(),
          userRutController: TextEditingController(),
        ),
      ),
    ),
  ));
}
