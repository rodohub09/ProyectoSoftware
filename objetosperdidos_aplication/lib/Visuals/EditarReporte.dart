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
  bool _isSaving = false; // Para evitar doble tap al guardar

  @override
  void initState() {
    super.initState();
    _loadUser();
    _loadReportData();
  }

  Future<void> _loadUser() async {
    _isAdmin = await AuthService().isCurrentUserAdmin();
    if (mounted) setState(() {});
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
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Editar Reporte', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(), // Ocultar teclado
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Información Básica'),
              const SizedBox(height: 15),
              _buildInputTitulo(),
              const SizedBox(height: 25),
              
              _buildSectionTitle('Clasificación'),
              const SizedBox(height: 10),
              _buildSeleccionables(),
              
              const SizedBox(height: 25),
              
              // Solo mostrar sección de descripción si es Admin
              if (_isAdmin) ...[
                _buildSectionTitle('Detalles (Admin)'),
                const SizedBox(height: 10),
                _buildInputDescripcion(),
                const SizedBox(height: 30),
              ],

              _buildBotonGuardar(),
              const SizedBox(height: 20),
            ],
          ),
        ),
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
        hintText: 'Ej. Llaves de auto',
        prefixIcon: const Icon(Icons.edit_outlined),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
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
        prefixIcon: const Padding(
          padding: EdgeInsets.only(bottom: 45), 
          child: Icon(Icons.description_outlined),
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
    );
  }

  Widget _buildSeleccionables() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Categorías
        Container(
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
              return ChoiceChip(
                label: Text(categoria.label),
                selected: isSelected,
                selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
                labelStyle: TextStyle(
                  color: isSelected ? Theme.of(context).primaryColor : Colors.black87,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                backgroundColor: Colors.grey[100],
                onSelected: (bool selected) {
                  setState(() {
                    _categoriaSeleccionada = selected ? categoria : null;
                    _subcategoriaSeleccionada = null; // Reset subcategoria
                  });
                },
              );
            }).toList(),
          ),
        ),
        
        // Subcategorías (Animación suave)
        AnimatedCrossFade(
          firstChild: Container(), // Espacio vacío si no hay categoría
          secondChild: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 15),
              const Text('Subcategoría:', style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              Container(
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
                  children: (subfiltros[_categoriaSeleccionada] ?? []).map((subcategoria) {
                    final isSelected = _subcategoriaSeleccionada == subcategoria;
                    return FilterChip(
                      label: Text(subcategoria),
                      selected: isSelected,
                      checkmarkColor: Colors.white,
                      selectedColor: Colors.blueAccent,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
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
              ),
            ],
          ),
          crossFadeState: _categoriaSeleccionada != null 
              ? CrossFadeState.showSecond 
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 300),
        ),
      ],
    );
  }

  Widget _buildBotonGuardar() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton.icon(
        icon: _isSaving 
          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
          : const Icon(Icons.save_as_outlined),
        label: Text(
          _isSaving ? 'GUARDANDO...' : 'GUARDAR CAMBIOS',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
        ),
        onPressed: _isSaving ? null : _handleGuardar,
      ),
    );
  }

  Future<void> _handleGuardar() async {
    if (!esFormularioValido()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Por favor complete todos los campos requeridos.'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    // Simular pequeño delay para UX
    await Future.delayed(const Duration(milliseconds: 500));

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
      createdAt: widget.reporte.createdAt, // Mantenemos la fecha original
    );

    // Lógica de actualización (Remove + Add)
    if (widget.reporte.ownerIsAdmin) {
      ReportesManager().removeAdminReport(widget.reporte);
      ReportesManager().addAdminReport(reporteActualizado);
    } else {
      ReportesManager().removeUserReport(widget.reporte);
      ReportesManager().addUserReport(reporteActualizado);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 10),
              Text('Reporte actualizado exitosamente'),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
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