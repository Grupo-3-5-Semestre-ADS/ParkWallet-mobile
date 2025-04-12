import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:park_wallet/constants/app_colors.dart';
import 'package:park_wallet/pages/stores/controllers/stores_controller.dart';
import 'package:park_wallet/pages/widgets/common_app_bar.dart';
import 'package:park_wallet/pages/widgets/common_bottom_navigation_bar.dart';
import 'package:park_wallet/pages/widgets/common_drawer.dart';
import 'package:park_wallet/pages/widgets/store_item_tile.dart';
import 'package:park_wallet/pages/widgets/wave_background.dart';

class StoresPage extends StatelessWidget {
  const StoresPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<StoresController>();

    return Scaffold(
      appBar: CommonAppBar(),
      drawer: CommonDrawer(),
      body: Stack(
        children: [
          WaveBackground(opaque: true),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "stores".tr,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    onChanged: controller.updateSearch,
                    decoration: InputDecoration(
                      hintText: 'search_stores'.tr,
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: Obx(() {
                      final stores = controller.filteredStores;

                      if (stores.isEmpty) {
                        return Center(child: Text("no_stores_found".tr));
                      }

                      return ListView.separated(
                        itemCount: stores.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (_, index) {
                          final item = stores[index];
                          return StoreItemTile(
                            item: item,
                            onTap: () => controller.navigateToStoreDetail(item),
                          );
                        },
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: CommonBottomNavigationBar(currentRoute: "/stores"),
    );
  }
}