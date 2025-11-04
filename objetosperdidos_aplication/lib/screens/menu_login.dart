import 'package:flutter/material.dart';

class MenuLogin extends StatefulWidget {
  const MenuLogin({super.key});

  @override
  State<MenuLogin> createState() => _MenuLoginState();
}

class _MenuLoginState extends State<MenuLogin> {
  final TextEditingController _usuarioController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

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
              height: 330,
              decoration: BoxDecoration(
                color: const Color.fromARGB(
                  255,
                  255,
                  238,
                  0,
                ), // El color se establece dentro de la decoración
                // También puedes añadir otras propiedades aquí, como bordes o gradientes
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 250,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(
                        255,
                        109,
                        190,
                        180,
                      ), // El color se establece dentro de la decoración
                      // También puedes añadir otras propiedades aquí, como bordes o gradientes
                    ),
                    child: TextField(
                      controller: _usuarioController,
                      decoration: InputDecoration(
                        labelText: "Usuario",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(height: 15),

                  Container(
                    width: 250,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(
                        255,
                        109,
                        190,
                        180,
                      ), // El color se establece dentro de la decoración
                      // También puedes añadir otras propiedades aquí, como bordes o gradientes
                    ),
                    child: TextField(
                      controller: _passwordController,
                      obscureText: true,
                      obscuringCharacter: "*",
                      decoration: InputDecoration(
                        labelText: "Contraseña",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: () {},
                    child: Text("Iniciar Sesión"),
                  ),
                  SizedBox(height: 30),
                  ElevatedButton(onPressed: () {}, child: Text("Registrarse")),
                ],
              ),
            ),

            SizedBox(height: 15),
            ElevatedButton(
              onPressed: () {},
              child: Text("Continuar sin iniciar sesión"),
            ),
          ],
        ),
      ),
      backgroundColor: Color.fromARGB(255, 255, 255, 255),
    );
  }
}

PreferredSizeWidget customAppBar() {
  return AppBar(
    title: Text(
      "Menú Login",
      style: TextStyle(color: Color.fromRGBO(255, 255, 255, 0.824)),
    ),
    backgroundColor: Color.fromARGB(255, 212, 137, 87),
  );
}
