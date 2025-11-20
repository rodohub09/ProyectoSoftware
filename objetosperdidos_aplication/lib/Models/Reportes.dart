import 'package:objetosperdidos_aplication/Utils/enumFiltros.dart';
import 'package:objetosperdidos_aplication/Utils/tipoReporte.dart';

class Reportes {
  final String titulo;
  final String descripcion; 
  final Enumfiltros categoria;
  final Tiporeporte tipoReporte;

  Reportes({
    required this.titulo,
    required this.descripcion,
    required this.categoria,
    required this.tipoReporte,
  });
}

class ReportesManager {
  // Singleton
  static final ReportesManager _instance = ReportesManager._internal();
  factory ReportesManager() => _instance;
  ReportesManager._internal();

  final List<Reportes> _reportes = [];

  List<Reportes> getAllReportes() {
    return _reportes;
  }

  void addReporte(Reportes reporte) {
    _reportes.add(reporte);
  }

  void removeEquipo(Reportes reporte){
    _reportes.remove(reporte);
  }
}