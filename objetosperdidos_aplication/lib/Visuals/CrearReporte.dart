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
  String? _subcategoriaSeleccionada;
  Tiporeporte? _tiporeporte;
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
          SizedBox(height: 10),
          Row(
            children: [
              SizedBox(width: 10),
              Expanded(
                child: TextField(
                  maxLength: 50,
                  controller: _tituloController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Título del reporte',
                  ),
                ),
              ),
              SizedBox(width: 10)
            ],
          ),
          SizedBox(height: 10),
          _buildSeleccionables(),
          SizedBox(height: 10),
          Row(
            children: [
              SizedBox(width: 10),
              Expanded(
                child: TextField(
                  maxLength: 200,
                  controller: _descripcionController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Descripción del objeto',
                  ),
                ),
              ),
              SizedBox(width: 10)
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
            SizedBox(width: 10),
            Text('Categoria:'),
            SizedBox(width: 10),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Wrap(
                  spacing: 8.0,
                  children: Enumfiltros.values.map((categoria) {
                    return FilterChip(
                      label: Text(categoria.label),
                      selected: _categoriaSeleccionada == categoria,
                      onSelected: (bool selected) {
                        setState(() {
                          _categoriaSeleccionada = selected ? categoria : null;
                          _subcategoriaSeleccionada =
                              null;
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
            ),
            SizedBox(width: 10)
          ],
        ),
        SizedBox(height: 10),
        if (_categoriaSeleccionada != null)
          Row(
            children: [
              SizedBox(width: 10),
              Text('Subcategoría:'),
              SizedBox(width: 10),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Wrap(
                    spacing: 8.0,
                    children: (subfiltros[_categoriaSeleccionada] ?? []).map((
                      subcategoria,
                    ) {
                      return ChoiceChip(
                        label: Text(subcategoria),
                        selected: _subcategoriaSeleccionada == subcategoria,
                        onSelected: (bool selected) {
                          setState(() {
                            _subcategoriaSeleccionada = selected
                                ? subcategoria
                                : null;
                          });
                        },
                      );
                    }).toList(),
                  ),
                ),
              ),
              SizedBox(width: 10)
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
            subcategoria: _subcategoriaSeleccionada!,
            tipoReporte: _tiporeporte!,
          );
          //ReportesManager().addReporte(nuevoReporte);
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
        _subcategoriaSeleccionada != null &&
        _tituloController.text.isNotEmpty &&
        _descripcionController.text.isNotEmpty;
  }
}
