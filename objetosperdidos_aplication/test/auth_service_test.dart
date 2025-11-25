import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:objetosperdidos_aplication/services/auth_service.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('Registrar usuario e iniciar sesión funciona y persiste sesión', () async {
    final auth = AuthService();

    final registered = await auth.registrarUsuario(
      userId: 'u123',
      userName: 'usuarioTest',
      userEmail: 'test@example.com',
      password: 'pass123',
      rut: '12345678-9',
      isAdmin: false,
    );

    expect(registered, isTrue);

    final login = await auth.iniciarSesion(usuario: 'u123', password: 'pass123');
    expect(login['success'], isTrue);

    final logged = await auth.isLoggedIn();
    expect(logged, isTrue);

    await auth.logout();
    final loggedAfter = await auth.isLoggedIn();
    expect(loggedAfter, isFalse);
  });
}
