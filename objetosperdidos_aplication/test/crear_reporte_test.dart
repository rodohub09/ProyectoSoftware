import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:objetosperdidos_aplication/Visuals/CrearReporte.dart';
import 'package:objetosperdidos_aplication/Models/Reportes.dart';
import 'package:objetosperdidos_aplication/services/auth_service.dart';
import 'package:objetosperdidos_aplication/Utils/enumFiltros.dart'; 

class MockAuthService extends Mock implements AuthService {}
class MockReportesManager extends Mock implements ReportesManager {}
class FakeReportes extends Fake implements Reportes {}

void main() {
  late MockAuthService mockAuthService;
  late MockReportesManager mockReportesManager;

  setUpAll(() {
    registerFallbackValue(FakeReportes());
  });

  setUp(() {
    mockAuthService = MockAuthService();
    mockReportesManager = MockReportesManager();

    // Mocks por defecto
    when(() => mockAuthService.isCurrentUserAdmin()).thenAnswer((_) async => false);
    when(() => mockAuthService.getCurrentUserId()).thenAnswer((_) async => 'user_123');
    when(() => mockAuthService.isLoggedIn()).thenAnswer((_) async => true);
    when(() => mockReportesManager.addUserReport(any())).thenAnswer((_) async {});
  });

  testWidgets('Flujo Exitoso: Llenar y Guardar', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: CrearReporte(
        authService: mockAuthService,
        reportesManager: mockReportesManager,
      ),
    ));
    await tester.pumpAndSettle();

    // 2. Llenar Título
    await tester.enterText(find.byType(TextField).first, 'Mochila Azul');
    await tester.pump();

    // 3. Seleccionar Categoría 
    final categoriaEnum = Enumfiltros.values.first; 
    final nombreCategoria = categoriaEnum.label;
    
    final chipCategoria = find.text(nombreCategoria);
    await tester.ensureVisible(chipCategoria);
    await tester.tap(chipCategoria);
    await tester.pumpAndSettle(); 

    // 4. Seleccionar Subcategoría 
    final nombreSubcategoria = subfiltros[categoriaEnum]!.first;
    
    final chipSub = find.text(nombreSubcategoria);
    expect(chipSub, findsOneWidget, reason: "No se encontró el chip '$nombreSubcategoria'");
    
    await tester.ensureVisible(chipSub);
    await tester.tap(chipSub);
    await tester.pumpAndSettle();

    // 5. Presionar Guardar
    final botonGuardar = find.text('PUBLICAR REPORTE');
    await tester.ensureVisible(botonGuardar);
    await tester.tap(botonGuardar);

    // 6. Verificar SnackBar (Solo pump() para ver el mensaje efímero)
    await tester.pump(); 
    
    if (find.text('Por favor complete todos los campos requeridos.').evaluate().isNotEmpty) {
      fail("El test falló porque el formulario se consideró inválido.");
    }

    expect(find.text('¡Reporte creado exitosamente!'), findsOneWidget);

    // 7. Dejar que termine todo
    await tester.pumpAndSettle();
  });
}