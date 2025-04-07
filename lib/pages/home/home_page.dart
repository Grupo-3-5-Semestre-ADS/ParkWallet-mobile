import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:park_wallet/pages/home/controllers/home_credit_controller.dart';
import 'package:park_wallet/pages/home/controllers/home_history_controller.dart';
import 'package:park_wallet/pages/home/widgets/credit_card.dart';
import 'package:park_wallet/pages/home/widgets/history_card.dart';
import 'package:park_wallet/pages/widgets/common_app_bar.dart';
import 'package:park_wallet/pages/widgets/common_bottom_navigation_bar.dart';
import 'package:park_wallet/pages/widgets/common_drawer.dart';
import 'package:park_wallet/pages/widgets/wave_background.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(),
      drawer: CommonDrawer(),
      body: _body(context),
      bottomNavigationBar: CommonBottomNavigationBar(currentRoute: "/home"),
    );
  }

  Widget _body(BuildContext context) {
    return Stack(
      children: [

        WaveBackground(opaque: true),

        Column(
          children: [
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: CreditCard(creditCtrl: Get.find<HomeCreditController>())
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: HistoryCard(historyController: Get.find<HomeHistoryController>()),
              ),
            ),
          ],
        ),
      ],
    );
  }

}
