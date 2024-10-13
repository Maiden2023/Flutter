import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GoogleMapFlutter extends StatefulWidget {
  const GoogleMapFlutter({super.key});

  @override
  State<GoogleMapFlutter> createState() => _GoogleMapFlutterState();
}

class _GoogleMapFlutterState extends State<GoogleMapFlutter> {
  
  Set<Marker> _marcadores = {};
  List<Map<String, dynamic>> marcadoresGuardados = [];
  int maximoMarcadores = 5;

  @override
  void initState() {
    super.initState();
  }

  void _agregarMarcador(LatLng posicion) {
    if (_marcadores.length >= maximoMarcadores) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Has alcanzado el límite de $maximoMarcadores marcadores')),
      );
      return; 
    }

    setState(() {
      _marcadores.add(
        Marker(
          markerId: MarkerId(posicion.toString()),
          position: posicion,
          infoWindow: InfoWindow(
            title: 'Nuevo marcador',
            onTap: () {
              _agregarNombreMarcador(posicion);
            },
          ),
        ),
      );
    });
  }


  void _agregarNombreMarcador(LatLng posicion) {
  
    final marcadorExistente = marcadoresGuardados.firstWhere(
      (marcador) => marcador['lat'] == posicion.latitude && marcador['lng'] == posicion.longitude,
      orElse: () => {},
    );

    if (marcadorExistente != null && marcadorExistente['nombre'] != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Este marcador ya tiene un nombre')),
      );
      return;
    }

    TextEditingController controladorNombre = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Añadir nombre al marcador"),
          content: TextField(
            controller: controladorNombre,
            decoration: const InputDecoration(hintText: "Nombre del marcador"),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Guardar"),
              onPressed: () {
                setState(() {
                  marcadoresGuardados.add({
                    'nombre': controladorNombre.text,
                    'lat': posicion.latitude,
                    'lng': posicion.longitude,
                  });

                 
                  _marcadores = _marcadores.map((marcador) {
                    if (marcador.position == posicion) {
                      return marcador.copyWith(
                        infoWindowParam: InfoWindow(
                          title: controladorNombre.text,
                        ),
                      );
                    }
                    return marcador;
                  }).toSet();

                  Navigator.of(context).pop();
                });
              },
            ),
            TextButton(
              child: const Text("Cancelar"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }


  void _cambiarMaximoMarcadores() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController controladorMaximoMarcadores = TextEditingController();
        return AlertDialog(
          title: const Text("Cambiar el número máximo de marcadores"),
          content: TextField(
            controller: controladorMaximoMarcadores,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(hintText: "Número máximo de marcadores"),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Guardar"),
              onPressed: () {
                setState(() {
                  int? nuevoMaximo = int.tryParse(controladorMaximoMarcadores.text);
                  if (nuevoMaximo != null && nuevoMaximo > 0) {
                    maximoMarcadores = nuevoMaximo;
                  }
                  Navigator.of(context).pop();
                });
              },
            ),
            TextButton(
              child: const Text("Cancelar"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Google Map Flutter'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _cambiarMaximoMarcadores, 
            tooltip: 'Cambiar el número máximo de marcadores',
          ),
        ],
      ),
      body: GoogleMap(
        onTap: (LatLng posicion) {
          _agregarMarcador(posicion);
        },
        initialCameraPosition: CameraPosition(
          target: const LatLng(37.42796133580664, -122.085749655962), 
          zoom: 14.0,
        ),
        markers: _marcadores,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
         
          _mostrarMarcadoresGuardados();
        },
        child: const Icon(Icons.list),
        tooltip: 'Mostrar marcadores guardados',
      ),
    );
  }

  void _mostrarMarcadoresGuardados() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Marcadores guardados"),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              itemCount: marcadoresGuardados.length,
              itemBuilder: (context, index) {
                final marcador = marcadoresGuardados[index];
                return ListTile(
                  title: Text(marcador['nombre']),
                  subtitle: Text(
                      "Lat: ${marcador['lat']}, Lng: ${marcador['lng']}"),
                );
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Cerrar"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
