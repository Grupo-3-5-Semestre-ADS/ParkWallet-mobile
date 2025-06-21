import 'package:flutter/services.dart';

class MapStyleService {
  static String? _mapStyle;

  static Future<void> loadMapStyle() async {
    try {
      _mapStyle = await rootBundle.loadString('assets/map_style.json');
    } catch (e) {
      _mapStyle = null;
      print('Erro ao carregar estilo do mapa: $e');
    }
  }

  static String? get mapStyle => _mapStyle;
}