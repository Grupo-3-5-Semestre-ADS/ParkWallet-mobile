import 'package:get/get.dart';
import 'package:park_wallet/pages/chat/chat_controller.dart';
import 'package:park_wallet/services/chat_service.dart';

class ChatBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ChatService>(() => ChatService());
    Get.lazyPut<ChatController>(() => ChatController());
  }
}