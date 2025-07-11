// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GeocodeData {
  String name;
  LatLng latLng;
  
  GeocodeData({
    required this.name,
    required this.latLng,
  });

  factory GeocodeData.fromJson(Map<String, dynamic> json) {
    return GeocodeData(
      name: json['name'] as String,
      latLng: LatLng(
        (json['lat'] as num).toDouble(),
        (json['lon'] as num).toDouble(),
      ),
    );
  }
}
