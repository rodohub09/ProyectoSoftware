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

  void _markRecogido(MatchPair match) {
    ReportesManager().markMatchAsRecogido(match);
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
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                m.adminReport.titulo,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            if (!widget.viewerIsAdmin &&
                                m.adminReport.descripcion != null)
                              IconButton(
                                icon: const Icon(Icons.info_outline),
                                tooltip: 'Ver descripción',
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: Text(m.adminReport.titulo),
                                      content: SingleChildScrollView(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Text(
                                              'Descripción del reporte encontrado:',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              m.adminReport.descripcion ??
                                                  'Sin descripción',
                                            ),
                                          ],
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: const Text('Cerrar'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text('Admin: ${m.adminReport.ownerId ?? 'admin'}'),
                        const SizedBox(height: 6),
                        Text('Usuario: ${m.userReport.ownerId ?? 'anon'}'),
                        const SizedBox(height: 6),
                        Text(
                          'Categoria: ${m.adminReport.categoria.label} - ${m.adminReport.subcategoria}',
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Fecha coincidencia: ${m.matchedAt.day}/${m.matchedAt.month}/${m.matchedAt.year} ${m.matchedAt.hour.toString().padLeft(2, '0')}:${m.matchedAt.minute.toString().padLeft(2, '0')}',
                        ),
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
                                onPressed: () => _markRecogido(m),
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
