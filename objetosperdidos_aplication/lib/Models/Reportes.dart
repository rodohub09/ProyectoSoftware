import 'package:objetosperdidos_aplication/Utils/enumFiltros.dart';
import 'package:objetosperdidos_aplication/Utils/tipoReporte.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:objetosperdidos_aplication/services/notification_service.dart';

class Reportes {
  final String titulo;
  final String? descripcion; // puede ser null para reportes de usuario
  final Enumfiltros categoria;
  final String subcategoria;
  final Tiporeporte tipoReporte;
  final String? ownerId; // matrícula o id del creador
  final bool ownerIsAdmin; // true si fue creado por admin
  bool recogido; // si el reporte fue declarado recogido
  final DateTime createdAt;

  Reportes({
    required this.titulo,
    this.descripcion,
    required this.categoria,
    required this.subcategoria,
    required this.tipoReporte,
    this.ownerId,
    this.ownerIsAdmin = false,
    this.recogido = false,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'titulo': titulo,
      'descripcion': descripcion,
      'categoria': categoria.index,
      'subcategoria': subcategoria,
      'tipoReporte': tipoReporte.index,
      'ownerId': ownerId,
      'ownerIsAdmin': ownerIsAdmin,
      'recogido': recogido,
      'fecha_creacion': createdAt.toIso8601String(),
    };
  }

  factory Reportes.fromJson(Map<String, dynamic> map) {
    // Compatibilidad con formato antiguo (creadoEn) y nuevo (fecha_creacion)
    final fechaString = map['fecha_creacion'] ?? map['creadoEn'];
    final fecha = fechaString != null
        ? DateTime.parse(fechaString as String)
        : DateTime.now(); // Fallback si no existe ningún campo de fecha

    return Reportes(
      titulo: map['titulo'] ?? '',
      descripcion: map['descripcion'],
      categoria: Enumfiltros.values[(map['categoria'] as int?) ?? 0],
      subcategoria: map['subcategoria'] ?? '',
      tipoReporte: Tiporeporte.values[(map['tipoReporte'] as int?) ?? 0],
      ownerId: map['ownerId'],
      ownerIsAdmin: map['ownerIsAdmin'] == true,
      recogido: map['recogido'] == true,
      createdAt: fecha,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Reportes &&
        other.titulo == titulo &&
        other.descripcion == descripcion &&
        other.categoria == categoria &&
        other.subcategoria == subcategoria &&
        other.tipoReporte == tipoReporte &&
        other.ownerId == ownerId &&
        other.ownerIsAdmin == ownerIsAdmin;
  }

  @override
  int get hashCode =>
      titulo.hashCode ^
      (descripcion?.hashCode ?? 0) ^
      categoria.hashCode ^
      subcategoria.hashCode ^
      tipoReporte.hashCode ^
      (ownerId?.hashCode ?? 0) ^
      ownerIsAdmin.hashCode;
}

class MatchPair {
  final Reportes adminReport;
  final Reportes userReport;
  final DateTime matchedAt;

  MatchPair({required this.adminReport, required this.userReport})
    : matchedAt = DateTime.now();

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MatchPair &&
        other.adminReport == adminReport &&
        other.userReport == userReport;
  }

  @override
  int get hashCode => adminReport.hashCode ^ userReport.hashCode;
}

class MatchManager {
  MatchManager._internal();
  static final MatchManager _instance = MatchManager._internal();
  factory MatchManager() => _instance;

  final List<MatchPair> _matches = [];

  List<MatchPair> getAllMatches() => List.unmodifiable(_matches);

  void removeMatchesWithAdmin(Reportes adminRep) {
    _matches.removeWhere((m) => m.adminReport == adminRep);
  }

  void removeMatchesWithUser(Reportes userRep) {
    _matches.removeWhere((m) => m.userReport == userRep);
  }

  void removeMatchPair(MatchPair pair) {
    _matches.remove(pair);
  }

  void _addMatch(MatchPair pair) {
    if (!_matches.contains(pair)) {
      _matches.add(pair);
      NotificationService().notify('Coincidencia: ${pair.adminReport.titulo}');
      print(
        '🔎 Nueva coincidencia detectada: admin="${pair.adminReport.titulo}" user="${pair.userReport.titulo}"',
      );
    }
  }

  bool _isMatch(Reportes adminRep, Reportes userRep) {
    final sameCategory =
        adminRep.categoria == userRep.categoria &&
        adminRep.subcategoria == userRep.subcategoria;
    // Match only when admin report is 'encontrado' and user report is 'perdido',
    // and the admin report was actually created by an admin
    final correctTypes =
        adminRep.tipoReporte == Tiporeporte.encontrado &&
        userRep.tipoReporte == Tiporeporte.perdido &&
        adminRep.ownerIsAdmin == true &&
        userRep.ownerIsAdmin == false;
    final match = sameCategory && correctTypes;
    if (match) {
      print(
        'Coinciden: categoria ${adminRep.categoria}, sub ${adminRep.subcategoria} (admin: "${adminRep.titulo}", usuario: "${userRep.titulo}")',
      );
    } else {
      print(
        'No coinciden: admin="${adminRep.titulo}" vs usuario="${userRep.titulo}"',
      );
    }
    return match;
  }

  void checkAndAddMatchesForAdmin(
    Reportes adminRep,
    List<Reportes> userReports,
  ) {
    for (var u in userReports) {
      if (_isMatch(adminRep, u)) {
        _addMatch(MatchPair(adminReport: adminRep, userReport: u));
      }
    }
  }

  void checkAndAddMatchesForUser(
    Reportes userRep,
    List<Reportes> adminReports,
  ) {
    for (var a in adminReports) {
      if (_isMatch(a, userRep)) {
        _addMatch(MatchPair(adminReport: a, userReport: userRep));
      }
    }
  }
}

class ReportesManager {
  // Singleton
  static final ReportesManager _instance = ReportesManager._internal();
  factory ReportesManager() => _instance;
  ReportesManager._internal() {
    // Cargar reportes desde almacenamiento cuando se construye el singleton
    _loadFromStorage();
  }

  // Reportes creados por usuarios (no visibles públicamente por defecto)
  final List<Reportes> _reportesUsuarios = [];
  // Reportes creados por admins (visibles)
  final List<Reportes> _reportesAdmin = [];

  // MATCH MANAGER
  final MatchManager _matchManager = MatchManager();

  // Agregar reporte creado por un usuario registrado (sin descripción)
  void addUserReport(Reportes reporte) {
    _reportesUsuarios.add(reporte);
    print(
      '➕ Reporte de usuario agregado: ${reporte.titulo} (owner=${reporte.ownerId})',
    );
    NotificationService().notify(
      'Reporte de usuario creado: ${reporte.titulo}',
    );
    // Chequear coincidencias contra reportes admin
    _matchManager.checkAndAddMatchesForUser(reporte, _reportesAdmin);
    _saveToStorage();
  }

  // Agregar reporte creado por admin (con descripción opcional)
  void addAdminReport(Reportes reporte) {
    _reportesAdmin.add(reporte);
    print(
      '➕ Reporte admin agregado: ${reporte.titulo} (owner=${reporte.ownerId})',
    );
    NotificationService().notify('Reporte admin creado: ${reporte.titulo}');
    // Chequear coincidencias contra reportes de usuarios
    _matchManager.checkAndAddMatchesForAdmin(reporte, _reportesUsuarios);
    _saveToStorage();
  }

  List<Reportes> getUserReports() => List.unmodifiable(_reportesUsuarios);
  List<Reportes> getAdminReports() => List.unmodifiable(_reportesAdmin);

  List<Reportes> getUserReportsByOwner(String? ownerId) {
    if (ownerId == null) return [];
    return _reportesUsuarios.where((r) => r.ownerId == ownerId).toList();
  }

  // Devuelve los reportes visibles para quien consulta
  List<Reportes> getVisibleReports({
    String? viewerId,
    bool viewerIsAdmin = false,
    bool adminWantsToSeeUserReports = true,
  }) {
    // Admin: puede ver admin reports y (opcionalmente) user reports
    if (viewerIsAdmin) {
      if (adminWantsToSeeUserReports) {
        return List.unmodifiable([..._reportesAdmin, ..._reportesUsuarios]);
      } else {
        return List.unmodifiable(_reportesAdmin);
      }
    }

    // Usuario: puede ver admin reports + sus propios user reports
    final visible = <Reportes>[];
    visible.addAll(_reportesAdmin);
    if (viewerId != null) {
      visible.addAll(_reportesUsuarios.where((r) => r.ownerId == viewerId));
    }
    return List.unmodifiable(visible);
  }

  void removeUserReport(Reportes reporte) {
    _reportesUsuarios.remove(reporte);
    _matchManager.removeMatchesWithUser(reporte);
    _saveToStorage();
  }

  void removeAdminReport(Reportes reporte) {
    _reportesAdmin.remove(reporte);
    _matchManager.removeMatchesWithAdmin(reporte);
    _saveToStorage();
  }

  List<MatchPair> getAllMatches() => _matchManager.getAllMatches();

  // Marcar como recogido y eliminar ambos reportes de la pareja
  void markMatchAsRecogido(MatchPair match) {
    // Marcar el reporte admin como recogido
    match.adminReport.recogido = true;
    // Eliminar ambos reportes de las listas
    _reportesAdmin.remove(match.adminReport);
    _reportesUsuarios.remove(match.userReport);
    // Eliminar la pareja de matches
    _matchManager.removeMatchPair(match);
    _saveToStorage();
    NotificationService().notify(
      'Objeto marcado como recogido y reportes eliminados',
    );
  }

  // Persistence
  static const String _keyReportesDB = 'reportesDB';

  Future<void> _saveToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = {
        'admins': _reportesAdmin.map((r) => r.toJson()).toList(),
        'users': _reportesUsuarios.map((r) => r.toJson()).toList(),
      };
      await prefs.setString(_keyReportesDB, jsonEncode(data));
      print(' Reportes guardados');
    } catch (e) {
      print('Error guardando reportes: $e');
    }
  }

  Future<void> _loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_keyReportesDB) ?? '';
      if (jsonString.isEmpty) return;
      final data = jsonDecode(jsonString) as Map<String, dynamic>;
      final admins = (data['admins'] as List<dynamic>?) ?? [];
      final users = (data['users'] as List<dynamic>?) ?? [];
      _reportesAdmin.clear();
      _reportesUsuarios.clear();
      for (var a in admins) {
        _reportesAdmin.add(Reportes.fromJson(Map<String, dynamic>.from(a)));
      }
      for (var u in users) {
        _reportesUsuarios.add(Reportes.fromJson(Map<String, dynamic>.from(u)));
      }
      // Recompute matches
      for (var admin in _reportesAdmin) {
        _matchManager.checkAndAddMatchesForAdmin(admin, _reportesUsuarios);
      }
      print(
        'Reportes cargados: ${_reportesAdmin.length} admins, ${_reportesUsuarios.length} users',
      );
    } catch (e) {
      print('Error cargando reportes: $e');
    }
  }

  // Public helper to persist current in-memory state (useful after mutating a Reportes instance)
  Future<void> updateReport(Reportes reporte) async {
    await _saveToStorage();
  }
}
