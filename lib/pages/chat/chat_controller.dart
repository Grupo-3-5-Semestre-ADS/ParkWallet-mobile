import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:park_wallet/data/models/chat_message.dart';
import 'package:park_wallet/services/chat_service.dart';

class ChatController extends GetxController {
  final ChatService _chatService = Get.find<ChatService>();
  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final RxBool isConnected = false.obs;
  final RxBool isLoading = true.obs;
  final RxList<ChatMessage> messages = <ChatMessage>[].obs;
  final ImagePicker _picker = ImagePicker();
  
  // WebSocket server URL - update this with your actual server URL when ready
  final String wsUrl = 'ws://localhost:8080/chat';
  
  @override
  void onInit() {
    super.onInit();
    _initChatService();
    _subscribeToMessages();
    _subscribeToConnectionStatus();
  }
  
  @override
  void onClose() {
    messageController.dispose();
    scrollController.dispose();
    _chatService.disconnect();
    super.onClose();
  }
  
  void _initChatService() {
    // This is just preparing for future connection
    // Don't connect now as the server isn't ready yet
    isLoading.value = false;
  }
  
  void _subscribeToMessages() {
    _chatService.messagesStream.listen((updatedMessages) {
      messages.value = updatedMessages;
      
      // Auto-scroll to bottom on new message
      if (scrollController.hasClients) {
        Future.delayed(const Duration(milliseconds: 100), () {
          scrollController.animateTo(
            scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        });
      }
    });
  }
  
  void _subscribeToConnectionStatus() {
    _chatService.connectionStatusStream.listen((status) {
      isConnected.value = status == ConnectionStatus.connected;
    });
  }
  
  // User actions
  Future<void> connect() async {
    if (!isConnected.value) {
      await _chatService.connect(wsUrl);
    }
  }
  
  Future<void> sendMessage() async {
    final message = messageController.text.trim();
    if (message.isNotEmpty) {
      await _chatService.sendTextMessage(message);
      messageController.clear();
    }
  }
  
  Future<void> pickAndSendImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70, // Reduce quality to keep base64 size reasonable
    );
    
    if (image != null) {
      await _chatService.sendImageMessage(image);
    }
  }
  
  Future<void> takeAndSendPhoto() async {
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 70, // Reduce quality to keep base64 size reasonable
    );
    
    if (photo != null) {
      await _chatService.sendImageMessage(photo);
    }
  }
}