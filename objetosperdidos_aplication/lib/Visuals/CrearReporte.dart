import 'package:flutter/material.dart';
import 'package:objetosperdidos_aplication/Models/Reportes.dart';
import 'package:objetosperdidos_aplication/Utils/enumFiltros.dart';
import 'package:objetosperdidos_aplication/Utils/tipoReporte.dart';

class CrearReporte extends StatefulWidget {
  const CrearReporte({super.key});

  @override
  State<CrearReporte> createState() => _CrearRegistroState();
}

class _CrearRegistroState extends State<CrearReporte> {
  Enumfiltros? _categoriaSeleccionada;
  Tiporeporte? _tipoReporteSeleccionado;
  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();

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
      appBar: AppBar(title: Text('Crear Registro'), centerTitle: true),
      body: _buildFormulario(),
    );
  }

  Widget _buildFormulario() {
    return Center(
      child: Column(
        children: [
          Row(
            children: [
              Text('Titulo del reporte:'),
              SizedBox(width: 10),
              SizedBox(
                width: 200,
                child: TextField(maxLength: 50, controller: _tituloController),
              ),
            ],
          ),
          SizedBox(height: 10),
          _buildSeleccionables(),
          SizedBox(height: 10),
          Row(
            children: [
              Text('Descripcion del reporte:'),
              SizedBox(width: 10),
              Expanded(
                child: TextField(
                  maxLength: 200,
                  controller: _descripcionController,
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          _buildBotonCrear(),
          SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildSeleccionables() {
    return Column(
      children: [
        Row(
          children: [
            Text('Categoria:'),
            SizedBox(width: 10),
            Wrap(
              spacing: 8.0,
              children: Enumfiltros.values.map((categoria) {
                return FilterChip(
                  label: Text(categoria.label),
                  selected: _categoriaSeleccionada == categoria,
                  onSelected: (bool selected) {
                    setState(() {
                      _categoriaSeleccionada = selected ? categoria : null;
                    });
                  },
                );
              }).toList(),
            ),
          ],
        ),
        SizedBox(height: 10),
        Row(
          children: [
            Text('Tipo de reporte:'),
            SizedBox(width: 10),
            Wrap(
              spacing: 8.0,
              children: Tiporeporte.values.map((reporte) {
                return FilterChip(
                  label: Text(reporte.label),
                  selected: _tipoReporteSeleccionado == reporte,
                  onSelected: (bool selected) {
                    setState(() {
                      _tipoReporteSeleccionado = selected ? reporte : null;
                    });
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBotonCrear() {
    return ElevatedButton(
      onPressed: () {
        if (esFormularioValido()) {
          Reportes nuevoReporte = Reportes(
            titulo: _tituloController.text,
            descripcion: _descripcionController.text,
            categoria: _categoriaSeleccionada!,
            tipoReporte: _tipoReporteSeleccionado!,
          );
          ReportesManager().addReporte(nuevoReporte);
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              duration: Duration(seconds: 2),
              content: Text(
                'Por favor complete todos los campos del formulario.',
              ),
            ),
          );
        }
      },
      child: Text('Crear Reporte'),
    );
  }

  bool esFormularioValido() {
    return _categoriaSeleccionada != null &&
        _tipoReporteSeleccionado != null &&
        _tituloController.text.isNotEmpty &&
        _descripcionController.text.isNotEmpty;
  } 
}
