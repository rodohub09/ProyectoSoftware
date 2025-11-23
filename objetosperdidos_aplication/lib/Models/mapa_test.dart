import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
class Mapa extends StatefulWidget {
  const Mapa({super.key});

  @override
  State<Mapa> createState() => _MapaState();
}

class _MapaState extends State<Mapa> { 
  final MapController controller = MapController();
  LatLng? _miUbicacion;
  void initState() {
    super.initState();
    _irAmiUbicacion();
  }

  Future<void> _irAmiUbicacion() async {
    try {
      // Llamamos a la función que creamos arriba
      Position posicion = await determinarPosicion();

      // Creamos el objeto LatLng
      LatLng nuevaPosicion = LatLng(posicion.latitude, posicion.longitude);

      setState(() {
        _miUbicacion = nuevaPosicion;
      });
    } catch (e) {
      print('Error: $e'); // Manejar el error (ej: mostrar SnackBar)
    }
  }
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FlutterMap(
          mapController: controller,
          options: MapOptions(
            initialCenter: LatLng(-36.8302959, -73.0345925),
            initialZoom: 17,
            initialRotation: -45.0,
            // 👇 Habilitar zoom y gestos (sirve para Android/Web/Windows)
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all, // zoom, drag, scroll, etc.
            ),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.app',
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: LatLng(
                    -36.826537707893756,
                    -73.036912958654,
                  ), // Casa del deporte
                  width: 50, // Ancho del área del marcador
                  height: 50, // Alto del área del marcador
                  child: const Icon(
                    Icons.location_pin, // El icono de bandera de Flutter
                    color: Colors.yellow, // Color rojo
                    size: 50, // Tamaño del icono
                  ),
                ),
                Marker(
                  point: LatLng(-36.8301516, -73.0366847), // Sistemas
                  width: 50, // Ancho del área del marcador
                  height: 50, // Alto del área del marcador
                  child: const Icon(
                    Icons.location_pin, // El icono de bandera de Flutter
                    color: Colors.green, // Color rojo
                    size: 50, // Tamaño del icono
                  ),
                ),
                Marker(
                  point: LatLng(-36.8319057, -73.0351986), // Central
                  width: 50, // Ancho del área del marcador
                  height: 50, // Alto del área del marcador
                  child: const Icon(
                    Icons.location_pin, // El icono de bandera de Flutter
                    color: Colors.red, // Color rojo
                    size: 50, // Tamaño del icono
                  ),
                ),
                Marker(
                  point: LatLng(
                    -36.833396545811134,
                    -73.03210433088138,
                  ), // Cubo 4
                  width: 50,
                  height: 50, 
                  child: const Icon(
                    Icons.location_pin,
                    color: Colors.blue, 
                    size: 50, 
                  ),
                ),
                if (_miUbicacion != null)
                Marker(
                  point: _miUbicacion!,
                  width: 50, 
                  height: 50, 
                  child: const Icon(
                    Icons.person_pin_circle_outlined, 
                    color: Colors.black, 
                    size: 50, 
                  ),
                ),
              ],
            ),
          ],
        ),

        // Botón de zoom IN
        Positioned(
          right: 10,
          bottom: 70,
          child: FloatingActionButton(
            heroTag: "zoom_in",
            onPressed: () {
              controller.move(
                controller.camera.center,
                controller.camera.zoom + 1,
              );
            },
            child: const Icon(Icons.zoom_in),
          ),
        ),

        // Botón de zoom OUT
        Positioned(
          right: 10,
          bottom: 10,
          child: FloatingActionButton(
            heroTag: "zoom_out",
            onPressed: () {
              controller.move(
                controller.camera.center,
                controller.camera.zoom - 1,
              );
            },
            child: const Icon(Icons.zoom_out),
          ),
        ),
      ],
    );
  }
}


Future<Position> determinarPosicion() async {
  bool servicioHabilitado;
  LocationPermission permiso;

  // 1. Verificar si el GPS está prendido
  servicioHabilitado = await Geolocator.isLocationServiceEnabled();
  if (!servicioHabilitado) {
    return Future.error('El GPS está desactivado.');
  }

  // 2. Verificar permisos
  permiso = await Geolocator.checkPermission();
  if (permiso == LocationPermission.denied) {
    permiso = await Geolocator.requestPermission();
    if (permiso == LocationPermission.denied) {
      return Future.error('Permiso de ubicación denegado.');
    }
  }

  if (permiso == LocationPermission.deniedForever) {
    return Future.error('Permisos denegados permanentemente, ve a ajustes.');
  }

  // 3. ¡Si llegamos aquí, tenemos permiso! Obtenemos la ubicación
  return await Geolocator.getCurrentPosition();
}



void main() {
  runApp(const MaterialApp(home: Scaffold(body: Mapa())));
}
