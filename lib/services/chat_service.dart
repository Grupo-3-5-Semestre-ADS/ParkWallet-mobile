import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:park_wallet/data/models/chat_message.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ChatService extends GetxService {
  WebSocketChannel? _channel;
  final _messages = <ChatMessage>[].obs;
  final _connectionStatus = Rx<ConnectionStatus>(ConnectionStatus.disconnected);
  final _storage = const FlutterSecureStorage();
  final String _userId = '';
  final String _userName = '';

  // Public getters
  List<ChatMessage> get messages => _messages;
  Stream<List<ChatMessage>> get messagesStream => _messages.stream;
  ConnectionStatus get connectionStatus => _connectionStatus.value;
  Stream<ConnectionStatus> get connectionStatusStream => _connectionStatus.stream;

  // WebSocket connection methods
  Future<void> connect(String url) async {
    if (_connectionStatus.value == ConnectionStatus.connected) {
      return;
    }

    try {
      _connectionStatus.value = ConnectionStatus.connecting;
      
      // Get user info from secure storage
      final userId = await _storage.read(key: 'userId');
      final userName = await _storage.read(key: 'userName');
      
      // Create WebSocket connection
      _channel = WebSocketChannel.connect(Uri.parse(url));
      
      // Listen for messages
      _channel!.stream.listen(
        (message) {
          final data = jsonDecode(message);
          final chatMessage = ChatMessage.fromJson(data, userId ?? '');
          _messages.add(chatMessage);
        },
        onError: (error) {
          debugPrint('WebSocket error: $error');
          _connectionStatus.value = ConnectionStatus.error;
          _reconnect(url);
        },
        onDone: () {
          debugPrint('WebSocket connection closed');
          _connectionStatus.value = ConnectionStatus.disconnected;
          _reconnect(url);
        },
      );
      
      _connectionStatus.value = ConnectionStatus.connected;
      
      // Send connection message
      _sendSystemMessage('$userName connected');
    } catch (e) {
      debugPrint('Error connecting to WebSocket: $e');
      _connectionStatus.value = ConnectionStatus.error;
      _reconnect(url);
    }
  }
  
  Future<void> _reconnect(String url) async {
    if (_connectionStatus.value != ConnectionStatus.reconnecting) {
      _connectionStatus.value = ConnectionStatus.reconnecting;
      
      // Wait 5 seconds before reconnecting
      await Future.delayed(const Duration(seconds: 5));
      await connect(url);
    }
  }

  void disconnect() {
    if (_channel != null) {
      _channel!.sink.close();
      _channel = null;
      _connectionStatus.value = ConnectionStatus.disconnected;
    }
  }
  
  // Message sending methods
  Future<void> sendTextMessage(String content) async {
    if (_connectionStatus.value != ConnectionStatus.connected || content.trim().isEmpty) {
      return;
    }
    
    final userId = await _storage.read(key: 'userId') ?? 'unknown';
    final userName = await _storage.read(key: 'userName') ?? 'User';
    
    final message = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'senderId': userId,
      'senderName': userName,
      'content': content,
      'timestamp': DateTime.now().toIso8601String(),
      'type': 'text'
    };
    
    _channel!.sink.add(jsonEncode(message));
  }
  
  Future<void> sendImageMessage(XFile imageFile) async {
    if (_connectionStatus.value != ConnectionStatus.connected) {
      return;
    }
    
    try {
      // Read image file as bytes
      final bytes = await imageFile.readAsBytes();
      
      // Convert to base64
      final base64Image = base64Encode(bytes);
      
      // Get user info
      final userId = await _storage.read(key: 'userId') ?? 'unknown';
      final userName = await _storage.read(key: 'userName') ?? 'User';
      
      // Create message
      final message = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'senderId': userId,
        'senderName': userName,
        'content': base64Image,
        'timestamp': DateTime.now().toIso8601String(),
        'type': 'image'
      };
      
      _channel!.sink.add(jsonEncode(message));
    } catch (e) {
      debugPrint('Error sending image: $e');
    }
  }
  
  Future<void> _sendSystemMessage(String content) async {
    if (_channel == null) return;
    
    final message = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'senderId': 'system',
      'senderName': 'System',
      'content': content,
      'timestamp': DateTime.now().toIso8601String(),
      'type': 'system'
    };
    
    _channel!.sink.add(jsonEncode(message));
  }
  
  // Helper methods for image handling
  Future<Uint8List?> base64ToImage(String base64String) async {
    try {
      return base64Decode(base64String);
    } catch (e) {
      debugPrint('Error decoding base64 image: $e');
      return null;
    }
  }
}

enum ConnectionStatus {
  disconnected,
  connecting,
  connected,
  reconnecting,
  error
}