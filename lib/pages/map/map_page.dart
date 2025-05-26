// map_page.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:flutter/foundation.dart' show kIsWeb; // Não é mais estritamente necessário para a lógica do mapa aqui
import 'package:permission_handler/permission_handler.dart'; // Mantenha para mobile

import '../map/controllers/map_controller.dart'; // Ajuste o caminho
import 'package:park_wallet/pages/widgets/common_app_bar.dart';
import 'package:park_wallet/pages/widgets/common_bottom_navigation_bar.dart';
import 'package:park_wallet/pages/widgets/common_drawer.dart';
// Removido: import 'package:park_wallet/pages/map/widgets/google_map_webview.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late final MapController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<MapController>();
    // Solicita permissão no initState para mobile. Para web, isso não faz nada.
    _checkAndRequestLocationPermission();
  }

  Future<void> _checkAndRequestLocationPermission() async {
    // kIsWeb não é necessário aqui pois permission_handler lida com a plataforma
    if (await Permission.location.isDenied || await Permission.location.isPermanentlyDenied) {
      await Permission.location.request();
    }
    // Atualiza o estado para reconstruir se a permissão mudar (opcional,
    // pois myLocationEnabled pode já lidar com isso internamente)
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(),
      drawer: CommonDrawer(),
      body: Obx(() { // Obx para reagir às mudanças nos marcadores e isLoading
        if (controller.isLoadingFacilities.value && controller.markers.value.isEmpty) {
          return const Center(child: CircularProgressIndicator.adaptive());
        }
        
        // Usar GoogleMap diretamente para todas as plataformas
        return GoogleMap(
          initialCameraPosition: controller.initialCameraPosition,
          onMapCreated: controller.onMapCreated,
          cameraTargetBounds: CameraTargetBounds(controller.cameraBounds),
          minMaxZoomPreference: controller.zoomPreference,
          mapType: MapType.satellite, // Ou MapType.normal se preferir
          markers: controller.markers.value, // USA OS MARKERS DO CONTROLLER
          myLocationEnabled: true,      // Tenta mostrar a localização do usuário
          myLocationButtonEnabled: true, // Botão para centralizar na localização
          compassEnabled: true,
          zoomControlsEnabled: true,    // Controles de zoom no mapa
          mapToolbarEnabled: false,       // Desabilita barra de ferramentas do Google Maps (abrir no app Maps, etc.)
          // Outras propriedades que você queira configurar...
        );
      }),
      bottomNavigationBar:
          const CommonBottomNavigationBar(currentRoute: "/map"),
    );
  }
}