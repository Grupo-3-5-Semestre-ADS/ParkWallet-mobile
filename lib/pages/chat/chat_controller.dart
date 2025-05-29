import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:park_wallet/data/models/chat_message.dart';
import 'package:park_wallet/services/chat_service.dart';
import 'dart:math' as math;

class ChatController extends GetxController with WidgetsBindingObserver {
  late final ChatService _chatService;
  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final RxBool isConnected = false.obs;
  final RxBool isLoading = true.obs;
  final RxList<ChatMessage> messages = <ChatMessage>[].obs;
  final ImagePicker _picker = ImagePicker();
  
  @override
  void onInit() {
    super.onInit();
    _chatService = Get.find<ChatService>();
    
    // Add app lifecycle observer to detect when app comes back from background
    WidgetsBinding.instance.addObserver(this);
    
    _initChatService();
    _subscribeToMessages();
    _subscribeToConnectionStatus();
    
    // Initial sync of messages
    _syncInitialMessages();
  }
  
  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    messageController.dispose();
    scrollController.dispose();
    _chatService.disconnect();
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      debugPrint('ChatController: App resumed, checking for new messages');
      // When app comes back to foreground, use the specialized method
      _chatService.onAppResumed();
    }
  }
  
  void _initChatService() {
    debugPrint('=== ChatController: STARTING CHAT INITIALIZATION ===');
    isLoading.value = true;
    
    // Use the new comprehensive initialization method
    _chatService.initializeWithHistory().then((_) {
      debugPrint('ChatController: Chat service initialization completed successfully');
      
      // Force sync the loaded messages
      final currentMessages = _chatService.messages;
      debugPrint('ChatController: Messages available after init: ${currentMessages.length}');
      
      if (currentMessages.isNotEmpty) {
        messages.value = List.from(currentMessages);
        debugPrint('ChatController: Successfully synced ${messages.length} messages to UI');
        
        // Log some sample messages for debugging
        for (int i = 0; i < math.min(currentMessages.length, 3); i++) {
          final msg = currentMessages[i];
          debugPrint('ChatController: Message $i: "${msg.content}" from ${msg.senderName} at ${msg.timestamp}');
        }
      } else {
        debugPrint('ChatController: No messages found after initialization');
      }
      
      isLoading.value = false;
      debugPrint('=== ChatController: CHAT INITIALIZATION COMPLETE ===');
      
    }).catchError((error) {
      debugPrint('ChatController: ERROR during chat service initialization: $error');
      isLoading.value = false;
      
      // Enhanced fallback with more detailed logging
      debugPrint('ChatController: Attempting fallback history load...');
      _chatService.loadMessageHistory().then((_) {
        final fallbackMessages = _chatService.messages;
        debugPrint('ChatController: Fallback loaded ${fallbackMessages.length} messages');
        
        if (fallbackMessages.isNotEmpty) {
          messages.value = List.from(fallbackMessages);
          debugPrint('ChatController: Fallback sync successful: ${messages.length} messages');
        }
        
        debugPrint('ChatController: Fallback message history load completed');
      }).catchError((fallbackError) {
        debugPrint('ChatController: FALLBACK ALSO FAILED: $fallbackError');
      });
    });
  }
  
  void _subscribeToMessages() {
    // Directly observe the ChatService observable messages
    ever(_chatService.messagesObservable, (List<ChatMessage> updatedMessages) {
      messages.value = List.from(updatedMessages); // Create a new list to trigger updates
      debugPrint('ChatController: Messages updated, count: ${updatedMessages.length}');
      
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
  
  void _syncInitialMessages() {
    // Sync any existing messages from ChatService to Controller
    final currentMessages = _chatService.messages;
    debugPrint('ChatController: _syncInitialMessages called. ChatService has ${currentMessages.length} messages');
    
    if (currentMessages.isNotEmpty) {
      messages.value = List.from(currentMessages);
      debugPrint('ChatController: Synced ${currentMessages.length} initial messages to UI');
      
      // Auto-scroll to bottom after syncing messages
      if (scrollController.hasClients) {
        Future.delayed(const Duration(milliseconds: 300), () {
          if (scrollController.hasClients) {
            scrollController.animateTo(
              scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      }
    } else {
      debugPrint('ChatController: No initial messages to sync');
    }
  }
  
  // User actions
  Future<void> connect() async {
    if (!isConnected.value) {
      await _chatService.connect();
      // Refresh messages after connecting to get any pending messages
      await _chatService.refreshMessages();
    }
  }

  Future<void> refreshMessages() async {
    debugPrint('ChatController: Refreshing complete message history...');
    
    // Load complete message history from the beginning
    await _chatService.loadMessageHistory();
    
    // Also check for any new messages that arrived while offline
    await _chatService.checkForNewMessages();
    
    // Sync the refreshed messages
    _syncInitialMessages();
    
    debugPrint('ChatController: Message refresh completed');
  }
  
  Future<void> sendMessage() async {
    final message = messageController.text.trim();
    if (message.isNotEmpty) {
      await _chatService.sendMessage(message);
      messageController.clear();
    }
  }
  
  Future<void> pickAndSendImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70, // Reduce quality to keep base64 size reasonable
    );
    
    if (image != null) {
      await _chatService.sendImageFromGallery();
    }
  }
  
  Future<void> takeAndSendPhoto() async {
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 70, // Reduce quality to keep base64 size reasonable
    );
    
    if (photo != null) {
      await _chatService.sendImageFromCamera();
    }
  }
}