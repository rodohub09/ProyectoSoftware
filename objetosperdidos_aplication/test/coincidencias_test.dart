import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:objetosperdidos_aplication/Models/Reportes.dart';
import 'package:objetosperdidos_aplication/Utils/enumFiltros.dart';
import 'package:objetosperdidos_aplication/Utils/tipoReporte.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('MatchPair', () {
    test('Crear una coincidencia con reportes admin y usuario', () {
      final adminReport = Reportes(
        titulo: 'Tablet encontrada',
        descripcion: 'Tablet HP en sala 301',
        categoria: Enumfiltros.tecnologia,
        subcategoria: 'Tablet',
        tipoReporte: Tiporeporte.encontrado,
        ownerId: 'admin1',
        ownerIsAdmin: true,
        createdAt: DateTime.now(),
      );

      final userReport = Reportes(
        titulo: 'Perdí mi tablet',
        categoria: Enumfiltros.tecnologia,
        subcategoria: 'Tablet',
        tipoReporte: Tiporeporte.perdido,
        ownerId: 'user123',
        ownerIsAdmin: false,
        createdAt: DateTime.now(),
      );

      final match = MatchPair(adminReport: adminReport, userReport: userReport);

      expect(match.adminReport, equals(adminReport));
      expect(match.userReport, equals(userReport));
      expect(match.matchedAt, isNotNull);
    });

    test('Dos coincidencias con los mismos reportes deben ser iguales', () {
      final adminReport = Reportes(
        titulo: 'Mochila encontrada',
        categoria: Enumfiltros.miscelaneos,
        subcategoria: 'Mochila',
        tipoReporte: Tiporeporte.encontrado,
        ownerId: 'admin1',
        ownerIsAdmin: true,
        createdAt: DateTime.now(),
      );

      final userReport = Reportes(
        titulo: 'Perdí mi mochila',
        categoria: Enumfiltros.miscelaneos,
        subcategoria: 'Mochila',
        tipoReporte: Tiporeporte.perdido,
        ownerId: 'user456',
        ownerIsAdmin: false,
        createdAt: DateTime.now(),
      );

      final match1 = MatchPair(
        adminReport: adminReport,
        userReport: userReport,
      );
      final match2 = MatchPair(
        adminReport: adminReport,
        userReport: userReport,
      );

      expect(match1, equals(match2));
      expect(match1.hashCode, equals(match2.hashCode));
    });
  });

  group('MatchManager', () {
    late MatchManager matchManager;

    setUp(() {
      matchManager = MatchManager();
      // Limpiar coincidencias previas
      final allMatches = matchManager.getAllMatches();
      for (var match in allMatches.toList()) {
        matchManager.removeMatchPair(match);
      }
    });

    test('getAllMatches devuelve lista inmutable', () {
      final matches = matchManager.getAllMatches();
      expect(matches, isA<List<MatchPair>>());
    });

    test('checkAndAddMatchesForAdmin agrega coincidencia cuando hay match', () {
      final adminReport = Reportes(
        titulo: 'Celular encontrado',
        descripcion: 'iPhone 12 en biblioteca',
        categoria: Enumfiltros.tecnologia,
        subcategoria: 'Celular',
        tipoReporte: Tiporeporte.encontrado,
        ownerId: 'admin1',
        ownerIsAdmin: true,
        createdAt: DateTime.now(),
      );

      final userReport = Reportes(
        titulo: 'Perdí mi celular',
        categoria: Enumfiltros.tecnologia,
        subcategoria: 'Celular',
        tipoReporte: Tiporeporte.perdido,
        ownerId: 'user789',
        ownerIsAdmin: false,
        createdAt: DateTime.now(),
      );

      matchManager.checkAndAddMatchesForAdmin(adminReport, [userReport]);

      final matches = matchManager.getAllMatches();
      expect(matches.length, equals(1));
      expect(matches.first.adminReport, equals(adminReport));
      expect(matches.first.userReport, equals(userReport));
    });

    test('No crea coincidencia si categorías son diferentes', () {
      final adminReport = Reportes(
        titulo: 'Reloj encontrado',
        categoria: Enumfiltros.accesorios,
        subcategoria: 'Reloj',
        tipoReporte: Tiporeporte.encontrado,
        ownerId: 'admin1',
        ownerIsAdmin: true,
        createdAt: DateTime.now(),
      );

      final userReport = Reportes(
        titulo: 'Perdí mi celular',
        categoria: Enumfiltros.tecnologia,
        subcategoria: 'Celular',
        tipoReporte: Tiporeporte.perdido,
        ownerId: 'user123',
        ownerIsAdmin: false,
        createdAt: DateTime.now(),
      );

      matchManager.checkAndAddMatchesForAdmin(adminReport, [userReport]);

      final matches = matchManager.getAllMatches();
      expect(matches.length, equals(0));
    });

    test('No crea coincidencia si subcategorías son diferentes', () {
      final adminReport = Reportes(
        titulo: 'Cargador encontrado',
        categoria: Enumfiltros.tecnologia,
        subcategoria: 'Cargador',
        tipoReporte: Tiporeporte.encontrado,
        ownerId: 'admin1',
        ownerIsAdmin: true,
        createdAt: DateTime.now(),
      );

      final userReport = Reportes(
        titulo: 'Perdí audífonos',
        categoria: Enumfiltros.tecnologia,
        subcategoria: 'Audífono',
        tipoReporte: Tiporeporte.perdido,
        ownerId: 'user123',
        ownerIsAdmin: false,
        createdAt: DateTime.now(),
      );

      matchManager.checkAndAddMatchesForAdmin(adminReport, [userReport]);

      final matches = matchManager.getAllMatches();
      expect(matches.length, equals(0));
    });

    test('No agrega coincidencias duplicadas', () {
      final adminReport = Reportes(
        titulo: 'Tablet encontrada',
        categoria: Enumfiltros.tecnologia,
        subcategoria: 'Tablet',
        tipoReporte: Tiporeporte.encontrado,
        ownerId: 'admin1',
        ownerIsAdmin: true,
        createdAt: DateTime.now(),
      );

      final userReport = Reportes(
        titulo: 'Perdí tablet',
        categoria: Enumfiltros.tecnologia,
        subcategoria: 'Tablet',
        tipoReporte: Tiporeporte.perdido,
        ownerId: 'user1',
        ownerIsAdmin: false,
        createdAt: DateTime.now(),
      );

      matchManager.checkAndAddMatchesForAdmin(adminReport, [userReport]);
      matchManager.checkAndAddMatchesForAdmin(adminReport, [userReport]);

      expect(matchManager.getAllMatches().length, equals(1));
    });
  });

  group('ReportesManager - Coincidencias', () {
    late ReportesManager reportesManager;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      reportesManager = ReportesManager();
      // Limpiar reportes previos
      await Future.delayed(Duration(milliseconds: 100)); // Esperar carga
      for (var report in reportesManager.getAdminReports().toList()) {
        reportesManager.removeAdminReport(report);
      }
      for (var report in reportesManager.getUserReports().toList()) {
        reportesManager.removeUserReport(report);
      }
    });

    test(
      'addAdminReport crea coincidencias con reportes de usuario existentes',
      () async {
        final userReport = Reportes(
          titulo: 'Perdí mi gorro',
          categoria: Enumfiltros.accesorios,
          subcategoria: 'Gorro',
          tipoReporte: Tiporeporte.perdido,
          ownerId: 'user1',
          ownerIsAdmin: false,
          createdAt: DateTime.now(),
        );

        reportesManager.addUserReport(userReport);
        await Future.delayed(Duration(milliseconds: 50));

        final matchesBeforeAdmin = reportesManager.getAllMatches().length;

        final adminReport = Reportes(
          titulo: 'Gorro encontrado',
          descripcion: 'Gorro rojo en cafetería',
          categoria: Enumfiltros.accesorios,
          subcategoria: 'Gorro',
          tipoReporte: Tiporeporte.encontrado,
          ownerId: 'admin1',
          ownerIsAdmin: true,
          createdAt: DateTime.now(),
        );

        reportesManager.addAdminReport(adminReport);
        await Future.delayed(Duration(milliseconds: 50));

        expect(
          reportesManager.getAllMatches().length,
          equals(matchesBeforeAdmin + 1),
        );
      },
    );

    test(
      'markMatchAsRecogido marca como recogido y elimina reportes y coincidencia',
      () async {
        final adminReport = Reportes(
          titulo: 'Pulsera encontrada',
          descripcion: 'Pulsera de plata',
          categoria: Enumfiltros.accesorios,
          subcategoria: 'Pulsera',
          tipoReporte: Tiporeporte.encontrado,
          ownerId: 'admin1',
          ownerIsAdmin: true,
          createdAt: DateTime.now(),
        );

        final userReport = Reportes(
          titulo: 'Perdí pulsera',
          categoria: Enumfiltros.accesorios,
          subcategoria: 'Pulsera',
          tipoReporte: Tiporeporte.perdido,
          ownerId: 'user1',
          ownerIsAdmin: false,
          createdAt: DateTime.now(),
        );

        reportesManager.addAdminReport(adminReport);
        reportesManager.addUserReport(userReport);
        await Future.delayed(Duration(milliseconds: 50));

        final matchesBeforeMark = reportesManager.getAllMatches().length;
        final matches = reportesManager.getAllMatches();
        expect(matches.length, greaterThan(0));
        final match = matches.firstWhere(
          (m) => m.adminReport == adminReport && m.userReport == userReport,
        );
        reportesManager.markMatchAsRecogido(match);
        await Future.delayed(Duration(milliseconds: 50));

        expect(adminReport.recogido, isTrue);
        expect(
          reportesManager.getAllMatches().length,
          equals(matchesBeforeMark - 1),
        );
        expect(reportesManager.getAdminReports(), isNot(contains(adminReport)));
        expect(reportesManager.getUserReports(), isNot(contains(userReport)));
      },
    );
  });
}
