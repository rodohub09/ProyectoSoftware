import 'package:flutter/material.dart';
import 'package:objetosperdidos_aplication/Models/Reportes.dart';
import 'package:objetosperdidos_aplication/Utils/enumFiltros.dart';
import 'package:objetosperdidos_aplication/Utils/tipoReporte.dart';
import 'package:objetosperdidos_aplication/services/auth_service.dart';

class CrearReporte extends StatefulWidget {
  const CrearReporte({super.key});

  @override
  State<CrearReporte> createState() => _CrearRegistroState();
}

class _CrearRegistroState extends State<CrearReporte> {
  Enumfiltros? _categoriaSeleccionada;
  String? _subcategoriaSeleccionada;
  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  bool _isAdmin = false;
  String? _currentUserId;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    _isAdmin = await AuthService().isCurrentUserAdmin();
    _currentUserId = await AuthService().getCurrentUserId();
    _isLoggedIn = await AuthService().isLoggedIn();
    setState(() {});
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
              SizedBox(width: 10),
            ],
          ),
          SizedBox(height: 10),
          _buildSeleccionables(),
          SizedBox(height: 10),
          // Descripción solo editable si es admin
          Row(
            children: [
              SizedBox(width: 10),
              Expanded(
                child: TextField(
                  maxLength: 200,
                  controller: _descripcionController,
                  enabled: _isAdmin,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: _isAdmin
                        ? 'Descripción del objeto'
                        : 'Descripción (solo admins pueden escribir)',
                  ),
                ),
              ),
              SizedBox(width: 10),
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
                          _subcategoriaSeleccionada = null;
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
            ),
            SizedBox(width: 10),
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
              SizedBox(width: 10),
            ],
          ),
      ],
    );
  }

  Widget _buildBotonCrear() {
    return ElevatedButton(
      onPressed: () async {
        final isAdmin = _isAdmin;
        if (!_isLoggedIn) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Debes iniciar sesión para crear reportes'),
            ),
          );
          return;
        }
        if (esFormularioValido()) {
          final DateTime ahora = DateTime.now();
          final ownerId = _currentUserId;
          // Tipo automático: admin = Encontrado, usuario = Perdido
          final tipoAuto = isAdmin
              ? Tiporeporte.encontrado
              : Tiporeporte.perdido;
          final reporte = Reportes(
            titulo: _tituloController.text.trim(),
            descripcion: isAdmin ? _descripcionController.text.trim() : null,
            categoria: _categoriaSeleccionada!,
            subcategoria: _subcategoriaSeleccionada!,
            tipoReporte: tipoAuto,
            ownerId: ownerId,
            ownerIsAdmin: isAdmin,
            createdAt: ahora,
          );

          if (isAdmin) {
            ReportesManager().addAdminReport(reporte);
          } else {
            ReportesManager().addUserReport(reporte);
          }

          Navigator.pop(context);
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
      child: const Text('Crear Reporte'),
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
    // usuarios no deben proveer descripción, tipo es automático
    return tituloOk && categoriaOk;
  }
}
