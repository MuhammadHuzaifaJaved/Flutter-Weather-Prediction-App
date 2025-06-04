import 'package:google_maps_flutter/google_maps_flutter.dart' as google_maps;
import 'package:latlong2/latlong.dart' as latlong2;

class LocationUtils {
  /// Convert from google_maps LatLng to latlong2 LatLng
  static latlong2.LatLng googleToLatLong2(google_maps.LatLng location) {
    return latlong2.LatLng(location.latitude, location.longitude);
  }

  /// Convert from latlong2 LatLng to google_maps LatLng
  static google_maps.LatLng latLong2ToGoogle(latlong2.LatLng location) {
    return google_maps.LatLng(location.latitude, location.longitude);
  }
} 