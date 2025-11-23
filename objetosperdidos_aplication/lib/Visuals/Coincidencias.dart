import 'package:flutter/material.dart';
import 'package:objetosperdidos_aplication/Models/Reportes.dart';
import 'package:objetosperdidos_aplication/services/notification_service.dart';

class CoincidenciasScreen extends StatefulWidget {
  final String? viewerId;
  final bool viewerIsAdmin;

  const CoincidenciasScreen({
    super.key,
    this.viewerId,
    this.viewerIsAdmin = false,
  });

  @override
  State<CoincidenciasScreen> createState() => _CoincidenciasScreenState();
}

class _CoincidenciasScreenState extends State<CoincidenciasScreen> {
  List<MatchPair> _matches = [];

  @override
  void initState() {
    super.initState();
    _loadMatches();
    NotificationService().stream.listen((msg) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(msg)));
        _loadMatches();
      }
    });
  }

  bool get _isGuest => widget.viewerId == null && !widget.viewerIsAdmin;

  void _loadMatches() {
    final all = ReportesManager().getAllMatches();
    if (widget.viewerIsAdmin) {
      _matches = all;
    } else {
      _matches = all
          .where((m) => m.userReport.ownerId == widget.viewerId)
          .toList();
    }
    setState(() {});
  }

  void _deleteUserReport(Reportes r) {
    ReportesManager().removeUserReport(r);
    NotificationService().notify('Reporte de usuario eliminado');
    _loadMatches();
  }

  void _deleteAdminReport(Reportes r) {
    ReportesManager().removeAdminReport(r);
    NotificationService().notify('Reporte admin eliminado');
    _loadMatches();
  }

  void _markRecogido(Reportes r) {
    r.recogido = true;
    ReportesManager().updateReport(r);
    NotificationService().notify('Reporte marcado como recogido');
    _loadMatches();
  }

  @override
  Widget build(BuildContext context) {
    if (_isGuest) {
      return Scaffold(
        appBar: AppBar(title: const Text('Coincidencias')),
        body: const Center(
          child: Text('Debes iniciar sesión para ver coincidencias'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Coincidencias')),
      body: _matches.isEmpty
          ? const Center(child: Text('No hay coincidencias'))
          : ListView.builder(
              itemCount: _matches.length,
              itemBuilder: (context, index) {
                final m = _matches[index];
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          m.adminReport.titulo,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Admin: ${m.adminReport.ownerId ?? 'admin'} - ${m.adminReport.descripcion ?? ''}',
                        ),
                        const SizedBox(height: 6),
                        Text('Usuario: ${m.userReport.ownerId ?? 'anon'}'),
                        const SizedBox(height: 6),
                        Text(
                          'Categoria: ${m.adminReport.categoria.label} - ${m.adminReport.subcategoria}',
                        ),
                        const SizedBox(height: 6),
                        Text('Fecha coincidencia: ${m.matchedAt.toLocal()}'),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            if (widget.viewerIsAdmin) ...[
                              ElevatedButton(
                                onPressed: () =>
                                    _deleteUserReport(m.userReport),
                                child: const Text('Eliminar usuario'),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: () =>
                                    _deleteAdminReport(m.adminReport),
                                child: const Text('Eliminar admin'),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: () => _markRecogido(m.adminReport),
                                child: const Text('Marcar recogido'),
                              ),
                            ] else ...[
                              if (m.userReport.ownerId == widget.viewerId) ...[
                                ElevatedButton(
                                  onPressed: () =>
                                      _deleteUserReport(m.userReport),
                                  child: const Text('Eliminar mi reporte'),
                                ),
                              ],
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
