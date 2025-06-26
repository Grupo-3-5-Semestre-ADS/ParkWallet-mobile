import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
  
  @override
  void onInit() {
    super.onInit();
    _chatService = Get.find<ChatService>();
    
    WidgetsBinding.instance.addObserver(this);
    
    _initChatService();
    _subscribeToMessages();
    _subscribeToConnectionStatus();
    
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
      _chatService.onAppResumed();
    }
  }
  
  void _initChatService() {
    debugPrint('=== ChatController: STARTING CHAT INITIALIZATION ===');
    isLoading.value = true;
    
    _chatService.initializeWithHistory().then((_) {
      debugPrint('ChatController: Chat service initialization completed successfully');
      
      final currentMessages = _chatService.messages;
      debugPrint('ChatController: Messages available after init: ${currentMessages.length}');
      
      if (currentMessages.isNotEmpty) {
        messages.value = List.from(currentMessages);
        debugPrint('ChatController: Successfully synced ${messages.length} messages to UI');
        
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
    ever(_chatService.messagesObservable, (List<ChatMessage> updatedMessages) {
      messages.value = List.from(updatedMessages);
      debugPrint('ChatController: Messages updated, count: ${updatedMessages.length}');
      
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
    final currentMessages = _chatService.messages;
    debugPrint('ChatController: _syncInitialMessages called. ChatService has ${currentMessages.length} messages');
    
    if (currentMessages.isNotEmpty) {
      messages.value = List.from(currentMessages);
      debugPrint('ChatController: Synced ${currentMessages.length} initial messages to UI');
      
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
  
  Future<void> connect() async {
    if (!isConnected.value) {
      await _chatService.connect();
      await _chatService.refreshMessages();
    }
  }

  Future<void> refreshMessages() async {
    debugPrint('ChatController: Refreshing complete message history...');
    
    await _chatService.loadMessageHistory();
    
    await _chatService.checkForNewMessages();
    
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
}