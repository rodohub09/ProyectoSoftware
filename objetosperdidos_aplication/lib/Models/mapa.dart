import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math' as math; // Necesario para la rotación

// 1. Modelo de datos para limpiar el código de marcadores
class LugarInteres {
  final String nombre;
  final LatLng ubicacion;
  final Color color;
  final String imagePath;

  LugarInteres({
    required this.nombre,
    required this.ubicacion,
    required this.color,
    required this.imagePath,
  });
}

class Mapa extends StatefulWidget {
  const Mapa({super.key});

  @override
  State<Mapa> createState() => _MapaState();
}

class _MapaState extends State<Mapa> {
  final MapController controller = MapController();
  LatLng? _miUbicacion;
  double _rotacionActual = -45.0; // Estado para guardar la rotación

  // Lista de lugares definida de forma limpia
  final List<LugarInteres> lugares = [
    LugarInteres(
      nombre: "Casa del Deporte",
      ubicacion: LatLng(-36.8265377, -73.0369129),
      color: Colors.purple,
      imagePath: 'assets/image/casa_del_deporte.jpg',
    ),
    LugarInteres(
      nombre: "Sistemas",
      ubicacion: LatLng(-36.8301516, -73.0366847),
      color: Colors.green,
      imagePath: 'assets/image/sistemas.jpg',
    ),
    LugarInteres(
      nombre: "Central",
      ubicacion: LatLng(-36.8319057, -73.0351986),
      color: Colors.red,
      imagePath: 'assets/image/central.jpg',
    ),
    LugarInteres(
      nombre: "Cubo 4",
      ubicacion: LatLng(-36.8333965, -73.0321043),
      color: Colors.blue,
      imagePath: 'assets/image/cubo4.jpg',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _irAmiUbicacion(moverMapa: true); // Solo obtener la data al inicio
  }

  Future<void> _irAmiUbicacion({bool moverMapa = true}) async {
    try {
      Position posicion = await determinarPosicion();
      LatLng nuevaPosicion = LatLng(posicion.latitude, posicion.longitude);
      
      if (!mounted) return; // Evita errores si cierras el mapa rápido

      setState(() {
        _miUbicacion = nuevaPosicion;
      });

      if (moverMapa) {
        // Mueve el mapa a tu ubicación
        controller.move(nuevaPosicion, 18); 
      }
    } catch (e) {
      debugPrint('Error obteniendo ubicación: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No pudimos encontrarte: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FlutterMap(
          mapController: controller,
          options: MapOptions(
            initialCenter: const LatLng(-36.8302959, -73.0345925),
            initialZoom: 16,
            initialRotation: _rotacionActual,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all,
            ),
            // 2. DETECTAR ROTACIÓN: Actualizamos el estado cuando el mapa se mueve/rota
            onPositionChanged: (camera, hasGesture) {
              if (camera.rotation != _rotacionActual) {
                setState(() {
                  _rotacionActual = camera.rotation;
                });
              }
            },
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.udec.objetosperdidos',
              additionalOptions: const {
                'User-Agent': 'ObjetosPerdidosUDEC/1.0',
              },
              maxZoom: 19,
              minZoom: 10,
            ),
            MarkerLayer(
              markers: [
                // Renderizamos los lugares de la lista
                ...lugares.map((lugar) => _buildMarker(lugar)),

                // Marcador de Mi Ubicación (Diferente estilo)
                if (_miUbicacion != null)
                  Marker(
                    point: _miUbicacion!,
                    width: 60,
                    height: 60,
                    // También aplicamos contra-rotación a este marcador
                    child: Transform.rotate(
                      angle: -_rotacionActual * (math.pi / 180),
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.all(4),
                            child: const Icon(
                              Icons.my_location,
                              color: Colors.blueAccent,
                              size: 30,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),

        Positioned(
          top: 50,
          right: 10,
          child: FloatingActionButton.small(
            heroTag: "compass",
            backgroundColor: Colors.white,
            onPressed: () {
              controller.rotate(0);
            },
            child: Transform.rotate(
              angle: _rotacionActual * (math.pi / 180),
              child: const Icon(Icons.navigation, color: Colors.red),
            ),
          ),
        ),

        // Botón Mi Ubicación
        Positioned(
          bottom: 140, // Un poco más arriba de los controles de zoom
          right: 10,
          child: FloatingActionButton(
            heroTag: "my_location",
            backgroundColor: Colors.white,
            child: const Icon(Icons.gps_fixed, color: Colors.black87),
            onPressed: () => _irAmiUbicacion(moverMapa: true),
          ),
        ),

        // Botones Zoom
        Positioned(
          bottom: 20,
          right: 10,
          child: Column(
            children: [
              FloatingActionButton.small(
                heroTag: "zoom_in",
                backgroundColor: Colors.white,
                child: const Icon(Icons.add, color: Colors.black87),
                onPressed: () {
                  controller.move(controller.camera.center, controller.camera.zoom + 1);
                },
              ),
              const SizedBox(height: 8),
              FloatingActionButton.small(
                heroTag: "zoom_out",
                backgroundColor: Colors.white,
                child: const Icon(Icons.remove, color: Colors.black87),
                onPressed: () {
                  controller.move(controller.camera.center, controller.camera.zoom - 1);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 3. Método constructor del marcador con Contra-Rotación
  Marker _buildMarker(LugarInteres lugar) {
    return Marker(
      point: lugar.ubicacion,
      width: 60,
      height: 70, // Un poco más alto para el texto
      child: GestureDetector(
        onTap: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(lugar.nombre),
                content: Image.asset(
                  lugar.imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => 
                    const Icon(Icons.image_not_supported, size: 50),
                ),
              );
            },
          );
        },
        // AQUI ESTA LA MAGIA: Transform.rotate
        // Negamos la rotación actual del mapa para que el icono se quede "quieto"
        child: Transform.rotate(
          angle: -_rotacionActual * (math.pi / 180),
          alignment: Alignment.center, 
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.location_pin,
                color: lugar.color,
                size: 50,
                shadows: const [
                  Shadow(blurRadius: 5, color: Colors.black45, offset: Offset(2, 2))
                ],
              ),
              // Texto opcional debajo del pin
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  lugar.nombre,
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ... La función determinarPosicion() se mantiene igual ...
Future<Position> determinarPosicion() async {
  bool servicioHabilitado;
  LocationPermission permiso;

  servicioHabilitado = await Geolocator.isLocationServiceEnabled();
  if (!servicioHabilitado) {
    return Future.error('El GPS está desactivado.');
  }

  permiso = await Geolocator.checkPermission();
  if (permiso == LocationPermission.denied) {
    permiso = await Geolocator.requestPermission();
    if (permiso == LocationPermission.denied) {
      return Future.error('Permiso de ubicación denegado.');
    }
  }

  if (permiso == LocationPermission.deniedForever) {
    return Future.error('Permisos denegados permanentemente.');
  }

  return await Geolocator.getCurrentPosition();
}