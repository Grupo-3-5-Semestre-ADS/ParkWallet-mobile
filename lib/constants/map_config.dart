import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapConfig {
  // Limites do parque
  static const double _northBound = -25.1480;
  static const double _southBound = -25.1680;
  static const double _eastBound = -54.2900;
  static const double _westBound = -54.3100;

  static const LatLng parkSouthwest = LatLng(_southBound, _westBound);
  static const LatLng parkNortheast = LatLng(_northBound, _eastBound);
  static const LatLng parkCenter = LatLng(-25.159346, -54.299943);

  static const double minZoom = 16.0;
  static const double maxZoom = 20.0;
  static const double defaultZoom = 18.0;
  static const double focusZoom = 19.0;

  static CameraPosition getDefaultCameraPosition() {
    return CameraPosition(target: parkCenter, zoom: defaultZoom);
  }

  static CameraPosition getFocusedCameraPosition(double lat, double lng) {
    return CameraPosition(target: LatLng(lat, lng), zoom: focusZoom);
  }

  static LatLngBounds getCameraBounds() {
    return LatLngBounds(southwest: parkSouthwest, northeast: parkNortheast);
  }

  static MinMaxZoomPreference getZoomPreference() {
    return const MinMaxZoomPreference(minZoom, maxZoom);
  }
}