import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:objetosperdidos_aplication/Models/Reportes.dart';
import 'package:objetosperdidos_aplication/Utils/enumFiltros.dart';
import 'package:objetosperdidos_aplication/Utils/tipoReporte.dart';

void main() {
  setUp(() {
    // Limpia SharedPreferences antes de cada test
    SharedPreferences.setMockInitialValues({});
  });

  test('MatchManager genera coincidencia cuando categoría/subcategoria y tipos correctos', () {
    final admin = Reportes(
      titulo: 'Llave Azul',
      descripcion: 'Llave con llavero azul',
      categoria: Enumfiltros.utiles,
      subcategoria: 'metal',
      tipoReporte: Tiporeporte.encontrado,
      ownerId: 'admin',
      ownerIsAdmin: true,
      createdAt: DateTime.now(),
    );

    final user = Reportes(
      titulo: 'Perdí mi llave',
      descripcion: null,
      categoria: Enumfiltros.utiles,
      subcategoria: 'metal',
      tipoReporte: Tiporeporte.perdido,
      ownerId: 'user1',
      ownerIsAdmin: false,
      createdAt: DateTime.now(),
    );

    // Añadimos los reportes
    ReportesManager().addAdminReport(admin);
    ReportesManager().addUserReport(user);

    final matches = ReportesManager().getAllMatches();
    expect(matches.length, 1);
    final pair = matches.first;
    expect(pair.adminReport.titulo, equals(admin.titulo));
    expect(pair.userReport.titulo, equals(user.titulo));

    // cleanup
    ReportesManager().removeAdminReport(admin);
    ReportesManager().removeUserReport(user);
  });
}
