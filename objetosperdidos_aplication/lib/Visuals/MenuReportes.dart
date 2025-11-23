import 'package:flutter/material.dart';
import 'package:objetosperdidos_aplication/Models/Reportes.dart';
import 'package:objetosperdidos_aplication/Models/mapa_test.dart';
import 'package:objetosperdidos_aplication/Utils/enumFiltros.dart';
import 'package:objetosperdidos_aplication/Utils/tipoReporte.dart';
import 'package:objetosperdidos_aplication/Visuals/CrearReporte.dart';
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
  final List<Reportes> listaReportes = [];
  Enumfiltros? _filtroSeleccionado;
  final TextEditingController _controller = TextEditingController();
  bool _isAdmin = false;
  String? _viewerId;
  bool _showUserReportsForAdmin = true;
  Stream<String>? _notifStream;
  bool _isLoggedIn = false;

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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(msg)));
        setState(() {});
      }
    });
    setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu de Reportes'),
        actions: [
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
                    MaterialPageRoute(
                      builder: (context) => const VentanaMenu(),
                    ),
                    (route) => false,
                  );
                }
              },
              icon: const Icon(Icons.logout),
            ),
          ],
          ElevatedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text("Mapa Zonas de Control"),
                    content:SizedBox(
                      width: 2500,
                      height: 1200,
                      child: Mapa()
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text("Cerrar"),
                      ),
                    ],
                  );
                },
              );
            },
            child: const Text("Zonas de control"),
          ),
        ],
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          children: [
            _buildBuscaryFiltrar(),
            SizedBox(height: 10),
            Expanded(child: _buildReportList()),
            SizedBox(height: 10),
            if (_isAdmin)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Mostrar reportes de usuarios:'),
                  Switch(
                    value: _showUserReportsForAdmin,
                    onChanged: (v) =>
                        setState(() => _showUserReportsForAdmin = v),
                  ),
                ],
              ),
            if (_isLoggedIn)
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CrearReporte(),
                    ),
                  ).then((_) => setState(() {}));
                },
                child: Text('Crear Nuevo Reporte'),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Inicia sesión para crear reportes'),
                      ),
                    );
                  },
                  child: const Text('Inicia sesión para crear reportes'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBuscaryFiltrar() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: "Busca un reporte por coincidencia de nombre",
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) => setState(() {}),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: ExpansionTile(
            collapsedBackgroundColor: const Color.fromARGB(255, 255, 253, 118),
            backgroundColor: const Color.fromARGB(255, 255, 253, 118),
            title: Text(
              'Filtrar por tipo de objeto:',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            collapsedShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade300),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade300),
            ),
            childrenPadding: const EdgeInsets.all(8.0),
            children: [
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: Enumfiltros.values.map((filtro) {
                  return FilterChip(
                    label: Text(
                      filtro.label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    selected: _filtroSeleccionado == filtro,
                    selectedColor: Colors.blueAccent,
                    backgroundColor: Colors.lightBlue,
                    checkmarkColor: const Color.fromARGB(255, 10, 0, 98),
                    onSelected: (selected) {
                      setState(() {
                        _filtroSeleccionado = selected ? filtro : null;
                      });
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReportList() {
    final listaReportes = _aplicarFiltros();
    return NotificationListener<ScrollNotification>(
      onNotification: (scrollInfo) {
        setState(() {});
        return true;
      },
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
        itemCount: listaReportes.length,
        itemBuilder: (context, index) {
          final reporte = listaReportes[index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: _buildCardReporte(reporte),
          );
        },
      ),
    );
  }

  String formatearFecha(DateTime fecha) {
  String dia = fecha.day.toString().padLeft(2, '0');
  String mes = fecha.month.toString().padLeft(2, '0');
  String anio = fecha.year.toString();
  String hora = fecha.hour.toString().padLeft(2, '0');
  String min = fecha.minute.toString().padLeft(2, '0');

  return '$dia/$mes/$anio $hora:$min';
}
  
  Widget _buildCardReporte(Reportes reporte) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        color: reporte.tipoReporte == Tiporeporte.perdido
            ? Colors.orangeAccent.shade100
            : Colors.blueAccent.shade100,
        elevation: 4.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      reporte.titulo,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) async {
                      if (value == 'eliminar') {
                        // Only admin or owner can delete
                        final isAdmin = _isAdmin;
                        if (isAdmin || reporte.ownerId == _viewerId) {
                          if (reporte.ownerIsAdmin) {
                            ReportesManager().removeAdminReport(reporte);
                            NotificationService().notify(
                              'Reporte admin eliminado',
                            );
                          } else {
                            ReportesManager().removeUserReport(reporte);
                            NotificationService().notify(
                              'Reporte usuario eliminado',
                            );
                          }
                          setState(() {});
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'No tienes permiso para eliminar este reporte',
                              ),
                            ),
                          );
                        }
                      } else if (value == 'recogido') {
                        // mark collected (admin action)
                        final isAdmin = _isAdmin;
                        if (isAdmin) {
                          reporte.recogido = true;
                          await ReportesManager().updateReport(reporte);
                          NotificationService().notify(
                            'Reporte marcado como recogido',
                          );
                          setState(() {});
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Solo admin puede marcar recogido'),
                            ),
                          );
                        }
                      }
                    },
                    itemBuilder: (context) {
                      final canDelete =
                          _isAdmin || reporte.ownerId == _viewerId;
                      return [
                        PopupMenuItem(
                          value: 'eliminar',
                          child: Text(canDelete ? 'Eliminar' : 'No disponible'),
                        ),
                        if (_isAdmin)
                          PopupMenuItem(
                            value: 'recogido',
                            child: const Text('Marcar recogido'),
                          ),
                      ];
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8.0),
              Text(
                reporte.categoria.label,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 8.0),
              Text(
                'Fecha: ${formatearFecha( reporte.createdAt)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Reportes> _aplicarFiltros() {
    final query = _controller.text.trim().toLowerCase();
    var reportes = ReportesManager().getVisibleReports(
      viewerId: _viewerId,
      viewerIsAdmin: _isAdmin,
      adminWantsToSeeUserReports: _showUserReportsForAdmin,
    );

    // Filtra por tipos seleccionados (en inglés)
    if (_filtroSeleccionado != null) {
      reportes = reportes
          .where((reporte) => reporte.categoria == _filtroSeleccionado)
          .toList();
    }

    // Filtra por nombre o id si hay texto
    if (query.isNotEmpty) {
      reportes = reportes
          .where((reporte) => reporte.titulo.toLowerCase().contains(query))
          .toList();
    }

    return reportes;
  }
}
