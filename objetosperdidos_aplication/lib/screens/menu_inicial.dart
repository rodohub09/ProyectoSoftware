import 'package:flutter/material.dart';
import 'package:objetosperdidos_aplication/Visuals/MenuReportes.dart';

class MenuInicial extends StatefulWidget {
  const MenuInicial({super.key});

  @override
  State<MenuInicial> createState() => _MenuInicialState();
}

class _MenuInicialState extends State<MenuInicial> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ElevatedButton(
              //objeto perdido para ventana de objetos perdidos
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MenuReportes()),
                );
              },
              child: Text("Objetos Perdidos"),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text("Mapa Zonas de Control"),
                      content: Image.asset('assets/image/mapaUDEC.png'), 
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text("Cerrar"),
                        ),
                      ],
                    );
                  },
                );},
              child: Text("Mapa Zonas de control de objetos"),
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
      "Menú",
      style: TextStyle(color: Color.fromRGBO(255, 255, 255, 0.824)),
    ),
    backgroundColor: Color.fromARGB(255, 212, 137, 87),
  );
}
