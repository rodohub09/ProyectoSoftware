import 'package:flutter/material.dart';
import 'package:objetosperdidos_aplication/widgets/botonregistrarse.dart';
import '/widgets/barraPrincipal.dart';
import '/widgets/texto_campo.dart';
import '/widgets/boton_continuar.dart';
import '/widgets/divisor.dart';

class VentanaRegistro extends StatefulWidget {
  const VentanaRegistro({super.key});

  @override
  State<VentanaRegistro> createState() => _VentanaRegistroState();
}

class _VentanaRegistroState extends State<VentanaRegistro> {
  final TextEditingController _usuarioController = TextEditingController();
  final TextEditingController _matriculaController = TextEditingController();
  final TextEditingController _rutController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: barraPrincipal(),
      backgroundColor: const Color(0xFFF5F5F5),
      body: Center(
        child: SingleChildScrollView(
          child: _interfazRegistro(),
        ),
      ),
    );
  }

  Widget _interfazRegistro() {
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
          const Icon(Icons.person_add_alt_1_outlined, size: 70, color: Color(0xFFD48957)),
          const SizedBox(height: 10),
          const Text(
            "Registro de Usuario",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFFD48957),
            ),
          ),
          const SizedBox(height: 30),

          // 🔹 Campos de texto
          TextoCampo(
            controller: _usuarioController,
            label: "Usuario",
            icon: Icons.person_outline,
          ),
          const SizedBox(height: 20),

          TextoCampo(
            controller: _correoController,
            label: "Correo Electrónico",
            icon: Icons.email_outlined,
          ),
          const SizedBox(height: 20),

          TextoCampo(
            controller: _matriculaController,
            label: "Matrícula",
            icon: Icons.badge_outlined,
          ),
          const SizedBox(height: 20),

          TextoCampo(
            controller: _rutController,
            label: "RUT",
            icon: Icons.credit_card_outlined,
          ),
          const SizedBox(height: 20),

          TextoCampo(
            controller: _passwordController,
            label: "Contraseña",
            icon: Icons.lock_outline,
            isPassword: true,
          ),
          const SizedBox(height: 30),

          BotonRegistrarse(
            userIdController: _matriculaController,
            userNameController: _usuarioController,
            userEmailController: _correoController,
            userPasswordController: _passwordController,
            userRutController: _rutController,
          ),
          const SizedBox(height: 15),

          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text(
              "¿Ya tienes cuenta? Inicia sesión",
              style: TextStyle(
                color: Color(0xFF6DBEB4),
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ),
          const SizedBox(height: 20),

          const Divisor(),
          const SizedBox(height: 20),

          const BotonContinuar(),
        ],
      ),
    );
  }
}
