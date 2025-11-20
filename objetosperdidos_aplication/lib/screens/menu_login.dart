import 'package:flutter/material.dart';
import 'package:objetosperdidos_aplication/Visuals/MenuReportes.dart';
import 'package:objetosperdidos_aplication/services/auth_service.dart';
import 'package:objetosperdidos_aplication/screens/PantallaRegistro.dart';
import 'package:objetosperdidos_aplication/widgets/texto_campo.dart';
import 'package:objetosperdidos_aplication/widgets/divisor.dart';

class MenuLogin extends StatefulWidget {
  const MenuLogin({super.key});

  @override
  State<MenuLogin> createState() => _MenuLoginState();
}

class _MenuLoginState extends State<MenuLogin> {
  final TextEditingController _usuarioController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  Future<void> _iniciarSesion() async {
    final usuario = _usuarioController.text.trim();
    final password = _passwordController.text.trim();

    if (usuario.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor completa todos los campos')),
      );
      return;
    }

    print('🔐 Intentando login...');
    final resultado = await _authService.iniciarSesion(
      usuario: usuario,
      password: password,
    );

    if (resultado['success'] == true) {
      print('✅ Login exitoso, navegando...');
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MenuReportes()),
        );
      }
    } else {
      print('❌ Login fallido: ${resultado['message']}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(resultado['message'] ?? 'Error al iniciar sesión')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 300,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 255, 238, 0),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    "Iniciar Sesión",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFD48957),
                    ),
                  ),
                  const SizedBox(height: 20),

                  TextoCampo(
                    controller: _usuarioController,
                    label: "Usuario",
                    icon: Icons.person_outline,
                  ),
                  const SizedBox(height: 15),

                  TextoCampo(
                    controller: _passwordController,
                    label: "Contraseña",
                    icon: Icons.lock_outline,
                    isPassword: true,
                  ),
                  const SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: _iniciarSesion,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD48957),
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    ),
                    child: const Text(
                      "Iniciar Sesión",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 15),

                  TextButton(
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
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  const Divisor(),
                  const SizedBox(height: 10),

                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const MenuReportes()),
                      );
                    },
                    child: const Text(
                      "Continuar sin iniciar sesión",
                      style: TextStyle(color: Color(0xFF6DBEB4)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
    );
  }
}

PreferredSizeWidget customAppBar() {
  return AppBar(
    title: const Text(
      "Menú Login",
      style: TextStyle(color: Color.fromRGBO(255, 255, 255, 0.824)),
    ),
    backgroundColor: const Color.fromARGB(255, 212, 137, 87),
  );
}
