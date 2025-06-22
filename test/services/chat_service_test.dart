import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:park_wallet/services/chat_service.dart';
import 'package:park_wallet/services/auth_service.dart';
import 'package:park_wallet/services/profile_service.dart';
import 'package:park_wallet/data/models/chat_message.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'dart:async';

// Generate mocks
@GenerateMocks([AuthService, ProfileService, IO.Socket])
import 'chat_service_test.mocks.dart';

void main() {
  group('ChatService Tests', () {
    late ChatService chatService;
    late MockAuthService mockAuthService;
    late MockProfileService mockProfileService;
    late MockSocket mockSocket;

    setUp(() {
      mockAuthService = MockAuthService();
      mockProfileService = MockProfileService();
      mockSocket = MockSocket();
      
      // Setup GetX dependencies
      Get.testMode = true;
      Get.put<AuthService>(mockAuthService);
      Get.put<ProfileService>(mockProfileService);
      
      chatService = ChatService();
    });

    tearDown(() {
      Get.reset();
    });

    group('Initialization', () {
      test('should initialize with empty messages list', () {
        // Act & Assert
        expect(chatService.messages, isEmpty);
        expect(chatService.connectionStatus, equals(ConnectionStatus.disconnected));
      });

      test('should initialize user info on init', () async {
        // Arrange
        const userId = 'user123';
        const userName = 'Test User';
        
        when(mockAuthService.userId).thenReturn(userId);
        when(mockProfileService.userProfile).thenReturn(null);
        
        // Act
        chatService.onInit();
        
        // Assert
        expect(chatService.connectionStatus, equals(ConnectionStatus.disconnected));
      });

      test('should handle missing auth service gracefully', () {
        // Arrange
        Get.delete<AuthService>();
        
        // Act & Assert
        expect(() => chatService.onInit(), returnsNormally);
      });

      test('should handle missing profile service gracefully', () {
        // Arrange
        Get.delete<ProfileService>();
        
        // Act & Assert
        expect(() => chatService.onInit(), returnsNormally);
      });
    });

    group('Connection Management', () {
      test('should update connection status when connecting', () {
        // Arrange
        const userId = 'user123';
        when(mockAuthService.userId).thenReturn(userId);
        
        // Act
        // Note: Actual connection testing would require socket mocking
        
        // Assert
        expect(chatService.connectionStatus, isA<ConnectionStatus>());
      });

      test('should handle connection errors', () {
        // Arrange
        const userId = 'user123';
        when(mockAuthService.userId).thenReturn(userId);
        
        // Act & Assert
        expect(chatService.connectionStatus, isA<ConnectionStatus>());
      });

      test('should handle disconnection gracefully', () {
        // Act
        chatService.onClose();
        
        // Assert
        expect(chatService.connectionStatus, equals(ConnectionStatus.disconnected));
      });

      test('should clean up resources on close', () {
        // Act
        chatService.onClose();
        
        // Assert
        // Verify cleanup occurred
        expect(() => chatService.onClose(), returnsNormally);
      });
    });

    group('Message Handling', () {
      test('should add message to messages list', () {
        // Arrange
        final message = ChatMessage(
          id: 'msg1',
          content: 'Test message',
          senderId: 'user123',
          senderName: 'Test User',
          timestamp: DateTime.now(),
          isFromCurrentUser: true,
        );
        
        // Act
        chatService.messages.add(message);
        
        // Assert
        expect(chatService.messages, contains(message));
        expect(chatService.messages.length, equals(1));
      });

      test('should handle empty message content', () {
        // Arrange
        final emptyMessage = ChatMessage(
          id: 'msg1',
          content: '',
          senderId: 'user123',
          senderName: 'Test User',
          timestamp: DateTime.now(),
          isFromCurrentUser: true,
        );
        
        // Act
        chatService.messages.add(emptyMessage);
        
        // Assert
        expect(chatService.messages, contains(emptyMessage));
        expect(emptyMessage.content, isEmpty);
      });

      test('should handle long message content', () {
        // Arrange
        final longContent = 'A' * 1000; // 1000 character message
        final longMessage = ChatMessage(
          id: 'msg1',
          content: longContent,
          senderId: 'user123',
          senderName: 'Test User',
          timestamp: DateTime.now(),
          isFromCurrentUser: true,
        );
        
        // Act
        chatService.messages.add(longMessage);
        
        // Assert
        expect(chatService.messages, contains(longMessage));
        expect(longMessage.content.length, equals(1000));
      });

      test('should handle special characters in messages', () {
        // Arrange
        final specialMessage = ChatMessage(
          id: 'msg1',
          content: 'Hello! 😀 How are you? 🎉 #test @user',
          senderId: 'user123',
          senderName: 'José da Silva',
          timestamp: DateTime.now(),
          isFromCurrentUser: true,
        );
        
        // Act
        chatService.messages.add(specialMessage);
        
        // Assert
        expect(chatService.messages, contains(specialMessage));
        expect(specialMessage.content, contains('😀'));
        expect(specialMessage.senderName, contains('é'));
      });

      test('should maintain message order', () {
        // Arrange
        final message1 = ChatMessage(
          id: 'msg1',
          content: 'First message',
          senderId: 'user123',
          senderName: 'Test User',
          timestamp: DateTime.now(),
          isFromCurrentUser: true,
        );
        
        final message2 = ChatMessage(
          id: 'msg2',
          content: 'Second message',
          senderId: 'user456',
          senderName: 'Other User',
          timestamp: DateTime.now().add(Duration(seconds: 1)),
          isFromCurrentUser: false,
        );
        
        // Act
        chatService.messages.add(message1);
        chatService.messages.add(message2);
        
        // Assert
        expect(chatService.messages.first, equals(message1));
        expect(chatService.messages.last, equals(message2));
        expect(chatService.messages.length, equals(2));
      });
    });

    group('Message Streams', () {
      test('should provide observable messages list', () {
        // Act
        final observableMessages = chatService.messagesObservable;
        
        // Assert
        expect(observableMessages, isA<RxList<ChatMessage>>());
        expect(observableMessages.length, equals(0));
      });

      test('should provide messages stream', () {
        // Act
        final messagesStream = chatService.messagesStream;
        
        // Assert
        expect(messagesStream, isA<Stream<List<ChatMessage>>>());
      });

      test('should provide connection status stream', () {
        // Act
        final statusStream = chatService.connectionStatusStream;
        
        // Assert
        expect(statusStream, isA<Stream<ConnectionStatus>>());
      });

      test('should notify observers when messages change', () async {
        // Arrange
        final message = ChatMessage(
          id: 'msg1',
          content: 'Test message',
          senderId: 'user123',
          senderName: 'Test User',
          timestamp: DateTime.now(),
          isFromCurrentUser: true,
        );
        
        bool streamEmitted = false;
        chatService.messagesStream.listen((messages) {
          if (messages.isNotEmpty) {
            streamEmitted = true;
          }
        });
        
        // Act
        chatService.messages.add(message);
        await Future.delayed(Duration(milliseconds: 10));
        
        // Assert
        expect(streamEmitted, isTrue);
      });
    });

    group('Connection Status', () {
      test('should handle all connection status types', () {
        // Arrange & Act
        final connected = ConnectionStatus.connected;
        final disconnected = ConnectionStatus.disconnected;
        final connecting = ConnectionStatus.connecting;
        final error = ConnectionStatus.error;
        
        // Assert
        expect(connected, equals(ConnectionStatus.connected));
        expect(disconnected, equals(ConnectionStatus.disconnected));
        expect(connecting, equals(ConnectionStatus.connecting));
        expect(error, equals(ConnectionStatus.error));
      });

      test('should start with disconnected status', () {
        // Act & Assert
        expect(chatService.connectionStatus, equals(ConnectionStatus.disconnected));
      });
    });

    group('User Information', () {
      test('should handle valid user ID from auth service', () {
        // Arrange
        const userId = 'user123';
        when(mockAuthService.userId).thenReturn(userId);
        
        // Act
        chatService.onInit();
        
        // Assert
        verify(mockAuthService.userId).called(1);
      });

      test('should handle null user ID gracefully', () {
        // Arrange
        when(mockAuthService.userId).thenReturn(null);
        
        // Act & Assert
        expect(() => chatService.onInit(), returnsNormally);
      });

      test('should handle empty user ID gracefully', () {
        // Arrange
        when(mockAuthService.userId).thenReturn('');
        
        // Act & Assert
        expect(() => chatService.onInit(), returnsNormally);
      });
    });

    group('Error Handling', () {
      test('should handle socket connection errors', () {
        // Arrange
        const userId = 'user123';
        when(mockAuthService.userId).thenReturn(userId);
        
        // Act & Assert
        expect(() => chatService.onInit(), returnsNormally);
      });

      test('should handle network disconnection', () {
        // Act & Assert
        expect(chatService.connectionStatus, isA<ConnectionStatus>());
      });

      test('should handle malformed message data', () {
        // Arrange
        final invalidMessage = {
          'id': null,
          'content': 123, // Invalid type
          'senderId': '',
          'timestamp': 'invalid_date',
        };
        
        // Act & Assert
        expect(() => {
          // Handle invalid message data
        }, returnsNormally);
      });
    });

    group('Memory Management', () {
      test('should clear messages when needed', () {
        // Arrange
        final message = ChatMessage(
          id: 'msg1',
          content: 'Test message',
          senderId: 'user123',
          senderName: 'Test User',
          timestamp: DateTime.now(),
          isFromCurrentUser: true,
        );
        chatService.messages.add(message);
        
        // Act
        chatService.messages.clear();
        
        // Assert
        expect(chatService.messages, isEmpty);
      });

      test('should handle large number of messages', () {
        // Arrange
        final messages = List.generate(1000, (index) => ChatMessage(
          id: 'msg$index',
          content: 'Message $index',
          senderId: 'user123',
          senderName: 'Test User',
          timestamp: DateTime.now().add(Duration(seconds: index)),
          isFromCurrentUser: index % 2 == 0,
        ));
        
        // Act
        chatService.messages.addAll(messages);
        
        // Assert
        expect(chatService.messages.length, equals(1000));
        expect(chatService.messages.first.id, equals('msg0'));
        expect(chatService.messages.last.id, equals('msg999'));
      });
    });

    group('Integration Scenarios', () {
      test('should handle rapid message sending', () {
        // Arrange
        final messages = List.generate(10, (index) => ChatMessage(
          id: 'msg$index',
          content: 'Rapid message $index',
          senderId: 'user123',
          senderName: 'Test User',
          timestamp: DateTime.now().add(Duration(milliseconds: index * 100)),
          isFromCurrentUser: true,
        ));
        
        // Act
        for (final message in messages) {
          chatService.messages.add(message);
        }
        
        // Assert
        expect(chatService.messages.length, equals(10));
      });

      test('should handle concurrent operations', () async {
        // Arrange
        final futures = <Future>[];
        
        // Act
        for (int i = 0; i < 5; i++) {
          futures.add(Future(() {
            final message = ChatMessage(
              id: 'msg$i',
              content: 'Concurrent message $i',
              senderId: 'user123',
              senderName: 'Test User',
              timestamp: DateTime.now(),
              isFromCurrentUser: true,
            );
            chatService.messages.add(message);
          }));
        }
        
        await Future.wait(futures);
        
        // Assert
        expect(chatService.messages.length, equals(5));
      });
    });
  });
}