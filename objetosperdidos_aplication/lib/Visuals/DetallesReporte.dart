import 'package:flutter/material.dart';
import 'package:objetosperdidos_aplication/Models/Reportes.dart';

class DetallesReporte extends StatefulWidget {
  final Reportes reporte;
  const DetallesReporte({super.key, required this.reporte});

  @override
  State<DetallesReporte> createState() => _DetallesReporte();
}

class _DetallesReporte extends State<DetallesReporte> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Detalles del Reporte'), centerTitle: true),
      body: Center(
        child: Column(
          children: [
            Text(
              widget.reporte.titulo,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 20),
            Text(
              widget.reporte.descripcion,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}