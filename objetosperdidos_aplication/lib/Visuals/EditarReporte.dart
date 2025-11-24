import 'package:flutter/material.dart';
import 'package:objetosperdidos_aplication/Models/Reportes.dart';
import 'package:objetosperdidos_aplication/Utils/enumFiltros.dart';
import 'package:objetosperdidos_aplication/services/auth_service.dart';

class EditarReporte extends StatefulWidget {
  final Reportes reporte;

  const EditarReporte({super.key, required this.reporte});

  @override
  State<EditarReporte> createState() => _EditarReporteState();
}

class _EditarReporteState extends State<EditarReporte> {
  Enumfiltros? _categoriaSeleccionada;
  String? _subcategoriaSeleccionada;
  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _loadUser();
    _loadReportData();
  }

  Future<void> _loadUser() async {
    _isAdmin = await AuthService().isCurrentUserAdmin();
    setState(() {});
  }

  void _loadReportData() {
    _tituloController.text = widget.reporte.titulo;
    _descripcionController.text = widget.reporte.descripcion ?? '';
    _categoriaSeleccionada = widget.reporte.categoria;
    _subcategoriaSeleccionada = widget.reporte.subcategoria;
    setState(() {});
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar Reporte'), centerTitle: true),
      body: _buildFormulario(),
    );
  }

  Widget _buildFormulario() {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 10),
            Row(
              children: [
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    maxLength: 50,
                    controller: _tituloController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Título del reporte',
                    ),
                  ),
                ),
                const SizedBox(width: 10),
              ],
            ),
            const SizedBox(height: 10),
            _buildSeleccionables(),
            const SizedBox(height: 10),
            // Descripción solo editable si es admin
            Row(
              children: [
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    maxLength: 200,
                    controller: _descripcionController,
                    enabled: _isAdmin,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: _isAdmin
                          ? 'Descripción del objeto'
                          : 'Descripción (solo admins pueden escribir)',
                    ),
                  ),
                ),
                const SizedBox(width: 10),
              ],
            ),
            const SizedBox(height: 10),
            _buildBotonGuardar(),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildSeleccionables() {
    return Column(
      children: [
        Row(
          children: [
            const SizedBox(width: 10),
            const Text('Categoria:'),
            const SizedBox(width: 10),
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
                          _subcategoriaSeleccionada = null;
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(width: 10),
          ],
        ),
        const SizedBox(height: 10),
        if (_categoriaSeleccionada != null)
          Row(
            children: [
              const SizedBox(width: 10),
              const Text('Subcategoría:'),
              const SizedBox(width: 10),
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
              const SizedBox(width: 10),
            ],
          ),
      ],
    );
  }

  Widget _buildBotonGuardar() {
    return ElevatedButton(
      onPressed: () async {
        if (esFormularioValido()) {
          // Crear un nuevo reporte con los datos actualizados
          final reporteActualizado = Reportes(
            titulo: _tituloController.text.trim(),
            descripcion: _isAdmin
                ? _descripcionController.text.trim()
                : widget.reporte.descripcion,
            categoria: _categoriaSeleccionada!,
            subcategoria: _subcategoriaSeleccionada!,
            tipoReporte: widget.reporte.tipoReporte,
            ownerId: widget.reporte.ownerId,
            ownerIsAdmin: widget.reporte.ownerIsAdmin,
            recogido: widget.reporte.recogido,
            createdAt: widget.reporte.createdAt,
          );

          // Eliminar el reporte viejo y agregar el nuevo
          if (widget.reporte.ownerIsAdmin) {
            ReportesManager().removeAdminReport(widget.reporte);
            ReportesManager().addAdminReport(reporteActualizado);
          } else {
            ReportesManager().removeUserReport(widget.reporte);
            ReportesManager().addUserReport(reporteActualizado);
          }

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Reporte actualizado')),
            );
            Navigator.pop(context, true);
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              duration: Duration(seconds: 2),
              content: Text(
                'Por favor complete todos los campos del formulario.',
              ),
            ),
          );
        }
      },
      child: const Text('Guardar Cambios'),
    );
  }

  bool esFormularioValido() {
    final tituloOk = _tituloController.text.trim().isNotEmpty;
    final categoriaOk =
        _categoriaSeleccionada != null && _subcategoriaSeleccionada != null;
    if (_isAdmin) {
      return tituloOk &&
          categoriaOk &&
          _descripcionController.text.trim().isNotEmpty;
    }
    // usuarios no deben proveer descripción
    return tituloOk && categoriaOk;
  }
}
