import 'package:objetosperdidos_aplication/Utils/enumFiltros.dart';
import 'package:objetosperdidos_aplication/Utils/tipoReporte.dart';

class Reportes {
  final String titulo;
  final String descripcion; 
  final Enumfiltros categoria;
  final String subcategoria;
  final Tiporeporte tipoReporte;

  Reportes({
    required this.titulo,
    required this.descripcion,
    required this.categoria,
    required this.subcategoria,
    required this.tipoReporte,
  });
}

class ReportesManager {
  // Singleton
  static final ReportesManager _instance = ReportesManager._internal();
  factory ReportesManager() => _instance;
  ReportesManager._internal();

  final List<Reportes> _reportesPerdidos = [];
  final List<Reportes> _reportesEncontrados = [];

  List<Reportes> getAllReportes() {
    return _reportesPerdidos + _reportesEncontrados;
  }

  List<Reportes> getReportesPerdidos() {
    return _reportesPerdidos;
  }

  List<Reportes> getReportesEncontrados() {
    return _reportesEncontrados;
  }

  void addReportePerdido(Reportes reporte) {
    _reportesPerdidos.add(reporte);
  }

  void addReporteEncontrado(Reportes reporte) {
    _reportesEncontrados.add(reporte);
  }

  void removePerdido(Reportes reporte){
    _reportesPerdidos.remove(reporte);
  }

  void removeEncontrados(Reportes reporte){
    _reportesEncontrados.remove(reporte);
  }
}
