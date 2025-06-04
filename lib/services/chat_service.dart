import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:park_wallet/data/models/chat_message.dart';
import 'package:image_picker/image_picker.dart';
import 'package:park_wallet/services/auth_service.dart';
import 'package:park_wallet/services/profile_service.dart';
import 'package:park_wallet/constants/endpoints.dart';
import 'package:http/http.dart' as http;

enum ConnectionStatus { connected, disconnected, connecting, error }

class ChatService extends GetxService {
  IO.Socket? _socket;
  final _messages = <ChatMessage>[].obs;
  final _connectionStatus = Rx<ConnectionStatus>(ConnectionStatus.disconnected);
  
  String? _currentUserId;
  String? _currentUserName;
  int? _adminUserId;
  Timer? _reconnectTimer;

  List<ChatMessage> get messages => _messages;
  RxList<ChatMessage> get messagesObservable => _messages;
  Stream<List<ChatMessage>> get messagesStream => _messages.stream;
  ConnectionStatus get connectionStatus => _connectionStatus.value;
  Stream<ConnectionStatus> get connectionStatusStream => _connectionStatus.stream;

  @override
  void onInit() {
    super.onInit();
    _initializeUserInfo();
  }

  @override
  void onClose() {
    _socket?.dispose();
    _reconnectTimer?.cancel();
    super.onClose();
  }

  Future<void> _initializeUserInfo() async {
    try {
      // Get user ID from AuthService (JWT token)
      final authService = Get.find<AuthService>();
      _currentUserId = authService.userId;
      
      try {
        final profileService = Get.find<ProfileService>();
        _currentUserName = profileService.userProfile?.name;
      } catch (e) {
        debugPrint('ChatService: ProfileService not found or profile not loaded: $e');
        _currentUserName = null;
      }
      
      debugPrint('ChatService: Current user ID: $_currentUserId');
      debugPrint('ChatService: Current user name: $_currentUserName');
      
      _adminUserId = 1;
      debugPrint('ChatService: Admin user ID set to: $_adminUserId');
      
    } catch (e) {
      debugPrint('ChatService: Error initializing user info: $e');
    }
  }

  Future<void> connect() async {
    if (_connectionStatus.value == ConnectionStatus.connected) {
      debugPrint('ChatService: Already connected');
      return;
    }

    if (_currentUserId == null) {
      debugPrint('ChatService: Cannot connect - current user ID is null');
      await _initializeUserInfo();
      if (_currentUserId == null) return;
    }

    try {
      _connectionStatus.value = ConnectionStatus.connecting;
      debugPrint('ChatService: Connecting to Socket.IO...');

      _socket = IO.io(
        Endpoints.socketEndpoint,
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .disableAutoConnect()
            .build(),
      );

      _setupSocketListeners();
      _socket!.connect();

    } catch (e) {
      debugPrint('ChatService: Error connecting: $e');
      _connectionStatus.value = ConnectionStatus.error;
      _scheduleReconnect();
    }
  }

  void _setupSocketListeners() {
    _socket!.onConnect((_) {
      debugPrint('ChatService: Connected to Socket.IO');
      _connectionStatus.value = ConnectionStatus.connected;
      _cancelReconnectTimer();
      
      _socket!.emit('user_online', {
        'userId': int.parse(_currentUserId!),
        'userName': _currentUserName,
      });

      _loadMessageHistory();
      _checkForNewMessages();
    });

    _socket!.onDisconnect((_) {
      debugPrint('ChatService: Disconnected from Socket.IO');
      _connectionStatus.value = ConnectionStatus.disconnected;
      _scheduleReconnect();
    });

    _socket!.onConnectError((error) {
      debugPrint('ChatService: Connection error: $error');
      _connectionStatus.value = ConnectionStatus.error;
      _scheduleReconnect();
    });

    _socket!.on('receive_message', (data) {
      debugPrint('ChatService: Received message: $data');
      try {
        final messageData = data as Map<String, dynamic>;
        
        String senderName;
        final senderUserId = messageData['senderUserId']?.toString() ?? '';
        if (senderUserId == _adminUserId.toString()) {
          senderName = 'Suporte';
        } else if (senderUserId == _currentUserId) {
          senderName = _currentUserName ?? 'Você';
        } else {
          senderName = messageData['senderName'] ?? 'Unknown';
        }
        
        final message = ChatMessage(
          id: messageData['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
          senderId: senderUserId,
          senderName: senderName,
          content: messageData['message'] ?? '',
          timestamp: DateTime.tryParse(messageData['createdAt'] ?? '') ?? DateTime.now(),
          type: MessageType.text,
          isMe: senderUserId == _currentUserId,
        );
        
        if (message.senderId == _adminUserId.toString() ||
            messageData['recipientUserId']?.toString() == _adminUserId.toString()) {
          _addMessageSafely(message);
        } else {
          debugPrint('ChatService: Message not added - not admin conversation');
        }
      } catch (e) {
        debugPrint('ChatService: Error processing received message: $e');
      }
    });

    _socket!.on('message_sent_ack', (data) {
      debugPrint('ChatService: Message sent acknowledgment: $data');
    });

    _socket!.on('error_message', (data) {
      debugPrint('ChatService: Socket error: $data');
    });
  }

  Future<void> _loadMessageHistory() async {
    debugPrint('ChatService: === STARTING MESSAGE HISTORY LOAD ===');
    
    if (_currentUserId == null || _adminUserId == null) {
      debugPrint('ChatService: User info not ready, initializing...');
      await _initializeUserInfo();
      
      if (_currentUserId == null || _adminUserId == null) {
        debugPrint('ChatService: CRITICAL: Cannot load history - user ID or admin ID is still null');
        debugPrint('ChatService: Current User ID: $_currentUserId, Admin ID: $_adminUserId');
        return;
      }
    }

    try {
      debugPrint('ChatService: Loading complete message history for user: $_currentUserId');
      debugPrint('ChatService: Admin ID set to: $_adminUserId');
      
      final history = await _getChatHistory(int.parse(_currentUserId!));
      debugPrint('ChatService: _getChatHistory returned: ${history?.length ?? 0} messages');
      
      if (history != null && history.isNotEmpty) {
        final adminId = _adminUserId.toString();
        debugPrint('ChatService: Filtering messages for conversation between user $_currentUserId and admin $adminId');
        
        final filteredMessages = history.where((message) {
          final senderUserId = message.senderId;
          final isUserMessage = senderUserId == _currentUserId;
          final isAdminMessage = senderUserId == adminId;
          final isRelevant = isUserMessage || isAdminMessage;
          
          debugPrint('ChatService: Message from ${message.senderName} (ID: $senderUserId): "${message.content}" - Relevant: $isRelevant');
          
          return isRelevant;
        }).toList();

        debugPrint('ChatService: After filtering: ${filteredMessages.length} relevant messages (from ${history.length} total)');
        
        final oldCount = _messages.length;
        _messages.clear();
        _messages.addAll(filteredMessages);
        _sortMessages();
        
        debugPrint('ChatService: Messages list updated: $oldCount -> ${_messages.length} messages');
        debugPrint('ChatService: Complete message history loaded successfully');
        
        if (_messages.isNotEmpty) {
          debugPrint('ChatService: FIRST MESSAGE: "${_messages.first.content}" from ${_messages.first.senderName} (${_messages.first.timestamp})');
          debugPrint('ChatService: LAST MESSAGE: "${_messages.last.content}" from ${_messages.last.senderName} (${_messages.last.timestamp})');
        }
      } else {
        debugPrint('ChatService: No message history found or empty response from API');
        _messages.clear();
        debugPrint('ChatService: Cleared messages list, current count: ${_messages.length}');
      }
      
      debugPrint('ChatService: === MESSAGE HISTORY LOAD COMPLETE ===');
    } catch (e) {
      debugPrint('ChatService: ERROR loading message history: $e');
      debugPrint('ChatService: Stack trace: ${StackTrace.current}');
    }
  }

  Future<List<ChatMessage>?> _getChatHistory(int userId) async {
    try {
      debugPrint('ChatService: === MAKING API CALL FOR CHAT HISTORY ===');
      debugPrint('ChatService: Requesting chat history for user ID: $userId');
      
      final authService = Get.find<AuthService>();
      final token = authService.token;
      
      if (token == null) {
        debugPrint('ChatService: CRITICAL: No token available for chat history');
        return null;
      }
      
      final url = '${Endpoints.chatApiEndpoint}/$userId';
      debugPrint('ChatService: Making GET request to: $url');
      debugPrint('ChatService: Using Authorization header with token: Bearer ${token.substring(0, 20)}...');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint('ChatService: API Response - Status Code: ${response.statusCode}');
      debugPrint('ChatService: API Response - Headers: ${response.headers}');
      debugPrint('ChatService: API Response - Body Length: ${response.body.length}');
      
      if (response.statusCode == 200) {
        if (response.body.isEmpty) {
          debugPrint('ChatService: API returned empty body');
          return [];
        }
        
        final bodyPreview = response.body.length > 500 ?
            '${response.body.substring(0, 500)}...' : response.body;
        debugPrint('ChatService: API Response Body Preview: $bodyPreview');
        
        final List<dynamic> messagesJson = json.decode(response.body);
        debugPrint('ChatService: Parsed ${messagesJson.length} message objects from JSON');
        
        final messages = <ChatMessage>[];
        for (int i = 0; i < messagesJson.length; i++) {
          try {
            final messageData = messagesJson[i];
            debugPrint('ChatService: Processing message $i: ID=${messageData['id']}, sender=${messageData['senderUserId']}, recipient=${messageData['recipientUserId']}');
            
            final message = ChatMessage.fromJson(messageData, userId.toString());
            messages.add(message);
            
            debugPrint('ChatService: ✓ Parsed message: "${message.content.substring(0, math.min(50, message.content.length))}..." from ${message.senderName}');
          } catch (e) {
            debugPrint('ChatService: ✗ Error parsing message $i: $e');
          }
        }
        
        debugPrint('ChatService: Successfully loaded ${messages.length} messages from API');
        return messages;
      } else if (response.statusCode == 401) {
        debugPrint('ChatService: AUTHENTICATION ERROR: Token may be invalid or expired');
        debugPrint('ChatService: Error response: ${response.body}');
        return null;
      } else {
        debugPrint('ChatService: API request failed with status ${response.statusCode}');
        debugPrint('ChatService: Error response body: ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('ChatService: EXCEPTION in _getChatHistory: $e');
      debugPrint('ChatService: Stack trace: ${StackTrace.current}');
      return null;
    }
  }

  Future<void> _checkForNewMessages() async {
    try {
      debugPrint('ChatService: Checking for new messages...');
      
      DateTime? lastMessageTime;
      if (_messages.isNotEmpty) {
        lastMessageTime = _messages.last.timestamp;
      }

      if (lastMessageTime != null) {
        final newHistory = await _getChatHistory(int.parse(_currentUserId!));
        
        if (newHistory != null) {
          final adminId = _adminUserId.toString();
          
          final newMessages = newHistory.where((message) {
            final isRelevantConversation = 
                (message.senderId == _currentUserId || message.senderId == adminId);
            
            final isAfterLastMessage = message.timestamp.isAfter(lastMessageTime!);
            
            return isRelevantConversation && isAfterLastMessage;
          }).toList();

          if (newMessages.isNotEmpty) {
            debugPrint('ChatService: Found ${newMessages.length} new messages while offline');
            
            for (final message in newMessages) {
              _addMessageSafely(message);
            }
          }
        }
      }
    } catch (e) {
      debugPrint('ChatService: Error checking for new messages: $e');
    }
  }

  void _sortMessages() {
    _messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }

  Future<void> sendMessage(String content) async {
    if (_socket == null || _connectionStatus.value != ConnectionStatus.connected) {
      debugPrint('ChatService: Cannot send message - not connected');
      return;
    }

    if (_adminUserId == null) {
      debugPrint('ChatService: Cannot send message - admin user ID is null');
      return;
    }

    try {
      final messageData = {
        'senderUserId': int.parse(_currentUserId!),
        'recipientUserId': _adminUserId,
        'message': content,
        'senderName': _currentUserName,
      };

      debugPrint('ChatService: Sending message: $messageData');
      _socket!.emit('send_message', messageData);

      final localMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        senderId: _currentUserId!,
        senderName: _currentUserName ?? 'You',
        content: content,
        timestamp: DateTime.now(),
        type: MessageType.text,
        isMe: true,
      );

      _addMessageSafely(localMessage);

    } catch (e) {
      debugPrint('ChatService: Error sending message: $e');
    }
  }

  void _scheduleReconnect() {
    _cancelReconnectTimer();
    debugPrint('ChatService: Scheduling reconnect in 5 seconds...');
    
    _reconnectTimer = Timer(const Duration(seconds: 5), () {
      if (_connectionStatus.value != ConnectionStatus.connected) {
        debugPrint('ChatService: Attempting to reconnect...');
        connect();
      }
    });
  }

  void _cancelReconnectTimer() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
  }

  void disconnect() {
    debugPrint('ChatService: Disconnecting...');
    _cancelReconnectTimer();
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _connectionStatus.value = ConnectionStatus.disconnected;
  }

  Future<void> refreshMessages() async {
    debugPrint('ChatService: Refreshing messages...');
    await _loadMessageHistory();
  }

  Future<void> initializeWithHistory() async {
    debugPrint('=== ChatService: STARTING INITIALIZATION WITH HISTORY ===');
    
    try {
      debugPrint('ChatService: Step 1 - Initializing user info...');
      await _initializeUserInfo();
      debugPrint('ChatService: User ID: $_currentUserId, Admin ID: $_adminUserId');
      
      debugPrint('ChatService: Step 2 - Loading message history...');
      await _loadMessageHistory();
      debugPrint('ChatService: Message history loaded. Current message count: ${_messages.length}');
      
      debugPrint('ChatService: Step 3 - Connecting to socket...');
      await connect();
      
      debugPrint('ChatService: Step 4 - Checking for new messages...');
      await _checkForNewMessages();
      
      debugPrint('=== ChatService: INITIALIZATION COMPLETE. Final message count: ${_messages.length} ===');
    } catch (e) {
      debugPrint('ChatService: ERROR during initialization: $e');
      rethrow;
    }
  }

  Future<void> loadMessageHistory() async {
    await _loadMessageHistory();
  }

  Future<void> checkForNewMessages() async {
    await _checkForNewMessages();
  }

  Future<void> onAppResumed() async {
    debugPrint('ChatService: === APP RESUMED - CHECKING FOR UPDATES ===');
    
    debugPrint('ChatService: Force reloading complete message history...');
    await _loadMessageHistory();
    
    if (_connectionStatus.value != ConnectionStatus.connected) {
      debugPrint('ChatService: Not connected, attempting to reconnect...');
      await connect();
    } else {
      debugPrint('ChatService: Already connected, checking for new messages...');
      await _checkForNewMessages();
    }
    
    debugPrint('ChatService: App resume handling complete. Current message count: ${_messages.length}');
  }

  Future<void> sendImageFromCamera() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);
    
    if (image != null) {
      await _sendImageMessage(image);
    }
  }

  Future<void> sendImageFromGallery() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      await _sendImageMessage(image);
    }
  }

  Future<void> _sendImageMessage(XFile imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);
      
      await sendMessage('[IMAGE]:$base64Image');
    } catch (e) {
      debugPrint('ChatService: Error sending image: $e');
    }
  }

  bool get isConnected => _connectionStatus.value == ConnectionStatus.connected;
  bool get isConnecting => _connectionStatus.value == ConnectionStatus.connecting;
  bool get hasError => _connectionStatus.value == ConnectionStatus.error;

  String getConnectionStatusText() {
    switch (_connectionStatus.value) {
      case ConnectionStatus.connected:
        return 'Conectado ao suporte';
      case ConnectionStatus.connecting:
        return 'Conectando...';
      case ConnectionStatus.disconnected:
        return 'Desconectado';
      case ConnectionStatus.error:
        return 'Erro de conexão';
    }
  }

  void _addMessageSafely(ChatMessage message) {
    if (!_messages.any((m) => m.id == message.id)) {
      _messages.add(message);
      _sortMessages();
      debugPrint('ChatService: Added unique message: ${message.content}');
      debugPrint('ChatService: Total messages: ${_messages.length}');
    } else {
      debugPrint('ChatService: Message already exists, skipping: ${message.content}');
    }
  }

  Future<void> forceReloadHistory() async {
    debugPrint('ChatService: === FORCE RELOAD HISTORY (DEBUG) ===');
    await _loadMessageHistory();
    debugPrint('ChatService: Force reload complete. Message count: ${_messages.length}');
  }

  void printDebugInfo() {
    debugPrint('ChatService: === DEBUG INFO ===');
    debugPrint('ChatService: Current User ID: $_currentUserId');
    debugPrint('ChatService: Admin User ID: $_adminUserId');
    debugPrint('ChatService: Connection Status: $_connectionStatus');
    debugPrint('ChatService: Message Count: ${_messages.length}');
    debugPrint('ChatService: Socket Connected: ${_socket?.connected ?? false}');
    
    if (_messages.isNotEmpty) {
      debugPrint('ChatService: === MESSAGE LIST ===');
      for (int i = 0; i < _messages.length; i++) {
        final msg = _messages[i];
        debugPrint('ChatService: [$i] "${msg.content}" from ${msg.senderName} (ID: ${msg.senderId}) at ${msg.timestamp}');
      }
    }
    debugPrint('ChatService: === END DEBUG INFO ===');
  }

  Future<void> debugChatAPI() async {
    debugPrint('=== CHAT API DEBUG TEST ===');
    
    try {
      await _initializeUserInfo();
      debugPrint('DEBUG: User ID: $_currentUserId');
      debugPrint('DEBUG: Admin ID: $_adminUserId');
      
      final authService = Get.find<AuthService>();
      final token = authService.token;
      debugPrint('DEBUG: Token available: ${token != null}');
      if (token != null) {
        debugPrint('DEBUG: Token preview: ${token.substring(0, math.min(30, token.length))}...');
      }
      
      if (_currentUserId != null) {
        debugPrint('DEBUG: Testing API call...');
        final result = await _getChatHistory(int.parse(_currentUserId!));
        debugPrint('DEBUG: API result: ${result?.length ?? 0} messages');
        
        if (result != null && result.isNotEmpty) {
          debugPrint('DEBUG: Sample message: ${result.first.content}');
        }
      }
      
    } catch (e) {
      debugPrint('DEBUG: Error in debug test: $e');
    }
    
    debugPrint('=== CHAT API DEBUG TEST COMPLETE ===');
  }
}
