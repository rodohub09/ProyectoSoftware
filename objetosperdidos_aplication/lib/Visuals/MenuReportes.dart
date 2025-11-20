import 'package:flutter/material.dart';
import 'package:objetosperdidos_aplication/Models/Reportes.dart';
import 'package:objetosperdidos_aplication/Utils/enumFiltros.dart';
import 'package:objetosperdidos_aplication/Utils/tipoReporte.dart';
import 'package:objetosperdidos_aplication/Visuals/CrearReporte.dart';
import 'package:objetosperdidos_aplication/Visuals/DetallesReporte.dart';

class MenuReportes extends StatefulWidget {
  const MenuReportes({super.key});

  @override
  State<MenuReportes> createState() => _MenuReportesState();
}

class _MenuReportesState extends State<MenuReportes> {
  final List<Reportes> listaReportes = [];
  Enumfiltros? _filtroSeleccionado;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Menu de Reportes'), centerTitle: true),
      body: Center(
        child: Column(
          children: [
            _buildBuscaryFiltrar(),
            SizedBox(height: 10),
            Expanded(child: _buildReportList()),
            SizedBox(height: 10),
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

  Widget _buildCardReporte(Reportes reporte) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetallesReporte(reporte: reporte),
            ),
          );
        },
        child: Card(
          color: reporte.tipoReporte == Tiporeporte.perdido
              ? Colors.orangeAccent.shade100
              : Colors.blueAccent.shade100,
          elevation: 4.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reporte.titulo,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8.0),
                Text(
                  reporte.categoria.label,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 8.0),
                Text(
                  'Fecha: 2024-01-01',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Reportes> _aplicarFiltros() {
    final query = _controller.text.trim().toLowerCase();
    var reportes = ReportesManager().getAllReportes();

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
