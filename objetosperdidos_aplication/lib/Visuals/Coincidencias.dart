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
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMatches();
    NotificationService().stream.listen((msg) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.blueGrey,
          ),
        );
        _loadMatches();
      }
    });
  }

  bool get _isGuest => widget.viewerId == null && !widget.viewerIsAdmin;

  Future<void> _loadMatches() async {
    // Simulamos un pequeño delay para sensación de carga si fuera real
    await Future.delayed(Duration.zero);
    final all = ReportesManager().getAllMatches();
    if (widget.viewerIsAdmin) {
      _matches = all;
    } else {
      _matches = all
          .where((m) => m.userReport.ownerId == widget.viewerId)
          .toList();
    }
    if (mounted) setState(() => _isLoading = false);
  }

  void _deleteUserReport(Reportes r) {
    _confirmAction('Eliminar reporte de usuario', () {
      ReportesManager().removeUserReport(r);
      NotificationService().notify('Reporte de usuario eliminado');
      _loadMatches();
    });
  }

  void _deleteAdminReport(Reportes r) {
    _confirmAction('Eliminar reporte de administrador', () {
      ReportesManager().removeAdminReport(r);
      NotificationService().notify('Reporte admin eliminado');
      _loadMatches();
    });
  }

  void _markRecogido(MatchPair match) {
    _confirmAction('Confirmar entrega del objeto', () {
      ReportesManager().markMatchAsRecogido(match);
      _loadMatches();
    }, isDestructive: false);
  }

  void _confirmAction(
    String title,
    VoidCallback onConfirm, {
    bool isDestructive = true,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: const Text('¿Estás seguro de realizar esta acción?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              onConfirm();
            },
            style: TextButton.styleFrom(
              foregroundColor: isDestructive ? Colors.red : Colors.green,
            ),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isGuest) {
      return Scaffold(
        appBar: AppBar(title: const Text('Coincidencias')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_outline, size: 60, color: Colors.grey[400]),
              const SizedBox(height: 20),
              const Text(
                'Inicia sesión para ver tus coincidencias',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Objetos Encontrados',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _matches.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _matches.length,
              itemBuilder: (context, index) {
                return _buildMatchCard(_matches[index]);
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.youtube_searched_for, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 20),
          Text(
            'No hay coincidencias aún',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            widget.viewerIsAdmin
                ? 'El sistema buscará automáticamente.'
                : 'Te avisaremos cuando encontremos tu objeto.',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchCard(MatchPair m) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          // Header del Match
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            decoration: const BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                const Icon(Icons.handshake, color: Colors.white),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    '¡COINCIDENCIA DETECTADA!',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                Text(
                  _formatearFechaCorta(m.matchedAt),
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sección de Comparación
                _buildComparisonRow(
                  icon: Icons.admin_panel_settings,
                  color: Colors.blueAccent,
                  label: "Encontrado por Admin",
                  title: m.adminReport.titulo,
                  subtitle:
                      m.adminReport.descripcion ?? 'Sin descripción adicional',
                  onInfo: () => _showDescriptionDialog(m.adminReport),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Divider(height: 1),
                ),
                _buildComparisonRow(
                  icon: Icons.person,
                  color: Colors.orangeAccent,
                  label: "Reportado por Usuario",
                  title: m.userReport.titulo,
                  subtitle: "ID Usuario: ${m.userReport.ownerId ?? 'Anon'}",
                ),

                const SizedBox(height: 20),

                // Botones de Acción
                if (widget.viewerIsAdmin)
                  _buildAdminActions(m)
                else
                  _buildUserActions(m),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonRow({
    required IconData icon,
    required Color color,
    required String label,
    required String title,
    required String subtitle,
    VoidCallback? onInfo,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        if (onInfo != null)
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.grey),
            onPressed: onInfo,
          ),
      ],
    );
  }

  Widget _buildAdminActions(MatchPair m) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            icon: const Icon(Icons.check_circle_outline),
            label: const Text('MARCAR COMO ENTREGADO / RECOGIDO'),
            onPressed: () => _markRecogido(m),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton.icon(
              icon: const Icon(Icons.delete_outline, size: 18),
              label: const Text('Borrar Admin Rep.'),
              style: TextButton.styleFrom(foregroundColor: Colors.red[300]),
              onPressed: () => _deleteAdminReport(m.adminReport),
            ),
            TextButton.icon(
              icon: const Icon(Icons.delete_outline, size: 18),
              label: const Text('Borrar Usu. Rep.'),
              style: TextButton.styleFrom(foregroundColor: Colors.red[300]),
              onPressed: () => _deleteUserReport(m.userReport),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUserActions(MatchPair m) {
    if (m.userReport.ownerId == widget.viewerId) {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.red,
            side: const BorderSide(color: Colors.red),
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          icon: const Icon(Icons.delete_forever),
          label: const Text('YA NO BUSCO ESTE OBJETO (ELIMINAR)'),
          onPressed: () => _deleteUserReport(m.userReport),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  void _showDescriptionDialog(Reportes r) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(r.titulo),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Descripción detallada:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(r.descripcion ?? 'Sin descripción disponible.'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  String _formatearFechaCorta(DateTime date) {
    return "${date.day}/${date.month} ${date.hour}:${date.minute.toString().padLeft(2, '0')}";
  }
}
