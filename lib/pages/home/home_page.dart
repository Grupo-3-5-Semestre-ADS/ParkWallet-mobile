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
    final creditCtrl = Get.find<HomeCreditController>();
    final historyCtrl = Get.find<HomeHistoryController>();

    return Stack(
      children: [
        WaveBackground(opaque: true),
        RefreshIndicator(
          onRefresh: () async {
            await creditCtrl.loadBalance();
            // await historyCtrl.loadHistory(); // Se tiver
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
                  child: CreditCard(creditCtrl: creditCtrl),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.6, // Altura visível p/ histórico
                    child: HistoryCard(historyController: historyCtrl),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }


}
