import 'package:flutter/material.dart';

class BototonesTraslado extends StatelessWidget {
  final String nombre;
  final Widget paginaDireccionada;

  const BototonesTraslado({
    super.key,
    required this.nombre,
    required this.paginaDireccionada  
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed:() {
        Navigator.push(
          context, 
          MaterialPageRoute(
            builder:(context) => paginaDireccionada,
          )
        );
      },
      child: Text(nombre),
    );
  }
}