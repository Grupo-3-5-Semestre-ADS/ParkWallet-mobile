import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:park_wallet/constants/app_colors.dart';
import 'package:park_wallet/pages/history/controllers/history_controller.dart';
import 'package:park_wallet/pages/widgets/added_balance_tile.dart';
import 'package:park_wallet/pages/widgets/app_button.dart';
import 'package:park_wallet/pages/widgets/common_app_bar.dart';
import 'package:park_wallet/pages/widgets/common_bottom_navigation_bar.dart';
import 'package:park_wallet/pages/widgets/common_drawer.dart';
import 'package:park_wallet/pages/widgets/purchase_item_tile.dart';
import 'package:park_wallet/pages/widgets/wave_background.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HistoryController>();

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
                    "transaction_history".tr,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    onChanged: controller.updateSearch,
                    decoration: InputDecoration(
                      hintText: 'search_transactions'.tr,
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
                      final transactions = controller.filteredTransactions;

                      if (transactions.isEmpty) {
                        return Center(child: Text("no_transactions".tr));
                      }

                      return ListView.separated(
                        itemCount: transactions.length + 1,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (_, index) {
                          if (index == transactions.length) {
                            return Padding(
                              padding: const EdgeInsets.all(12),
                              child: Center(
                                child: AppButton(
                                  label: "load_more".tr,
                                  backgroundColor: AppColors.muted_blue,
                                  onPressed: controller.loadMore,
                                  icon: Icons.refresh,
                                  iconPosition: IconPosition.start,
                                  width: 180,
                                ),
                              ),
                            );
                          }

                          final item = transactions[index];
                          return item.operation == "purchase"
                              ? PurchaseItemTile(item: item)
                              : AddedBalanceTile(item: item);
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
      bottomNavigationBar: CommonBottomNavigationBar(currentRoute: "/history"),
    );
  }
}
