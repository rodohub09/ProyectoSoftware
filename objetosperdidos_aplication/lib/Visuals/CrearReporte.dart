import 'package:flutter/material.dart';
import 'package:objetosperdidos_aplication/Models/Reportes.dart';
import 'package:objetosperdidos_aplication/Utils/enumFiltros.dart';
import 'package:objetosperdidos_aplication/Utils/tipoReporte.dart';
import 'package:objetosperdidos_aplication/services/auth_service.dart';

class CrearReporte extends StatefulWidget {
  // 1. Añadimos los servicios como parámetros opcionales
  final AuthService? authService;
  final ReportesManager? reportesManager;

  const CrearReporte({
    super.key, 
    this.authService,
    this.reportesManager,
  });

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
  bool _isLoading = true;

  // 2. Variables locales para los servicios
  late final AuthService _authService;
  late final ReportesManager _reportesManager;

  @override
  void initState() {
    super.initState();
    _authService = widget.authService ?? AuthService();
    _reportesManager = widget.reportesManager ?? ReportesManager();
    
    _loadUser();
  }

  Future<void> _loadUser() async {
    _isAdmin = await _authService.isCurrentUserAdmin();
    _currentUserId = await _authService.getCurrentUserId();
    _isLoggedIn = await _authService.isLoggedIn();
    
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
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
      backgroundColor: Colors.grey[50], 
      appBar: AppBar(
        title: const Text(
          'Nuevo Reporte',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(), 
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 25),
                  _buildInputTitulo(),
                  const SizedBox(height: 25),
                  _buildSectionTitle('Categoría'),
                  const SizedBox(height: 10),
                  _buildCategorias(),
                
                  AnimatedCrossFade(
                    firstChild: Container(),
                    secondChild: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        _buildSectionTitle('Subcategoría'),
                        const SizedBox(height: 10),
                        _buildSubcategorias(),
                      ],
                    ),
                    crossFadeState: _categoriaSeleccionada != null 
                        ? CrossFadeState.showSecond 
                        : CrossFadeState.showFirst,
                    duration: const Duration(milliseconds: 300),
                  ),

                  const SizedBox(height: 25),
               
                  if (_isAdmin) ...[
                     _buildInputDescripcion(),
                     const SizedBox(height: 30),
                  ],

                  _buildBotonCrear(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildHeader() {
    return Text(
      'Detalles del Objeto',
      style: TextStyle(
        fontSize: 22, 
        fontWeight: FontWeight.bold, 
        color: Colors.grey[800]
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.grey[700],
      ),
    );
  }

  Widget _buildInputTitulo() {
    return TextField(
      controller: _tituloController,
      maxLength: 50,
      decoration: InputDecoration(
        labelText: 'Título del reporte',
        hintText: 'Ej. Llaves de auto Mazda',
        prefixIcon: const Icon(Icons.title),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
    );
  }

  Widget _buildInputDescripcion() {
    return TextField(
      controller: _descripcionController,
      maxLength: 200,
      maxLines: 3,
      decoration: InputDecoration(
        labelText: 'Descripción detallada',
        alignLabelWithHint: true,
        hintText: 'Describe el estado, color, marcas...',
        prefixIcon: const Padding(
          padding: EdgeInsets.only(bottom: 45), // Alinear icono arriba
          child: Icon(Icons.description),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
    );
  }

  Widget _buildCategorias() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Wrap(
        spacing: 8.0,
        runSpacing: 8.0,
        children: Enumfiltros.values.map((categoria) {
          final isSelected = _categoriaSeleccionada == categoria;
          return FilterChip(
            label: Text(categoria.label),
            selected: isSelected,
            selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
            checkmarkColor: Theme.of(context).primaryColor,
            labelStyle: TextStyle(
              color: isSelected ? Theme.of(context).primaryColor : Colors.black87,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
            backgroundColor: Colors.grey[100],
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            onSelected: (bool selected) {
              setState(() {
                _categoriaSeleccionada = selected ? categoria : null;
                _subcategoriaSeleccionada = null;
              });
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSubcategorias() {
    // Si no hay categoría, retornamos vacío
    if (_categoriaSeleccionada == null) return const SizedBox.shrink();
    
    final listaSub = subfiltros[_categoriaSeleccionada] ?? [];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Wrap(
        spacing: 8.0,
        runSpacing: 8.0,
        children: listaSub.map((subcategoria) {
          final isSelected = _subcategoriaSeleccionada == subcategoria;
          return ChoiceChip(
            label: Text(subcategoria),
            selected: isSelected,
            selectedColor: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
            labelStyle: TextStyle(
              color: isSelected ? Theme.of(context).colorScheme.secondary : Colors.black87,
            ),
            backgroundColor: Colors.grey[100],
            onSelected: (bool selected) {
              setState(() {
                _subcategoriaSeleccionada = selected ? subcategoria : null;
              });
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBotonCrear() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton.icon(
        onPressed: _handleCrearReporte,
        icon: const Icon(Icons.check_circle_outline),
        label: const Text(
          'PUBLICAR REPORTE',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 2,
        ),
      ),
    );
  }

  Future<void> _handleCrearReporte() async {
    final isAdmin = _isAdmin;
    
    if (!_isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Debes iniciar sesión para crear reportes'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    if (esFormularioValido()) {
      final DateTime ahora = DateTime.now();
      final ownerId = _currentUserId;
      final tipoAuto = isAdmin ? Tiporeporte.encontrado : Tiporeporte.perdido;
      
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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('¡Reporte creado exitosamente!'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Por favor complete todos los campos requeridos.'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  bool esFormularioValido() {
    final tituloOk = _tituloController.text.trim().isNotEmpty;
    final categoriaOk = _categoriaSeleccionada != null && _subcategoriaSeleccionada != null;
    
    if (_isAdmin) {
      return tituloOk && categoriaOk && _descripcionController.text.trim().isNotEmpty;
    }
    return tituloOk && categoriaOk;
  }
}