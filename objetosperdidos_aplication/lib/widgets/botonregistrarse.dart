import 'package:flutter/material.dart';
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
  bool esEmailValido(String email) {
    String auxiliar = email;
    int cantidadArrobas = email.split('@').length - 1;
    if (cantidadArrobas > 1 ||
        cantidadArrobas == 0 ||
        auxiliar.startsWith('@udec.cl')) {
      return false;
    } 
    return true;
  }

  bool esRutValido(String rut){
    int? puntos;
    if(!rut.contains("-"))
      return false;
    if(rut.contains(".")){
      if(rut.length<11)
        return false;
      puntos = 0;
    }else{
      if(rut.length<9)
        return false;
    }
    List<String> digitosRut = rut.split("");
    int nums = 0;
    bool raya = false;
    for (int j = 0; j < digitosRut.length; j++) {
      int? i = int.tryParse(digitosRut[j]);
      if(i == null){
        if(digitosRut[j] == "." && puntos != null){
          if (puntos > 2){
            return false;
          }
          puntos++;
          continue;
        } else if((digitosRut[j] == "-") && (j == digitosRut.length-2)){
          raya = true;  
          continue;
        }else if(raya && ((digitosRut[j] == "k") || (digitosRut[j] == "K")))
          continue;
        return false;
      }
      if(!raya){
        nums *= 10;
        nums += i;
      }
    }
    if (nums>30000000 || nums < 1000000 || (puntos !=2 && rut.contains("."))){
      return false;
    }
    return true;
  }

  bool esContrasenaValida(String contrasena){
    if (contrasena.length < 8)
      return false;

    if(!contrasena.contains(RegExp(r'[0-9]')) || 
      !contrasena.contains(RegExp(r'[A-Z]')) || 
      !contrasena.contains(RegExp(r'[a-z]')) || 
      !contrasena.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))){
      return false;
    }
    return true;
  }

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
          if (userId.isEmpty ||
              userName.isEmpty ||
              userEmail.isEmpty ||
              userPassword.isEmpty ||
              userRut.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Por favor completa todos los campos'),
                backgroundColor: Colors.red,
              ),
            );
            return;
          } else if (!userEmail.endsWith('@udec.cl') ||
              !esEmailValido(userEmail)) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('El correo ingresado no es válido'),
                backgroundColor: Colors.red,
              ),
            );
            return;
          } else if (!userId.startsWith('20') || userId.length != 10) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('La matrícula ingresada no es válida'),
                backgroundColor: Colors.red,
              ),
            );
            return;
          }
          //Verificacion de rut.
          if(!esRutValido(userRut)){
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('El RUT ingresado no es valido.'),
                backgroundColor: Colors.red,
              ),
            );
            return;
          }

          if(!esContrasenaValida(userPassword)){
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('La contraseña ingresada no es valida.'),
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
            Navigator.pop(context); // Cerrar la pantalla de registro
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
  runApp(
    MaterialApp(
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
    ),
  );
}
