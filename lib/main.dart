import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:park_wallet/pages/home/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter GetX Demo',
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}
