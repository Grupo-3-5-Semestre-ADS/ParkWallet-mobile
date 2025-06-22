import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:park_wallet/constants/app_colors.dart';
import 'package:park_wallet/pages/map/controllers/map_controller.dart';
import 'package:park_wallet/pages/map/models/map_display_facility.dart';
import 'package:park_wallet/pages/map/widgets/product_item_widget.dart';

class FacilityDetailsBottomSheet extends StatelessWidget {
  final MapDisplayFacility facility;
  final MapController controller;

  const FacilityDetailsBottomSheet({
    super.key,
    required this.facility,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: Get.height * 0.85),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 8, bottom: 8),
            width: 40, height: 5,
            decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(child: Text(facility.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold))),
                  const SizedBox(height: 4),
                  Center(child: Text(facility.type.capitalizeFirst ?? facility.type, style: TextStyle(fontSize: 16, color: Colors.grey[600]))),
                  const SizedBox(height: 16),
                  Center(
                    child: facility.image != null && facility.image!.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              facility.image!, width: 200, height: 150, fit: BoxFit.cover,
                              errorBuilder: (c,e,s) => Container(width: 200, height: 150, decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(12)), child: Icon(Icons.broken_image, size: 80, color: Colors.grey[700])),
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
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
                      child: Text(facility.description, style: TextStyle(fontSize: 14, color: Colors.grey[800]), textAlign: TextAlign.center),
                    ),
                  ],
                  if (facility.horario != null && facility.horario!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Center(child: Text('Horário: ${facility.horario}', style: TextStyle(fontSize: 14, color: Colors.grey[700]))),
                  ],
                  if (facility.type.toLowerCase() == 'store') ...[
                    const SizedBox(height: 24),
                    const Center(child: Text("Produtos", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                    const SizedBox(height: 8),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        return ConstrainedBox(
                          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.35, minHeight: 0),
                          child: Container(
                            width: double.infinity, padding: const EdgeInsets.all(8.0),
                            decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(16)),
                            child: Obx(() {
                              if (controller.isLoadingProductsForBottomSheet.value) {
                                return const Center(child: Padding(padding: EdgeInsets.all(16.0), child: CircularProgressIndicator()));
                              }
                              if (controller.productsForBottomSheet.isEmpty) {
                                return const Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 16.0), child: Text("Nenhum produto disponível", style: TextStyle(color: Colors.grey))));
                              }
                              return Scrollbar(
                                thumbVisibility: true,
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  physics: const BouncingScrollPhysics(),
                                  itemCount: controller.productsForBottomSheet.length,
                                  itemBuilder: (context, index) {
                                    final product = controller.productsForBottomSheet[index];
                                    return ProductItemWidget(product: product);
                                  },
                                ),
                              );
                            }),
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
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.sapphire, minimumSize: const Size(double.infinity, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              child: Text('close'.tr, style: const TextStyle(fontSize: 16, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}