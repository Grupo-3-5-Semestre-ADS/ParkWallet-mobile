import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CommonBottomNavigationBar extends StatelessWidget {
  final String currentRoute;

  const CommonBottomNavigationBar({super.key, required this.currentRoute});

  void _onItemTapped(String route) {
    if (Get.currentRoute != route) {
      Get.toNamed(route);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: _getIndexFromRoute(currentRoute),
      onTap: (index) => _onItemTapped(_getRouteFromIndex(index)),
      type: BottomNavigationBarType.fixed,
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.pin_drop, color: Colors.grey[700]),
          label: 'map'.tr,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.store, color: Colors.grey[700]),
          label: 'stores'.tr,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.add_circle_outline, color: Colors.grey[700]),
          label: 'home'.tr,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.list, color: Colors.grey[700]),
          label: 'history'.tr,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.notifications, color: Colors.grey[700]),
          label: 'news'.tr,
        ),
      ],
    );
  }

  int _getIndexFromRoute(String route) {
    switch (route) {
      case '/map':
        return 0;
      case '/stores':
        return 1;
      case '/home':
        return 2;
      case '/history':
        return 3;
      case '/news':
        return 4;
      default:
        return 2;
    }
  }

  String _getRouteFromIndex(int index) {
    switch (index) {
      case 0:
        return '/map';
      case 1:
        return '/stores';
      case 2:
        return '/home';
      case 3:
        return '/history';
      case 4:
        return '/news';
      default:
        return '/home';
    }
  }
}
