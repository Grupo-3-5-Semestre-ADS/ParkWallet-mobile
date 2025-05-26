// map_controller.dart

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data'; // Para Uint8List
import 'dart:ui' as ui;    // Para ui.Codec e ui.ImageByteFormat

import 'package:flutter/foundation.dart' show kIsWeb; // Para checar a plataforma
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

import 'facility_model.dart';
import 'package:park_wallet/constants/endpoints.dart';
import 'package:park_wallet/constants/app_colors.dart';

class MapController extends GetxController {
  static const double _northBound = -25.1480;
  static const double _southBound = -25.1680;
  static const double _eastBound = -54.2900;
  static const double _westBound = -54.3100;
  static const LatLng parkSouthwest = LatLng(_southBound, _westBound);
  static const LatLng parkNortheast = LatLng(_northBound, _eastBound);
  static const LatLng initialCenter =
      LatLng((_northBound + _southBound) / 2, (_eastBound + _westBound) / 2);
  static const double minZoom = 16.0;
  static const double maxZoom = 20.0;
  static const double initialZoom = 18.0;

  final Completer<GoogleMapController> mapCompleter = Completer();
  GoogleMapController? googleMapController;
  String? mapStyle;
  late final CameraPosition initialCameraPosition;
  late final LatLngBounds cameraBounds;
  late final MinMaxZoomPreference zoomPreference;

  final facilitiesListInternal = <Map<String, dynamic>>[].obs;
  final Rx<Set<Marker>> markers = Rx<Set<Marker>>({});
  final RxBool isLoadingFacilities = true.obs;

  final Map<String, BitmapDescriptor> _pinIcons = {};
  BitmapDescriptor _defaultPinIcon = BitmapDescriptor.defaultMarker;

  final Rx<Facility?> selectedFacilityForBottomSheet = Rx<Facility?>(null);

  @override
  void onInit() {
    super.onInit();
    initialCameraPosition =
        const CameraPosition(target: initialCenter, zoom: initialZoom);
    cameraBounds =
        LatLngBounds(southwest: parkSouthwest, northeast: parkNortheast);
    zoomPreference = const MinMaxZoomPreference(minZoom, maxZoom);
    
    _initializeAssetsAndFetch();
  }

  Future<void> _initializeAssetsAndFetch() async {
    print("MapController: Inicializando assets e buscando facilities...");
    await _preparePinIcons();
    await _loadMapStyle(); // Carrega o estilo após os ícones, antes de fetch
    await _fetchAndLoadFacilities();
    print("MapController: Inicialização concluída.");
  }

  Future<BitmapDescriptor> _getMarkerIconFromAsset(String assetPath, {int width = 80}) async {
    // Adicione prints para depuração aqui se necessário
    // print("MapController: Carregando asset $assetPath");
    try {
      ByteData data = await rootBundle.load(assetPath);
      ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width);
      ui.FrameInfo fi = await codec.getNextFrame();
      final Uint8List markerIconBytes = (await fi.image.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
      // print("MapController: Asset $assetPath carregado com sucesso.");
      return BitmapDescriptor.fromBytes(markerIconBytes);
    } catch (e) {
      print("MapController: ERRO ao carregar ícone do asset '$assetPath': $e. Usando default.");
      return BitmapDescriptor.defaultMarker;
    }
  }

  Future<void> _preparePinIcons() async {
    print("MapController (_preparePinIcons): Preparando pinpoints...");
    _pinIcons.clear();

    if (kIsWeb) {
      print("MapController (_preparePinIcons): Plataforma WEB, carregando ícones de assets PNG.");
      _pinIcons['store'] = await _getMarkerIconFromAsset('assets/images/pins/pin_store.png');
      _pinIcons['attraction'] = await _getMarkerIconFromAsset('assets/images/pins/pin_attraction.png');
      _pinIcons['other'] = await _getMarkerIconFromAsset('assets/images/pins/pin_other.png');
      _defaultPinIcon = _pinIcons['other'] ?? BitmapDescriptor.defaultMarker; // Fallback para web
    } else {
      print("MapController (_preparePinIcons): Plataforma MOBILE, usando defaultMarkerWithHue.");
      _pinIcons['store'] = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
      _pinIcons['attraction'] = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
      _pinIcons['other'] = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
      _defaultPinIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet); // Fallback para mobile
    }
    _pinIcons['default'] = _defaultPinIcon;
    print("MapController (_preparePinIcons): Pinpoints preparados. Verificando:");
    _pinIcons.forEach((key, value) {
      print("  Ícone '$key': ${value.toString()} (É o default do Google? ${value == BitmapDescriptor.defaultMarker})");
    });
  }

  Future<void> _loadMapStyle() async {
    try {
      mapStyle = await rootBundle.loadString('assets/map_style.json');
      _applyMapStyle();
    } catch (e) {
      print("MapController: map_style.json não encontrado ou inválido: $e");
      mapStyle = null;
    }
  }
  
  void _applyMapStyle() {
    // Await mapCompleter.future para garantir que o controller está pronto
    mapCompleter.future.then((controller) {
        if (mapStyle != null) {
            controller.setMapStyle(mapStyle);
            print("MapController: Estilo do mapa aplicado.");
        }
    }).catchError((e) {
        print("MapController: Erro ao aplicar estilo do mapa (controller não pronto?): $e");
    });
  }

  void onMapCreated(GoogleMapController controller) {
    print("MapController: onMapCreated - Mapa criado.");
    if (!mapCompleter.isCompleted) {
      mapCompleter.complete(controller);
    }
    // googleMapController = controller; // mapCompleter já lida com isso
    _applyMapStyle(); 
  }

  void _handleMarkerTap(String facilityId) {
    print("MapController: _handleMarkerTap para facility ID: $facilityId");
    final facilityMap = facilitiesListInternal.firstWhere(
      (f) => f['id'] == facilityId,
      orElse: () {
        print("MapController: _handleMarkerTap - Facility NÃO ENCONTRADA com ID: $facilityId");
        return <String, dynamic>{};
      },
    );

    if (facilityMap.isNotEmpty && facilityMap['facility_object'] is Facility) {
      final Facility facility = facilityMap['facility_object'];
      print("MapController: _handleMarkerTap - Facility ENCONTRADA: ${facility.name}");
      selectedFacilityForBottomSheet.value = facility;
      
      Get.bottomSheet(
        FacilityDetailsBottomSheet(facility: facility),
        backgroundColor: Colors.white,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ).whenComplete(() {
        print("MapController: BottomSheet para ${facility.name} fechado.");
        selectedFacilityForBottomSheet.value = null;
      });
    } else {
      print("MapController: _handleMarkerTap - Objeto facility inválido para ID $facilityId.");
    }
  }

  Future<void> _fetchAndLoadFacilities() async {
    isLoadingFacilities.value = true;
    facilitiesListInternal.clear();
    final Set<Marker> newMarkers = {};
    print('MapController (_fetchAndLoadFacilities): Iniciando...');

    if (_pinIcons.isEmpty) {
      print("MapController (_fetchAndLoadFacilities): ALERTA - Ícones não preparados! Re-preparando...");
      await _preparePinIcons();
      if (_pinIcons.isEmpty) {
        print("MapController (_fetchAndLoadFacilities): FALHA CRÍTICA ao preparar ícones.");
        _defaultPinIcon = BitmapDescriptor.defaultMarker;
      }
    }

    try {
      final Uri uri = Uri.parse(Endpoints.getFacilities);
      final response = await http.get(uri, headers: {'Content-Type': 'application/json; charset=UTF-8'})
          .timeout(const Duration(seconds: 20));
      print('MapController (_fetchAndLoadFacilities): Resposta API Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedBody = jsonDecode(utf8.decode(response.bodyBytes));
        if (decodedBody.containsKey('data') && decodedBody['data'] is List) {
          final List<dynamic> facilitiesDataList = decodedBody['data'];
          List<Facility> parsedFacilities = [];
          for (var data in facilitiesDataList) {
            try {
              parsedFacilities.add(Facility.fromJson(data as Map<String, dynamic>));
            } catch (e, s) {
              print("Erro parse facility JSON: $data. Erro: $e, Stack: $s");
            }
          }
          print("MapController (_fetchAndLoadFacilities): ${parsedFacilities.length} facilities parseadas.");

          for (final facility in parsedFacilities) {
            if (facility.inactive) continue;
            if (facility.latitude == null || facility.longitude == null) continue;
            final latlng = LatLng(facility.latitude!, facility.longitude!);
            if (latlng.latitude < parkSouthwest.latitude || latlng.latitude > parkNortheast.latitude ||
                latlng.longitude < parkSouthwest.longitude || latlng.longitude > parkNortheast.longitude) {
              continue;
            }

            final facilityMap = {
              "id": facility.id, "nome": facility.name, "latlng": latlng,
              "horario": facility.horario ?? "Não informado", "facility_object": facility,
            };
            facilitiesListInternal.add(facilityMap);

            String typeKey = facility.type.toLowerCase().trim();
            BitmapDescriptor icon = _pinIcons[typeKey] ?? _defaultPinIcon;
            
            print("MapController: Processando '${facility.name}', Tipo: '$typeKey', Ícone: ${icon == BitmapDescriptor.defaultMarker ? 'GOOGLE_DEFAULT' : 'CUSTOMIZADO/HUE'}. String do Ícone: ${icon.toString()}");

            newMarkers.add(
              Marker(
                markerId: MarkerId(facility.id),
                position: latlng,
                icon: icon,
                onTap: () => _handleMarkerTap(facility.id),
              ),
            );
          }
          markers.value = newMarkers;
          print("MapController (_fetchAndLoadFacilities): Marcadores atualizados: ${newMarkers.length}");
        } else { Get.snackbar('Erro', 'Formato de dados inválido.');}
      } else { Get.snackbar('Erro', 'Falha ao buscar dados: ${response.statusCode}');}
    } catch (e, s) {
      print('MapController (_fetchAndLoadFacilities): Erro GERAL: $e, Stack: $s');
      Get.snackbar('Erro', 'Erro de conexão.');
    } finally {
      isLoadingFacilities.value = false;
    }
  }

  List<Map<String, dynamic>> get facilitiesSerializable {
    // Este getter ainda pode ser útil se você precisar dos dados em outro lugar
    // ou se o seu map_view.html (que não usamos mais diretamente para o mapa)
    // ainda for usado para alguma outra funcionalidade.
    return facilitiesListInternal.map((facilityMapEntry) {
      final Facility facility = facilityMapEntry['facility_object'] as Facility;
      final LatLng latlng = facilityMapEntry['latlng'] as LatLng;
      return {
        'id': facility.id,
        'nome': facility.name,
        'type': facility.type,
        'description': facility.description,
        'image': facility.image,
        'latlng': {'lat': latlng.latitude, 'lng': latlng.longitude},
        'produtos': facility.products.map((p) => p.toJson()).toList(),
        'horario': facility.horario ?? "Não informado",
      };
    }).toList();
  }
}


// --- Widget para o BottomSheet (mantenha como na sua versão anterior ou mova para um arquivo separado) ---
// class FacilityDetailsBottomSheet extends StatelessWidget { ... }
// Cole aqui o FacilityDetailsBottomSheet da sua resposta anterior
class FacilityDetailsBottomSheet extends StatelessWidget {
  final Facility facility;

  const FacilityDetailsBottomSheet({super.key, required this.facility});

  @override
  Widget build(BuildContext context) {
    print("FacilityDetailsBottomSheet: Construindo para ${facility.name}");

    IconData getProductIcon(String _) => Icons.fastfood; // Ícone genérico

    return Container( 
      constraints: BoxConstraints(
        maxHeight: Get.height * 0.85, 
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, 
        children: [
          Container(
            margin: const EdgeInsets.only(top: 8, bottom: 8),
            width: 40,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch, 
                children: [
                  Center(
                    child: Text(
                      facility.name,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Center(
                    child: Text(
                      facility.type.capitalizeFirst ?? facility.type,
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: (facility.image != null && facility.image!.isNotEmpty)
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset( 
                              facility.image!,
                              width: 200,
                              height: 150,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                print("FacilityDetailsBottomSheet: ERRO AO CARREGAR IMAGEM ASSET '${facility.image}': $error");
                                return Container(
                                  width: 200, height: 150, 
                                  decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(12)),
                                  child: Icon(Icons.broken_image, size: 80, color: Colors.grey[700])
                                );
                              },
                            ),
                          )
                        : Container(
                            width: 200, height: 150,
                            decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(12)),
                            child: Icon(Icons.store, size: 80, color: Colors.grey[700]),
                          ),
                  ),
                  if (facility.description.isNotEmpty) ...[  
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
                      child: Text(
                        facility.description,
                        style: TextStyle(fontSize: 14, color: Colors.grey[800]),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                  if (facility.horario != null && facility.horario!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Center(child: Text('Horário: ${facility.horario}', style: TextStyle(fontSize: 14, color: Colors.grey[700]))),
                  ],
                  const SizedBox(height: 24),
                  if (facility.type.toLowerCase() == 'store') ...[
                    Center(
                      child: Text(
                        "Produtos", 
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (facility.products.isEmpty)
                      Center(child: Padding(padding: const EdgeInsets.symmetric(vertical: 16.0), child: Text("Nenhum produto disponível", style: TextStyle(color: Colors.grey[600]))))
                    else
                      ListView.builder(
                        shrinkWrap: true, 
                        physics: const NeverScrollableScrollPhysics(), 
                        itemCount: facility.products.length,
                        itemBuilder: (context, index) {
                          final product = facility.products[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            elevation: 2,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  Container(
                                    width: 50, height: 50,
                                    decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(8)),
                                    child: Icon(getProductIcon(product.name), size: 30, color: Colors.grey[700]),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(product.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                                        const SizedBox(height: 4),
                                        Text('R\$ ${product.price.toStringAsFixed(2)}', style: TextStyle(fontSize: 14, color: Colors.grey[700], fontWeight: FontWeight.w500)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () => Get.back(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.sapphire,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Fechar', style: TextStyle(fontSize: 16, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}