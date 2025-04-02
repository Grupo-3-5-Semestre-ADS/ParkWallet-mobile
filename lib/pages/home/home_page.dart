import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:park_wallet/pages/home/controllers/HomeController.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.find<HomeController>(); //

    return Scaffold(
      appBar: AppBar(title: const Text("Home")),
      body: Center(
        child: Obx(() => Text("Contador: ${controller.count}")),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: controller.increment,
        child: const Icon(Icons.add),
      ),
    );
  }
}
