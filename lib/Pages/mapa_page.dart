// ignore_for_file: unused_field

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapaPage extends StatefulWidget {
  final double latitude;
  final double longitude;

  const MapaPage({
    Key? key,
    required this.latitude,
    required this.longitude,
  }) : super(key: key);

  @override
  State<MapaPage> createState() => _MapaPageState();
}

class _MapaPageState extends State<MapaPage> {
  late GoogleMapController _controller;

  @override
  Widget build(BuildContext context) {
    final LatLng posicao = LatLng(widget.latitude, widget.longitude);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mapa - Localização"),
        backgroundColor: Colors.blueAccent,
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: posicao,
          zoom: 16,
        ),
        markers: {
          Marker(
            markerId: const MarkerId("local"),
            position: posicao,
            infoWindow: const InfoWindow(title: "Local Encontrado"),
          ),
        },
        onMapCreated: (controller) {
          _controller = controller;
        },
      ),
    );
  }
}
