import 'package:flutter/material.dart';
import 'package:objetosperdidos_aplication/botonesTraslado.dart';
import 'package:objetosperdidos_aplication/ejemplo.dart';

class PantallaInicio extends StatelessWidget {
  const PantallaInicio({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Objetos perdidos UDEC"),
        ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 1200,
              child: Padding(
                padding: const EdgeInsets.all(50.0),
                child: Image(
                  image: AssetImage("assets/image/mapaUDEC.png"),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: BototonesTraslado(
                nombre: "Reportar objeto perdido",
                paginaDireccionada: Ejemplo(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: BototonesTraslado(
                nombre: "Ver reportes",
                paginaDireccionada: Ejemplo(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}