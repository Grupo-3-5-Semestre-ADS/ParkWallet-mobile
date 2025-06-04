import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:park_wallet/constants/app_colors.dart';
import 'package:park_wallet/pages/home/controllers/home_history_controller.dart';
import 'package:park_wallet/pages/widgets/app_button.dart';
import '../../widgets/purchase_item_tile.dart';
import '../../widgets/added_balance_tile.dart';

class HistoryCard extends StatelessWidget {
  final HomeHistoryController historyController;

  const HistoryCard({
    super.key,
    required this.historyController,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.white,
      shadowColor: Colors.black87,
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            const itemHeight = 70.0;
            const headerHeight = 50.0;
            final availableHeight = constraints.maxHeight - headerHeight;
            final maxItems = availableHeight ~/ itemHeight;

            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (historyController.maxVisibleItems.value != maxItems) {
                historyController.maxVisibleItems.value = maxItems;
                historyController.loadHistory(size: maxItems);
              }
            });


            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "transaction_history".tr,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Obx(() {
                  final transactions = historyController.transactions;
                  final visibleItems = transactions.take(maxItems).toList();

                  return ListView.separated(
                    itemCount: visibleItems.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (_, index) {
                      final item = visibleItems[index];
                      if (item.operation == "purchase") {
                        return PurchaseItemTile(transaction: item);
                      } else if (item.operation == "credit") {
                        return AddedBalanceTile(transaction: item);
                      }
                      return const SizedBox.shrink();
                    },
                  );
                }),
                const Spacer(),
                Align(
                  alignment: Alignment.center,
                  child: AppButton(
                    label: "see_more".tr,
                    backgroundColor: AppColors.muted_blue,
                    onPressed: () {
                      Get.toNamed('/history');
                    },
                    icon: Icons.add,
                    iconPosition: IconPosition.start,
                    width: 150,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

}
