import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:park_wallet/constants/app_colors.dart';
import 'package:park_wallet/data/models/chat_message.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  
  const MessageBubble({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    switch (message.type) {
      case MessageType.text:
        return _buildTextMessage();
      case MessageType.image:
        return _buildImageMessage();
      case MessageType.system:
        return _buildSystemMessage();
    }
  }

  Widget _buildTextMessage() {
    return Align(
      alignment: message.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: message.isMe ? AppColors.sapphire : AppColors.very_light_grey,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: message.isMe ? const Radius.circular(16) : const Radius.circular(4),
            bottomRight: message.isMe ? const Radius.circular(4) : const Radius.circular(16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 2,
              spreadRadius: 0,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        constraints: const BoxConstraints(maxWidth: 280),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!message.isMe)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  message.senderName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: message.isMe ? Colors.white70 : AppColors.sapphire,
                  ),
                ),
              ),
            Text(
              message.content,
              style: TextStyle(
                color: message.isMe ? Colors.white : Colors.black87,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 2),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                DateFormat('HH:mm').format(message.timestamp),
                style: TextStyle(
                  fontSize: 10,
                  color: message.isMe ? Colors.white70 : Colors.black54,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildImageMessage() {
    return Align(
      alignment: message.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: message.isMe ? AppColors.sapphire : AppColors.very_light_grey,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: message.isMe ? const Radius.circular(16) : const Radius.circular(4),
            bottomRight: message.isMe ? const Radius.circular(4) : const Radius.circular(16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 2,
              spreadRadius: 0,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        constraints: const BoxConstraints(maxWidth: 200),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!message.isMe)
              Padding(
                padding: const EdgeInsets.only(left: 8, top: 4, bottom: 2),
                child: Text(
                  message.senderName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: message.isMe ? Colors.white70 : AppColors.sapphire,
                  ),
                ),
              ),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: _buildImageFromBase64(message.content),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 8, top: 2),
              child: Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  DateFormat('HH:mm').format(message.timestamp),
                  style: TextStyle(
                    fontSize: 10,
                    color: message.isMe ? Colors.white70 : Colors.black54,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildImageFromBase64(String base64String) {
    try {
      final Uint8List bytes = base64Decode(base64String);
      return Image.memory(
        bytes,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Icon(Icons.image_not_supported, color: Colors.grey),
          );
        },
      );
    } catch (e) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Icon(Icons.image_not_supported, color: Colors.grey),
      );
    }
  }
  
  Widget _buildSystemMessage() {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.black12,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          message.content,
          style: const TextStyle(
            color: Colors.black54,
            fontSize: 12,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }
}