import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapMarkerService {
  static final Map<String, BitmapDescriptor> _pinIcons = {};
  static final Map<String, BitmapDescriptor> _selectedPinIcons = {};
  static BitmapDescriptor _defaultPinIcon = BitmapDescriptor.defaultMarker;
  static BitmapDescriptor _defaultSelectedPinIcon = BitmapDescriptor.defaultMarker;

  static Future<void> initializeMarkerIcons() async {
    _pinIcons['store'] = await _getMarkerIconFromAsset('assets/images/pins/pin_store.png', width: 200);
    _pinIcons['attraction'] = await _getMarkerIconFromAsset('assets/images/pins/pin_attraction.png', width: 200);
    _pinIcons['other'] = await _getMarkerIconFromAsset('assets/images/pins/pin_other.png', width: 200);

    _selectedPinIcons['store'] = await _getMarkerIconFromAsset('assets/images/pins/pin_store_selected.png', width: 240);
    _selectedPinIcons['attraction'] = await _getMarkerIconFromAsset('assets/images/pins/pin_attraction_selected.png', width: 240);
    _selectedPinIcons['other'] = await _getMarkerIconFromAsset('assets/images/pins/pin_other_selected.png', width: 240);

    _defaultPinIcon = _pinIcons['other'] ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet);
    _defaultSelectedPinIcon = _selectedPinIcons['other'] ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow);
  }

  static BitmapDescriptor getMarkerIcon(String type, bool isSelected) {
    final iconType = type.toLowerCase().trim();
    if (isSelected) {
      return _selectedPinIcons[iconType] ?? _defaultSelectedPinIcon;
    } else {
      return _pinIcons[iconType] ?? _defaultPinIcon;
    }
  }

  static Future<BitmapDescriptor> _getMarkerIconFromAsset(String assetPath, {int width = 80}) async {
    try {
      final ByteData data = await rootBundle.load(assetPath);
      final ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width);
      final ui.FrameInfo fi = await codec.getNextFrame();
      final byteData = await fi.image.toByteData(format: ui.ImageByteFormat.png);
      return BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
    } catch (e) {
      print('Erro ao carregar imagem do marcador $assetPath: $e');
      if (assetPath.contains('pin_store')) {
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
      } else if (assetPath.contains('pin_attraction')) {
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
      } else {
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
      }
    }
  }
}