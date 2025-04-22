import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:park_wallet/constants/app_colors.dart';
import 'package:park_wallet/pages/chat/chat_controller.dart';
import 'package:park_wallet/pages/chat/widgets/message_bubble.dart';
import 'package:park_wallet/pages/widgets/common_app_bar.dart';
import 'package:park_wallet/pages/widgets/common_bottom_navigation_bar.dart';
import 'package:park_wallet/pages/widgets/common_drawer.dart';

class ChatPage extends GetView<ChatController> {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildCustomAppBar(context),
      drawer: const CommonDrawer(),
      body: Column(
        children: [
          _buildConnectionStatusBar(),
          Expanded(
            child: _buildChatMessages(),
          ),
          _buildInputArea(context),
        ],
      ),
      bottomNavigationBar: const CommonBottomNavigationBar(currentRoute: '/news'),
    );
  }

  PreferredSizeWidget _buildCustomAppBar(BuildContext context) {
    return const CommonAppBar();
  }

  Widget _buildConnectionStatusBar() {
    return Obx(() => Container(
      color: controller.isConnected.value ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: controller.isConnected.value ? Colors.green : Colors.grey,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            controller.isConnected.value ? 'online'.tr : 'offline'.tr,
            style: TextStyle(
              fontSize: 12,
              color: controller.isConnected.value ? Colors.green : Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    ));
  }

  Widget _buildChatMessages() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.messages.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.chat_outlined,
                size: 80,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'no_messages_yet'.tr,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: controller.connect,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.sapphire,
                  foregroundColor: Colors.white,
                ),
                child: Text('connect'.tr),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        controller: controller.scrollController,
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: controller.messages.length,
        itemBuilder: (context, index) {
          final message = controller.messages[index];
          return MessageBubble(message: message);
        },
      );
    });
  }

  Widget _buildInputArea(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 3,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              _showImageSourceOptions(context);
            },
            icon: const Icon(Icons.add_photo_alternate_outlined),
            color: AppColors.sapphire,
          ),
          Expanded(
            child: TextField(
              controller: controller.messageController,
              decoration: InputDecoration(
                hintText: 'type_message'.tr,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: AppColors.very_light_grey,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => controller.sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: AppColors.sapphire,
            radius: 20,
            child: IconButton(
              onPressed: controller.sendMessage,
              icon: const Icon(
                Icons.send,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showImageSourceOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: Text('gallery'.tr),
                onTap: () {
                  Navigator.pop(context);
                  controller.pickAndSendImage();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: Text('camera'.tr),
                onTap: () {
                  Navigator.pop(context);
                  controller.takeAndSendPhoto();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}