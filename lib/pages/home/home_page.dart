import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:park_wallet/pages/home/controllers/home_controller.dart';
import 'package:park_wallet/pages/widgets/common_app_bar.dart';
import 'package:park_wallet/pages/widgets/common_bottom_navigation_bar.dart';
import 'package:park_wallet/pages/widgets/common_drawer.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.find<HomeController>(); //

    return Scaffold(
      appBar: CommonAppBar(),
      drawer: CommonDrawer(),
      body: Center(
        child: Obx(() => Text("Contador: ${controller.count}")),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: controller.increment,
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: CommonBottomNavigationBar(currentRoute: "/home",),
    );

  }
}
