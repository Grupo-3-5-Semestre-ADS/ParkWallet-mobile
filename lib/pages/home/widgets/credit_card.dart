import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:park_wallet/constants/app_colors.dart';
import 'package:park_wallet/constants/input_formatters/currency_input_formatter.dart';
import 'package:park_wallet/pages/home/controllers/home_credit_controller.dart';
import 'package:park_wallet/pages/widgets/app_button.dart';

class CreditCard extends StatelessWidget {
  final HomeCreditController creditCtrl;

  const CreditCard({
    super.key,
    required this.creditCtrl,
  });

  void _showRechargeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("recharge".tr),
        content: TextField(
        controller: creditCtrl.valueController,
        keyboardType: TextInputType.number,
        inputFormatters: [CurrencyInputFormatter()],
        decoration: const InputDecoration(
          hintText: "R\$ 0,00",
          border: OutlineInputBorder(),
        ),
      ),


      actions: [
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: "cancel".tr,
                  onPressed: () {
                    Navigator.of(context).pop();
                    creditCtrl.valueController.text = "";
                  },
                  backgroundColor: Colors.grey.shade300,
                  textColor: Colors.black,
                  height: 40,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AppButton(
                  backgroundColor: AppColors.sapphire,
                  label: "recharge".tr,
                  onPressed: () => creditCtrl.handleRecharge(context),
                  height: 40,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.white,
      elevation: 6,
      shadowColor: Colors.black87,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "my_balance".tr,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Obx(() => Text(
              "\$ ${creditCtrl.balance.toStringAsFixed(2)}",
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            )),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                AppButton(
                  label: "pay".tr,
                  onPressed: creditCtrl.pay,
                  icon: Icons.qr_code,
                  iconPosition: IconPosition.start,
                  width: 140,
                ),
                AppButton(
                  label: "recharge".tr,
                  backgroundColor: AppColors.muted_blue,
                  onPressed: () => _showRechargeDialog(context),
                  icon: Icons.add,
                  iconPosition: IconPosition.start,
                  width: 140,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
