import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlong2;
import '../config/api_config.dart';
import '../utils/location_utils.dart';

class WeatherMapsScreen extends StatefulWidget {
  const WeatherMapsScreen({Key? key}) : super(key: key);

  @override
  _WeatherMapsScreenState createState() => _WeatherMapsScreenState();
}

class _WeatherMapsScreenState extends State<WeatherMapsScreen> {
  String selectedMapType = 'temp_new';
  final MapController mapController = MapController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather Maps'),
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildMapTypeButton('Temperature', 'temp_new'),
                  _buildMapTypeButton('Precipitation', 'precipitation_new'),
                  _buildMapTypeButton('Wind', 'wind_new'),
                  _buildMapTypeButton('Pressure', 'pressure_new'),
                  _buildMapTypeButton('Clouds', 'clouds_new'),
                ],
              ),
            ),
          ),
          Expanded(
            child: FlutterMap(
              mapController: mapController,
              options: const MapOptions(
                initialCenter: latlong2.LatLng(0, 0),
                initialZoom: 3,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.app',
                ),
                // Add weather overlay layer based on selectedMapType
                TileLayer(
                  urlTemplate:
                      '${ApiConfig.weatherMapBaseUrl}/$selectedMapType/{z}/{x}/{y}.png?appid=${ApiConfig.weatherMapApiKey}',
                  userAgentPackageName: 'com.example.app',
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildControlButton(Icons.remove, () {
                  final currentZoom = mapController.zoom;
                  mapController.move(
                    mapController.center,
                    currentZoom - 1,
                  );
                }),
                _buildControlButton(Icons.add, () {
                  final currentZoom = mapController.zoom;
                  mapController.move(
                    mapController.center,
                    currentZoom + 1,
                  );
                }),
                _buildControlButton(Icons.my_location, () {
                  // Get current location and center map
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapTypeButton(String label, String type) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            selectedMapType = type;
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: selectedMapType == type
              ? Theme.of(context).primaryColor
              : Colors.grey[300],
        ),
        child: Text(label),
      ),
    );
  }

  Widget _buildControlButton(IconData icon, VoidCallback onPressed) {
    return FloatingActionButton(
      mini: true,
      onPressed: onPressed,
      child: Icon(icon),
    );
  }
} 