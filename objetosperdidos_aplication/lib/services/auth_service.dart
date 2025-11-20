import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _keyIsLoggedIn = 'isLoggedIn';
  static const String _keyUserId = 'userId';
  static const String _keyUserName = 'userName';
  static const String _keyUserEmail = 'userEmail';
  static const String _keyUserPassword = 'userPassword';
  static const String _keyUserRut = 'userRut';
  static const String _keyUsuariosDB = 'usuariosDB';

  // Leer usuarios desde SharedPreferences
  Future<Map<String, dynamic>> _leerUsuarios() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_keyUsuariosDB) ?? '{}';
      print('📖 JSON almacenado: $jsonString');
      
      if (jsonString.isEmpty || jsonString == '{}') {
        print('⚠️ No hay usuarios registrados (primera vez)');
        return {};
      }
      
      final usuarios = jsonDecode(jsonString) as Map<String, dynamic>;
      print('✓ Usuarios cargados: ${usuarios.length}');
      return usuarios;
    } catch (e) {
      print('✗ Error al leer usuarios: $e');
      return {};
    }
  }

  // Guardar usuarios en SharedPreferences
  Future<bool> _guardarUsuarios(Map<String, dynamic> usuarios) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(usuarios);
      print('💾 Guardando ${usuarios.length} usuarios...');
      print('JSON: $jsonString');
      await prefs.setString(_keyUsuariosDB, jsonString);
      print('✓ Usuarios guardados exitosamente');
      return true;
    } catch (e) {
      print('✗ Error al guardar usuarios: $e');
      return false;
    }
  }

  // REGISTRAR USUARIO - Usa MATRÍCULA como key única
  Future<bool> registrarUsuario({
    required String userId,
    required String userName,
    required String userEmail,
    required String password,
    required String rut,
  }) async {
    try {
      print('=== INICIO REGISTRO ===');
      print('Matrícula: $userId');
      print('Nombre: $userName');
      print('Email: $userEmail');
      print('RUT: $rut');
      
      Map<String, dynamic> usuarios = await _leerUsuarios();
      
      // Verificar si la MATRÍCULA ya existe
      if (usuarios.containsKey(userId)) {
        print('✗ La matrícula $userId ya está registrada');
        return false;
      }
      
      // Verificar si el userName ya existe (buscar en valores)
      for (var usuario in usuarios.values) {
        if (usuario['userName'] == userName) {
          print('✗ El nombre de usuario $userName ya está registrado');
          return false;
        }
      }
      
      print('✓ Usuario disponible, registrando...');
      
      usuarios[userId] = {
        'userName': userName,
        'password': password,
        'matricula': userId,
        'rut': rut,
        'correo': userEmail,
        'createdAt': DateTime.now().toIso8601String(),
      };
      
      // Guardar en SharedPreferences
      bool guardado = await _guardarUsuarios(usuarios);
      
      if (guardado) {
        await guardarSesion(
          userId: userId,
          userName: userName,
          userEmail: userEmail,
          userPassword: password,
          userRut: rut,
        );
        
        print('✓ Usuario registrado y sesión iniciada');
        return true;
      }
      
      return false;
    } catch (e) {
      print('✗ ERROR al registrar: $e');
      return false;
    }
  }

  // INICIAR SESIÓN - Busca por userName, valida password
  Future<Map<String, dynamic>> iniciarSesion({
    required String usuario,    // Puede ser userName o matrícula
    required String password,
  }) async {
    try {
      print('=== INICIO LOGIN ===');
      print('Usuario ingresado: $usuario');
      print('Password: ${password.length} caracteres');
      
      Map<String, dynamic> usuarios = await _leerUsuarios();
      print('Total usuarios en sistema: ${usuarios.length}');
      
      // Buscar usuario (puede buscar por matrícula o userName)
      String? matriculaEncontrada;
      Map<String, dynamic>? datosUsuario;
      
      // Primero buscar por matrícula (key directa)
      if (usuarios.containsKey(usuario)) {
        matriculaEncontrada = usuario;
        datosUsuario = usuarios[usuario];
        print('✓ Usuario encontrado por matrícula');
      } else {
        // Buscar por userName en todos los usuarios
        for (var entry in usuarios.entries) {
          if (entry.value['userName'] == usuario) {
            matriculaEncontrada = entry.key;
            datosUsuario = entry.value;
            print('✓ Usuario encontrado por nombre');
            break;
          }
        }
      }
      
      if (datosUsuario == null) {
        print('✗ Usuario no encontrado');
        return {
          'success': false,
          'message': 'Usuario no encontrado',
        };
      }
      
      // Validar contraseña
      if (datosUsuario['password'] == password) {
        print('✓ Contraseña correcta');
        
        await guardarSesion(
          userId: matriculaEncontrada!,
          userName: datosUsuario['userName'] ?? '',
          userEmail: datosUsuario['correo'] ?? '',
          userPassword: password,
          userRut: datosUsuario['rut'] ?? '',
        );

        print('✓ Login exitoso');
        return {
          'success': true,
          'message': 'Login exitoso',
          'user': datosUsuario,
        };
      } else {
        print('✗ Contraseña incorrecta');
        return {
          'success': false,
          'message': 'Contraseña incorrecta',
        };
      }
    } catch (e) {
      print('✗ ERROR en login: $e');
      return {
        'success': false,
        'message': 'Error al iniciar sesión: $e',
      };
    }
  }

  // Guardar sesión
  Future<void> guardarSesion({
    required String userId,
    required String userName,
    required String userEmail,
    required String userPassword,
    required String userRut,
  }) async {
    print('--- Guardando sesión ---');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, true);
    await prefs.setString(_keyUserId, userId);
    await prefs.setString(_keyUserName, userName);
    await prefs.setString(_keyUserEmail, userEmail);
    await prefs.setString(_keyUserPassword, userPassword);
    await prefs.setString(_keyUserRut, userRut);
    print('✓ Sesión guardada');
  }

  // Verificar sesión
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  // Obtener datos del usuario
  Future<Map<String, String?>> obtenerDatosUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'userId': prefs.getString(_keyUserId),
      'userName': prefs.getString(_keyUserName),
      'userEmail': prefs.getString(_keyUserEmail),
      'userPassword': prefs.getString(_keyUserPassword),
      'userRut': prefs.getString(_keyUserRut),
    };
  }

  // Cerrar sesión
  Future<void> logout() async {
    print('--- Cerrando sesión ---');
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyIsLoggedIn);
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyUserName);
    await prefs.remove(_keyUserEmail);
    await prefs.remove(_keyUserPassword);
    await prefs.remove(_keyUserRut);
    print('✓ Sesión cerrada');
  }
}