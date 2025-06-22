import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:park_wallet/data/models/chat_message.dart';
import 'package:park_wallet/pages/chat/controllers/chat_controller.dart';
import 'package:park_wallet/services/chat_service.dart';

import 'chat_controller_test.mocks.dart';

@GenerateMocks([ChatService])
void main() {
  group('ChatController Tests', () {
    late ChatController chatController;
    late MockChatService mockChatService;

    setUp(() {
      Get.testMode = true;
      mockChatService = MockChatService();
      
      chatController = ChatController();
      chatController.chatService = mockChatService;
    });

    tearDown(() {
      Get.reset();
    });

    group('Initialization Tests', () {
      test('should initialize with default values', () {
        expect(chatController.messages, isEmpty);
        expect(chatController.isConnected.value, isFalse);
        expect(chatController.isLoading.value, isFalse);
        expect(chatController.isSending.value, isFalse);
        expect(chatController.messageController.text, isEmpty);
      });

      test('should connect to chat service on init', () async {
        // Arrange
        when(mockChatService.connect())
            .thenAnswer((_) async => true);
        when(mockChatService.getMessages())
            .thenAnswer((_) async => <ChatMessage>[]);
        
        // Act
        chatController.onInit();
        await Future.delayed(const Duration(milliseconds: 100));
        
        // Assert
        verify(mockChatService.connect()).called(1);
        verify(mockChatService.getMessages()).called(1);
        expect(chatController.isConnected.value, isTrue);
        expect(chatController.isLoading.value, isFalse);
      });

      test('should load existing messages on init', () async {
        // Arrange
        final existingMessages = [
          ChatMessage(
            id: '1',
            content: 'Hello',
            senderId: 'user1',
            senderName: 'User 1',
            timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
            isFromCurrentUser: false,
          ),
          ChatMessage(
            id: '2',
            content: 'Hi there!',
            senderId: 'user2',
            senderName: 'User 2',
            timestamp: DateTime.now().subtract(const Duration(minutes: 3)),
            isFromCurrentUser: true,
          ),
        ];
        
        when(mockChatService.connect())
            .thenAnswer((_) async => true);
        when(mockChatService.getMessages())
            .thenAnswer((_) async => existingMessages);
        
        // Act
        chatController.onInit();
        await Future.delayed(const Duration(milliseconds: 100));
        
        // Assert
        verify(mockChatService.connect()).called(1);
        verify(mockChatService.getMessages()).called(1);
        expect(chatController.messages.length, equals(2));
        expect(chatController.messages[0].content, equals('Hello'));
        expect(chatController.messages[1].content, equals('Hi there!'));
      });

      test('should handle connection failure on init', () async {
        // Arrange
        when(mockChatService.connect())
            .thenAnswer((_) async => false);
        
        // Act
        chatController.onInit();
        await Future.delayed(const Duration(milliseconds: 100));
        
        // Assert
        verify(mockChatService.connect()).called(1);
        verifyNever(mockChatService.getMessages());
        expect(chatController.isConnected.value, isFalse);
        expect(chatController.isLoading.value, isFalse);
      });

      test('should handle connection error on init', () async {
        // Arrange
        when(mockChatService.connect())
            .thenThrow(Exception('Connection failed'));
        
        // Act
        chatController.onInit();
        await Future.delayed(const Duration(milliseconds: 100));
        
        // Assert
        verify(mockChatService.connect()).called(1);
        verifyNever(mockChatService.getMessages());
        expect(chatController.isConnected.value, isFalse);
        expect(chatController.isLoading.value, isFalse);
      });
    });

    group('Send Message Tests', () {
      test('should send message successfully', () async {
        // Arrange
        chatController.messageController.text = 'Test message';
        chatController.isConnected.value = true;
        
        final sentMessage = ChatMessage(
          id: '3',
          content: 'Test message',
          senderId: 'currentUser',
          senderName: 'Current User',
          timestamp: DateTime.now(),
          isFromCurrentUser: true,
        );
        
        when(mockChatService.sendMessage('Test message'))
            .thenAnswer((_) async => sentMessage);
        
        // Act
        await chatController.sendMessage();
        
        // Assert
        verify(mockChatService.sendMessage('Test message')).called(1);
        expect(chatController.messages.length, equals(1));
        expect(chatController.messages.first.content, equals('Test message'));
        expect(chatController.messageController.text, isEmpty);
        expect(chatController.isSending.value, isFalse);
      });

      test('should handle sending state correctly', () async {
        // Arrange
        chatController.messageController.text = 'Test message';
        chatController.isConnected.value = true;
        
        final sentMessage = ChatMessage(
          id: '4',
          content: 'Test message',
          senderId: 'currentUser',
          senderName: 'Current User',
          timestamp: DateTime.now(),
          isFromCurrentUser: true,
        );
        
        when(mockChatService.sendMessage('Test message'))
            .thenAnswer((_) async {
          await Future.delayed(const Duration(milliseconds: 50));
          return sentMessage;
        });
        
        // Act
        final future = chatController.sendMessage();
        
        // Assert sending state
        expect(chatController.isSending.value, isTrue);
        
        await future;
        
        // Assert final state
        expect(chatController.isSending.value, isFalse);
        expect(chatController.messages.length, equals(1));
      });

      test('should not send empty message', () async {
        // Arrange
        chatController.messageController.text = '';
        chatController.isConnected.value = true;
        
        // Act
        await chatController.sendMessage();
        
        // Assert
        verifyNever(mockChatService.sendMessage(any));
        expect(chatController.messages, isEmpty);
        expect(chatController.isSending.value, isFalse);
      });

      test('should not send whitespace-only message', () async {
        // Arrange
        chatController.messageController.text = '   \n\t   ';
        chatController.isConnected.value = true;
        
        // Act
        await chatController.sendMessage();
        
        // Assert
        verifyNever(mockChatService.sendMessage(any));
        expect(chatController.messages, isEmpty);
        expect(chatController.isSending.value, isFalse);
      });

      test('should not send message when not connected', () async {
        // Arrange
        chatController.messageController.text = 'Test message';
        chatController.isConnected.value = false;
        
        // Act
        await chatController.sendMessage();
        
        // Assert
        verifyNever(mockChatService.sendMessage(any));
        expect(chatController.messages, isEmpty);
        expect(chatController.isSending.value, isFalse);
      });

      test('should handle send message error', () async {
        // Arrange
        chatController.messageController.text = 'Test message';
        chatController.isConnected.value = true;
        
        when(mockChatService.sendMessage('Test message'))
            .thenThrow(Exception('Send failed'));
        
        // Act
        await chatController.sendMessage();
        
        // Assert
        verify(mockChatService.sendMessage('Test message')).called(1);
        expect(chatController.messages, isEmpty);
        expect(chatController.isSending.value, isFalse);
        // Message should remain in text field on error
        expect(chatController.messageController.text, equals('Test message'));
      });

      test('should trim message content before sending', () async {
        // Arrange
        chatController.messageController.text = '  Test message  ';
        chatController.isConnected.value = true;
        
        final sentMessage = ChatMessage(
          id: '5',
          content: 'Test message',
          senderId: 'currentUser',
          senderName: 'Current User',
          timestamp: DateTime.now(),
          isFromCurrentUser: true,
        );
        
        when(mockChatService.sendMessage('Test message'))
            .thenAnswer((_) async => sentMessage);
        
        // Act
        await chatController.sendMessage();
        
        // Assert
        verify(mockChatService.sendMessage('Test message')).called(1);
        expect(chatController.messages.length, equals(1));
        expect(chatController.messages.first.content, equals('Test message'));
      });

      test('should handle long messages', () async {
        // Arrange
        final longMessage = 'A' * 1000;
        chatController.messageController.text = longMessage;
        chatController.isConnected.value = true;
        
        final sentMessage = ChatMessage(
          id: '6',
          content: longMessage,
          senderId: 'currentUser',
          senderName: 'Current User',
          timestamp: DateTime.now(),
          isFromCurrentUser: true,
        );
        
        when(mockChatService.sendMessage(longMessage))
            .thenAnswer((_) async => sentMessage);
        
        // Act
        await chatController.sendMessage();
        
        // Assert
        verify(mockChatService.sendMessage(longMessage)).called(1);
        expect(chatController.messages.length, equals(1));
        expect(chatController.messages.first.content, equals(longMessage));
      });

      test('should handle special characters in messages', () async {
        // Arrange
        final specialMessage = 'Hello! 😀 How are you? 🎉 #test @user';
        chatController.messageController.text = specialMessage;
        chatController.isConnected.value = true;
        
        final sentMessage = ChatMessage(
          id: '7',
          content: specialMessage,
          senderId: 'currentUser',
          senderName: 'Current User',
          timestamp: DateTime.now(),
          isFromCurrentUser: true,
        );
        
        when(mockChatService.sendMessage(specialMessage))
            .thenAnswer((_) async => sentMessage);
        
        // Act
        await chatController.sendMessage();
        
        // Assert
        verify(mockChatService.sendMessage(specialMessage)).called(1);
        expect(chatController.messages.length, equals(1));
        expect(chatController.messages.first.content, equals(specialMessage));
      });
    });

    group('Receive Message Tests', () {
      test('should receive and add new message', () {
        // Arrange
        final newMessage = ChatMessage(
          id: '8',
          content: 'Received message',
          senderId: 'otherUser',
          senderName: 'Other User',
          timestamp: DateTime.now(),
          isFromCurrentUser: false,
        );
        
        // Act
        chatController.onMessageReceived(newMessage);
        
        // Assert
        expect(chatController.messages.length, equals(1));
        expect(chatController.messages.first.content, equals('Received message'));
        expect(chatController.messages.first.isFromCurrentUser, isFalse);
      });

      test('should maintain message order when receiving multiple messages', () {
        // Arrange
        final message1 = ChatMessage(
          id: '9',
          content: 'First message',
          senderId: 'user1',
          senderName: 'User 1',
          timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
          isFromCurrentUser: false,
        );
        
        final message2 = ChatMessage(
          id: '10',
          content: 'Second message',
          senderId: 'user2',
          senderName: 'User 2',
          timestamp: DateTime.now().subtract(const Duration(minutes: 1)),
          isFromCurrentUser: false,
        );
        
        final message3 = ChatMessage(
          id: '11',
          content: 'Third message',
          senderId: 'user3',
          senderName: 'User 3',
          timestamp: DateTime.now(),
          isFromCurrentUser: false,
        );
        
        // Act
        chatController.onMessageReceived(message1);
        chatController.onMessageReceived(message2);
        chatController.onMessageReceived(message3);
        
        // Assert
        expect(chatController.messages.length, equals(3));
        expect(chatController.messages[0].content, equals('First message'));
        expect(chatController.messages[1].content, equals('Second message'));
        expect(chatController.messages[2].content, equals('Third message'));
      });

      test('should handle duplicate message IDs', () {
        // Arrange
        final message1 = ChatMessage(
          id: '12',
          content: 'Original message',
          senderId: 'user1',
          senderName: 'User 1',
          timestamp: DateTime.now(),
          isFromCurrentUser: false,
        );
        
        final message2 = ChatMessage(
          id: '12', // Same ID
          content: 'Duplicate message',
          senderId: 'user1',
          senderName: 'User 1',
          timestamp: DateTime.now(),
          isFromCurrentUser: false,
        );
        
        // Act
        chatController.onMessageReceived(message1);
        chatController.onMessageReceived(message2);
        
        // Assert - should not add duplicate
        expect(chatController.messages.length, equals(1));
        expect(chatController.messages.first.content, equals('Original message'));
      });
    });

    group('Connection Management Tests', () {
      test('should connect successfully', () async {
        // Arrange
        when(mockChatService.connect())
            .thenAnswer((_) async => true);
        
        // Act
        await chatController.connect();
        
        // Assert
        verify(mockChatService.connect()).called(1);
        expect(chatController.isConnected.value, isTrue);
      });

      test('should handle connection failure', () async {
        // Arrange
        when(mockChatService.connect())
            .thenAnswer((_) async => false);
        
        // Act
        await chatController.connect();
        
        // Assert
        verify(mockChatService.connect()).called(1);
        expect(chatController.isConnected.value, isFalse);
      });

      test('should disconnect successfully', () async {
        // Arrange
        chatController.isConnected.value = true;
        when(mockChatService.disconnect())
            .thenAnswer((_) async {});
        
        // Act
        await chatController.disconnect();
        
        // Assert
        verify(mockChatService.disconnect()).called(1);
        expect(chatController.isConnected.value, isFalse);
      });

      test('should handle disconnect error', () async {
        // Arrange
        chatController.isConnected.value = true;
        when(mockChatService.disconnect())
            .thenThrow(Exception('Disconnect failed'));
        
        // Act
        await chatController.disconnect();
        
        // Assert
        verify(mockChatService.disconnect()).called(1);
        expect(chatController.isConnected.value, isFalse);
      });

      test('should reconnect after connection loss', () async {
        // Arrange
        chatController.isConnected.value = true;
        when(mockChatService.connect())
            .thenAnswer((_) async => true);
        
        // Act
        chatController.onConnectionLost();
        await Future.delayed(const Duration(milliseconds: 100));
        
        // Assert
        expect(chatController.isConnected.value, isFalse);
        // Reconnection logic would be implemented here
      });
    });

    group('Lifecycle Tests', () {
      test('should disconnect on close', () async {
        // Arrange
        chatController.isConnected.value = true;
        when(mockChatService.disconnect())
            .thenAnswer((_) async {});
        
        // Act
        chatController.onClose();
        
        // Assert
        verify(mockChatService.disconnect()).called(1);
        expect(chatController.messageController.text, isEmpty);
      });

      test('should dispose text controller on close', () {
        // Arrange
        chatController.messageController.text = 'Test';
        when(mockChatService.disconnect())
            .thenAnswer((_) async {});
        
        // Act
        chatController.onClose();
        
        // Assert
        expect(chatController.messageController.text, isEmpty);
      });

      test('should handle multiple close calls', () async {
        // Arrange
        chatController.isConnected.value = true;
        when(mockChatService.disconnect())
            .thenAnswer((_) async {});
        
        // Act
        chatController.onClose();
        chatController.onClose();
        
        // Assert - should not throw or cause issues
        verify(mockChatService.disconnect()).called(2);
      });
    });

    group('Edge Cases and Integration Tests', () {
      test('should handle rapid message sending', () async {
        // Arrange
        chatController.isConnected.value = true;
        
        final messages = List.generate(5, (index) => ChatMessage(
          id: 'rapid_$index',
          content: 'Message $index',
          senderId: 'currentUser',
          senderName: 'Current User',
          timestamp: DateTime.now(),
          isFromCurrentUser: true,
        ));
        
        for (int i = 0; i < 5; i++) {
          when(mockChatService.sendMessage('Message $i'))
              .thenAnswer((_) async => messages[i]);
        }
        
        // Act
        final futures = <Future>[];
        for (int i = 0; i < 5; i++) {
          chatController.messageController.text = 'Message $i';
          futures.add(chatController.sendMessage());
        }
        
        await Future.wait(futures);
        
        // Assert
        expect(chatController.messages.length, equals(5));
        expect(chatController.isSending.value, isFalse);
      });

      test('should handle message history with mixed senders', () async {
        // Arrange
        final mixedMessages = [
          ChatMessage(
            id: 'mixed_1',
            content: 'User message',
            senderId: 'currentUser',
            senderName: 'Current User',
            timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
            isFromCurrentUser: true,
          ),
          ChatMessage(
            id: 'mixed_2',
            content: 'Other user message',
            senderId: 'otherUser',
            senderName: 'Other User',
            timestamp: DateTime.now().subtract(const Duration(minutes: 4)),
            isFromCurrentUser: false,
          ),
          ChatMessage(
            id: 'mixed_3',
            content: 'Another user message',
            senderId: 'currentUser',
            senderName: 'Current User',
            timestamp: DateTime.now().subtract(const Duration(minutes: 3)),
            isFromCurrentUser: true,
          ),
        ];
        
        when(mockChatService.connect())
            .thenAnswer((_) async => true);
        when(mockChatService.getMessages())
            .thenAnswer((_) async => mixedMessages);
        
        // Act
        chatController.onInit();
        await Future.delayed(const Duration(milliseconds: 100));
        
        // Assert
        expect(chatController.messages.length, equals(3));
        expect(chatController.messages[0].isFromCurrentUser, isTrue);
        expect(chatController.messages[1].isFromCurrentUser, isFalse);
        expect(chatController.messages[2].isFromCurrentUser, isTrue);
      });

      test('should handle memory management with large message history', () async {
        // Arrange
        final largeHistory = List.generate(1000, (index) => ChatMessage(
          id: 'large_$index',
          content: 'Message $index',
          senderId: index % 2 == 0 ? 'currentUser' : 'otherUser',
          senderName: index % 2 == 0 ? 'Current User' : 'Other User',
          timestamp: DateTime.now().subtract(Duration(minutes: 1000 - index)),
          isFromCurrentUser: index % 2 == 0,
        ));
        
        when(mockChatService.connect())
            .thenAnswer((_) async => true);
        when(mockChatService.getMessages())
            .thenAnswer((_) async => largeHistory);
        
        // Act
        chatController.onInit();
        await Future.delayed(const Duration(milliseconds: 100));
        
        // Assert
        expect(chatController.messages.length, equals(1000));
        expect(chatController.isLoading.value, isFalse);
      });

      test('should handle network reconnection scenario', () async {
        // Arrange
        chatController.isConnected.value = true;
        
        when(mockChatService.connect())
            .thenAnswer((_) async => true);
        when(mockChatService.getMessages())
            .thenAnswer((_) async => <ChatMessage>[]);
        
        // Act - simulate connection loss and reconnection
        chatController.onConnectionLost();
        expect(chatController.isConnected.value, isFalse);
        
        await chatController.connect();
        
        // Assert
        expect(chatController.isConnected.value, isTrue);
      });

      test('should maintain state consistency during errors', () async {
        // Arrange
        chatController.messageController.text = 'Test message';
        chatController.isConnected.value = true;
        
        when(mockChatService.sendMessage('Test message'))
            .thenThrow(Exception('Network error'));
        
        // Act
        await chatController.sendMessage();
        
        // Assert - state should be consistent after error
        expect(chatController.isSending.value, isFalse);
        expect(chatController.isConnected.value, isTrue);
        expect(chatController.messageController.text, equals('Test message'));
      });
    });
  });
}