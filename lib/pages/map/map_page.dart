import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:park_wallet/pages/map/controllers/map_controller.dart';
import 'package:park_wallet/pages/widgets/common_app_bar.dart';
import 'package:park_wallet/pages/widgets/common_bottom_navigation_bar.dart';
import 'package:park_wallet/pages/widgets/common_drawer.dart';
import 'dart:developer' as developer;

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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      developer.log('[MapPage initState] Get.arguments recebido: ${Get.arguments}', name: 'DEBUG_ARGUMENTOS');

      if (Get.arguments is Map<String, dynamic> && Get.arguments.containsKey('storeIdToFocus')) {
        final String storeId = Get.arguments['storeIdToFocus'];
        developer.log('[MapPage initState] ID da loja encontrado: $storeId. Chamando focusOnStore...', name: 'DEBUG_ARGUMENTOS');
        controller.focusOnStore(storeId);
      } else {
        developer.log('[MapPage initState] Nenhum argumento válido encontrado para focar.', name: 'DEBUG_ARGUMENTOS');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(),
      drawer: CommonDrawer(),
      body: Obx(() {
        if (!controller.isLocationPermissionGranted.value) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Verificando permissões...'),
              ],
            ),
          );
        }

        return Stack(
          children: [
            GoogleMap(
              initialCameraPosition: controller.initialCameraPosition,
              onMapCreated: controller.onMapCreated,
              cameraTargetBounds: CameraTargetBounds(controller.cameraBounds),
              minMaxZoomPreference: controller.zoomPreference,
              mapType: MapType.satellite,
              markers: controller.markers.value,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              compassEnabled: true,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
              scrollGesturesEnabled: !controller.isMapInteractionDisabled.value,
              zoomGesturesEnabled: !controller.isMapInteractionDisabled.value,
              tiltGesturesEnabled: !controller.isMapInteractionDisabled.value,
              rotateGesturesEnabled: !controller.isMapInteractionDisabled.value,
            ),

            if (controller.isLoadingFacilities.value && controller.facilities.isEmpty)
              const Center(
                child: CircularProgressIndicator.adaptive(),
              ),

            Positioned(
              bottom: 100,
              right: 16,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FloatingActionButton(
                    heroTag: "center_button",
                    onPressed: () => controller.centerOnPark(),
                    backgroundColor: Theme.of(context).primaryColor,
                    child: const Icon(
                      Icons.home,
                      color: Colors.white,
                    ),
                    tooltip: 'center_on_park'.tr,
                  ),
                  const SizedBox(height: 10),
                  FloatingActionButton(
                    heroTag: "nearest_store_button",
                    onPressed: () => controller.findNearestStore(),
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    child: const Icon(
                      Icons.store_mall_directory,
                      color: Colors.white,
                    ),
                    tooltip: 'find_nearest_store'.tr,
                  ),
                  const SizedBox(height: 10),
                  FloatingActionButton(
                    heroTag: "my_location_custom_button",
                    onPressed: () => controller.centerOnMyLocation(),
                    backgroundColor: Theme.of(context).primaryColor,
                    child: const Icon(
                      Icons.location_searching,
                      color: Colors.white,
                    ),
                    tooltip: 'my_location'.tr,
                  ),
                ],
              ),
            ),
          ],
        );
      }),
      bottomNavigationBar: const CommonBottomNavigationBar(currentRoute: "/map"),
    );
  }
}