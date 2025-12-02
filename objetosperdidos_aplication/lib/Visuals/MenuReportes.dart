import 'package:flutter/material.dart';
import 'package:objetosperdidos_aplication/Models/Reportes.dart';
import 'package:objetosperdidos_aplication/Models/mapa.dart';
import 'package:objetosperdidos_aplication/Utils/enumFiltros.dart';
import 'package:objetosperdidos_aplication/Utils/tipoReporte.dart';
import 'package:objetosperdidos_aplication/Visuals/CrearReporte.dart';
import 'package:objetosperdidos_aplication/Visuals/EditarReporte.dart';
import 'package:objetosperdidos_aplication/services/auth_service.dart';
import 'package:objetosperdidos_aplication/services/notification_service.dart';
import 'package:objetosperdidos_aplication/Visuals/Coincidencias.dart';
import 'package:objetosperdidos_aplication/screens/VentanaMenu.dart';

class MenuReportes extends StatefulWidget {
  const MenuReportes({super.key});

  @override
  State<MenuReportes> createState() => _MenuReportesState();
}

class _MenuReportesState extends State<MenuReportes> {
  Enumfiltros? _filtroSeleccionado;
  String? _subfiltroSeleccionado; // Nuevo estado para subfiltros
  final TextEditingController _controller = TextEditingController();
  
  bool _isAdmin = false;
  String? _viewerId;
  bool _showUserReportsForAdmin = true;
  Stream<String>? _notifStream;
  bool _isLoggedIn = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initUserState();
  }

  void _initUserState() async {
    _isAdmin = await AuthService().isCurrentUserAdmin();
    _viewerId = await AuthService().getCurrentUserId();
    _isLoggedIn = await AuthService().isLoggedIn();
    _notifStream = NotificationService().stream;
    
    _notifStream?.listen((msg) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            behavior: SnackBarBehavior.floating,
          )
        );
        setState(() {});
      }
    });

    if (mounted) setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Tablero de Reportes', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: _buildAppBarActions(),
      ),
      // Floating Action Button para crear reporte (UX más estándar)
      floatingActionButton: _isLoggedIn 
        ? FloatingActionButton.extended(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CrearReporte()),
              ).then((_) => setState(() {}));
            },
            label: const Text('Nuevo Reporte'),
            icon: const Icon(Icons.add),
          ) 
        : null,
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator()) 
        : Column(
            children: [
              _buildSearchAndFilters(),
              if (_isAdmin) _buildAdminToggle(),
              Expanded(child: _buildReportList()),
            ],
          ),
    );
  }

  List<Widget> _buildAppBarActions() {
    return [
      IconButton(
        tooltip: 'Puntos de Entrega',
        icon: const Icon(Icons.map_outlined),
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              insetPadding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min, // Se ajusta al contenido
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // --- Encabezado y Mensaje ---
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Puntos de Entrega',
                              style: TextStyle(
                                fontSize: 20, 
                                fontWeight: FontWeight.bold
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => Navigator.pop(context),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Acércate a las zonas marcadas en el mapa para entregar objetos encontrados o retirar los tuyos.',
                          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                  
                  // --- Mapa ---
                  SizedBox(
                    height: 500, // Altura fija para el mapa
                    width: double.maxFinite,
                    child: ClipRRect(
                      // Redondeamos solo las esquinas inferiores
                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
                      child: const Mapa(),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      if (_isLoggedIn) ...[
        IconButton(
          tooltip: 'Coincidencias',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CoincidenciasScreen(
                  viewerId: _viewerId,
                  viewerIsAdmin: _isAdmin,
                ),
              ),
            );
          },
          icon: const Icon(Icons.link),
        ),
        IconButton(
          tooltip: 'Cerrar sesión',
          onPressed: () async {
            await AuthService().logout();
            if (mounted) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const VentanaMenu()),
                (route) => false,
              );
            }
          },
          icon: const Icon(Icons.logout, color: Colors.redAccent),
        ),
      ],
    ];
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Barra de búsqueda
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: "Buscar objeto...",
              prefixIcon: const Icon(Icons.search),
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (value) => setState(() {}),
          ),
          const SizedBox(height: 15),
          
          // Título Filtros
          const Text(
            "Filtrar por Categoría",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: 8),

          // Chips de Categorías
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Wrap(
              spacing: 8.0,
              children: Enumfiltros.values.map((filtro) {
                final isSelected = _filtroSeleccionado == filtro;
                return ChoiceChip(
                  label: Text(filtro.label),
                  selected: isSelected,
                  selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
                  labelStyle: TextStyle(
                    color: isSelected ? Theme.of(context).primaryColor : Colors.black87,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  onSelected: (selected) {
                    setState(() {
                      // Al cambiar categoría, reseteamos el subfiltro
                      _filtroSeleccionado = selected ? filtro : null;
                      _subfiltroSeleccionado = null;
                    });
                  },
                );
              }).toList(),
            ),
          ),

          // Subfiltros (Animados)
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            child: _filtroSeleccionado != null
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    const Text(
                      "Especificar Tipo",
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Wrap(
                        spacing: 8.0,
                        children: (subfiltros[_filtroSeleccionado] ?? []).map((sub) {
                          final isSelected = _subfiltroSeleccionado == sub;
                          return FilterChip(
                            label: Text(sub),
                            selected: isSelected,
                            checkmarkColor: Colors.white,
                            selectedColor: Colors.blueAccent,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : Colors.black87,
                            ),
                            backgroundColor: Colors.grey[100],
                            onSelected: (selected) {
                              setState(() {
                                _subfiltroSeleccionado = selected ? sub : null;
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                )
              : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminToggle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const Text('Ver reportes de usuarios', style: TextStyle(fontSize: 12)),
          Switch(
            value: _showUserReportsForAdmin,
            activeColor: Colors.green,
            onChanged: (v) => setState(() => _showUserReportsForAdmin = v),
          ),
        ],
      ),
    );
  }

  Widget _buildReportList() {
    final listaReportes = _aplicarFiltros();

    if (listaReportes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 10),
            Text(
              "No se encontraron reportes",
              style: TextStyle(color: Colors.grey[500], fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: listaReportes.length,
      itemBuilder: (context, index) {
        return _buildCardReporte(listaReportes[index]);
      },
    );
  }

  Widget _buildCardReporte(Reportes reporte) {
    final isPerdido = reporte.tipoReporte == Tiporeporte.perdido;
    final colorBase = isPerdido ? Colors.orange : Colors.green;
    
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          // Opcional: Expandir detalles al tocar la tarjeta entera
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icono indicador
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: colorBase.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isPerdido ? Icons.search : Icons.check_circle,
                      color: colorBase,
                    ),
                  ),
                  const SizedBox(width: 15),
                  // Título y Subtítulo
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          reporte.titulo,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${reporte.categoria.label} • ${reporte.subcategoria}',
                          style: TextStyle(color: Colors.grey[600], fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  _buildPopupMenu(reporte),
                ],
              ),
              const SizedBox(height: 12),
              // Footer de la tarjeta
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isPerdido ? Colors.orange[50] : Colors.green[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: colorBase.withOpacity(0.3)),
                    ),
                    child: Text(
                      isPerdido ? "PERDIDO" : "ENCONTRADO",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: colorBase,
                      ),
                    ),
                  ),
                  Text(
                    formatearFecha(reporte.createdAt),
                    style: TextStyle(color: Colors.grey[400], fontSize: 12),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPopupMenu(Reportes reporte) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert, color: Colors.grey[400]),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (value) => _handleMenuAction(value, reporte),
      itemBuilder: (context) {
        final canDelete = _isAdmin || reporte.ownerId == _viewerId;
        final canEdit = reporte.ownerId == _viewerId;
        
        return [
          if (reporte.descripcion != null && reporte.descripcion!.isNotEmpty)
            const PopupMenuItem(
              value: 'ver_descripcion',
              child: Row(
                children: [Icon(Icons.info_outline, size: 20), SizedBox(width: 10), Text('Detalles')],
              ),
            ),
          if (canEdit)
            const PopupMenuItem(
              value: 'editar',
              child: Row(
                children: [Icon(Icons.edit, size: 20), SizedBox(width: 10), Text('Editar')],
              ),
            ),
          PopupMenuItem(
            value: 'eliminar',
            enabled: canDelete,
            child: Row(
              children: [
                Icon(Icons.delete_outline, size: 20, color: canDelete ? Colors.red : Colors.grey),
                const SizedBox(width: 10),
                Text('Eliminar', style: TextStyle(color: canDelete ? Colors.red : Colors.grey)),
              ],
            ),
          ),
        ];
      },
    );
  }

  // Lógica de acciones del menú extraída para limpieza
  void _handleMenuAction(String value, Reportes reporte) async {
    if (value == 'eliminar') {
      final isAdmin = _isAdmin;
      if (isAdmin || reporte.ownerId == _viewerId) {
        if (reporte.ownerIsAdmin) {
          ReportesManager().removeAdminReport(reporte);
        } else {
          ReportesManager().removeUserReport(reporte);
        }
        setState(() {});
      }
    } else if (value == 'editar') {
       final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => EditarReporte(reporte: reporte)),
      );
      if (result == true && mounted) setState(() {});
    } else if (value == 'ver_descripcion') {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(reporte.titulo),
          content: Text(reporte.descripcion ?? ''),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cerrar'))
          ],
        ),
      );
    }
  }

  String formatearFecha(DateTime fecha) {
    String dia = fecha.day.toString().padLeft(2, '0');
    String mes = fecha.month.toString().padLeft(2, '0');
    String hora = fecha.hour.toString().padLeft(2, '0');
    String min = fecha.minute.toString().padLeft(2, '0');
    return '$dia/$mes ${fecha.year} • $hora:$min';
  }

  List<Reportes> _aplicarFiltros() {
    final query = _controller.text.trim().toLowerCase();
    var reportes = ReportesManager().getVisibleReports(
      viewerId: _viewerId,
      viewerIsAdmin: _isAdmin,
      adminWantsToSeeUserReports: _showUserReportsForAdmin,
    );

    // 1. Filtro Categoría
    if (_filtroSeleccionado != null) {
      reportes = reportes.where((r) => r.categoria == _filtroSeleccionado).toList();
      
      // 2. Filtro Subcategoría (solo si hay categoría seleccionada)
      if (_subfiltroSeleccionado != null) {
         reportes = reportes.where((r) => r.subcategoria == _subfiltroSeleccionado).toList();
      }
    }

    // 3. Filtro Búsqueda Texto
    if (query.isNotEmpty) {
      reportes = reportes.where((r) => r.titulo.toLowerCase().contains(query)).toList();
    }

    return reportes;
  }
}
