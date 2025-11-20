import 'package:flutter/material.dart';
import '/widgets/barraPrincipal.dart';
import '/widgets/texto_campo.dart';
import '/widgets/botonlogin.dart';
import '/widgets/boton_registro.dart';
import '/widgets/boton_continuar.dart';
import '/widgets/divisor.dart';

class VentanaMenu extends StatefulWidget {
  const VentanaMenu({super.key});

  @override
  State<VentanaMenu> createState() => _VentanaMenuState();
}

class _VentanaMenuState extends State<VentanaMenu> {
  final TextEditingController _usuarioController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: barraPrincipal(),
      backgroundColor: const Color(0xFFF5F5F5),
      body: Center(
        child: SingleChildScrollView(
          child: _interfazInicioSesion(),
        ),
      ),
    );
  }

  Widget _interfazInicioSesion() {
    return Container(
      width: 350,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 15,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.lock_outline, size: 70, color: Color(0xFFD48957)),
          const SizedBox(height: 10),
          const Text(
            "Iniciar Sesión",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFFD48957),
            ),
          ),
          const SizedBox(height: 30),

          TextoCampo(
            controller: _usuarioController,
            label: "Usuario",
            icon: Icons.person_outline,
          ),
          const SizedBox(height: 20),
          TextoCampo(
            controller: _passwordController,
            label: "Contraseña",
            icon: Icons.lock_outline,
            isPassword: true,
          ),
          const SizedBox(height: 30),

          BotonLogin(
            usuarioController: _usuarioController,
            passwordController: _passwordController,
          ),
          const SizedBox(height: 15),
          const BotonRegistro(),
          const SizedBox(height: 20),
          const Divisor(),
          const SizedBox(height: 20),
          const BotonContinuar(),
        ],
      ),
    );
  }
}
