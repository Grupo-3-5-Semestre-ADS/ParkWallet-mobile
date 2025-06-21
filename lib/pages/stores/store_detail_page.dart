import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:park_wallet/constants/app_colors.dart';
import 'package:park_wallet/data/models/product.dart';
import 'package:park_wallet/pages/stores/controllers/store_detail_controller.dart';
import 'package:park_wallet/pages/widgets/app_button.dart';
import 'package:park_wallet/pages/widgets/common_app_bar.dart';
import 'package:park_wallet/pages/widgets/common_bottom_navigation_bar.dart';
import 'package:park_wallet/pages/widgets/common_drawer.dart';
import 'package:park_wallet/pages/widgets/wave_background.dart';

class StoreDetailPage extends StatelessWidget {
  const StoreDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<StoreDetailController>();

    if (controller.store.value == null) {
      return Scaffold(
        appBar: CommonAppBar(),
        drawer: CommonDrawer(),
        body: const Center(
          child: Text(
            'Erro ao carregar detalhes da loja.',
            style: TextStyle(color: Colors.red, fontSize: 18),
          ),
        ),
        bottomNavigationBar: CommonBottomNavigationBar(currentRoute: "/stores"),
      );
    }

    return Scaffold(
      appBar: CommonAppBar(),
      drawer: CommonDrawer(),
      body: Stack(
        children: [
          WaveBackground(opaque: true),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      controller.store.value.name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Center(
                    child: Text(
                      controller.store.value.type,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: controller.store.value.image != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              controller.store.value.image!,
                              width: 200,
                              height: 150,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Container(
                            width: 200,
                            height: 150,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.store,
                              size: 80,
                              color: Colors.grey[700],
                            ),
                          ),
                  ),
                  if (controller.store.value.description != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        controller.store.value.description!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[800],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Center(
                    child: SizedBox(
                      width: double.infinity,
                      child: AppButton(
                        label: 'view_on_map'.tr,
                        onPressed: controller.viewOnMap,
                        icon: Icons.map,
                        iconPosition: IconPosition.start,
                        backgroundColor: AppColors.sapphire,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Adiciona condicional para exibir produtos apenas se não for atração ou other
                  if (controller.store.value.type.toLowerCase() != 'atracao' && 
                      controller.store.value.type.toLowerCase() != 'atração' && 
                      controller.store.value.type.toLowerCase() != 'attraction' &&
                      controller.store.value.type.toLowerCase() != 'other' &&
                      controller.store.value.type.toLowerCase() != 'outro') ...[
                    Center(
                      child: Text('products'.tr,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        return ConstrainedBox(
                          constraints: BoxConstraints(

                            maxHeight: MediaQuery.of(context).size.height * 0.35,
                            minHeight: 0,
                          ),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Obx(() {
                              if (controller.isLoading.value) {
                                return const Center(child: CircularProgressIndicator());
                              }
                              if (controller.products.isEmpty) {
                                return Center(
                                  child: Text('no_products_available'.tr),
                                );
                              }
                              return Scrollbar(
                                thumbVisibility: true,
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  physics: const BouncingScrollPhysics(),
                                  itemCount: controller.products.length,
                                  itemBuilder: (context, index) {
                                    final product = controller.products[index];
                                    return _buildProductItem(product, controller, context);
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
        ],
      ),
      bottomNavigationBar: CommonBottomNavigationBar(currentRoute: "/stores"),
    );
  }

  Widget _buildProductItem(Product product, StoreDetailController controller, BuildContext context, {bool isGrid = false}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.fastfood,
                    size: 28,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        product.description ?? '',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'R\$ ${product.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}