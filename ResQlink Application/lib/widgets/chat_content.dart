import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../mm32_chat_page.dart';

class ChatPageContent extends StatelessWidget {
  const ChatPageContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);
    final controller = ScrollController();

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            controller: controller,
            reverse: true,
            itemCount: chatProvider.messages.length,
            itemBuilder: (context, index) {
              final msg = chatProvider.messages[index];
              return MessageBubble(data: msg);
            },
          ),
        ),
        _buildMessageComposer(chatProvider),
      ],
    );
  }

  Widget _buildMessageComposer(ChatProvider provider) {
    final controller = TextEditingController();

    return Container(
      padding: const EdgeInsets.all(8.0),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.send),
            color: Colors.blue,
            onPressed: () {
              if (controller.text.isNotEmpty) {
                provider.sendMessage(controller.text);
                controller.clear();
              }
            },
          ),
        ],
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  final Message data;
  
  const MessageBubble({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: data.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: data.isMe ? Colors.blue.shade700 : Colors.grey.shade800,
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Column(
          crossAxisAlignment:
              data.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              data.username,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: data.isMe ? Colors.white70 : Colors.white70,
              ),
            ),
            const SizedBox(height: 4.0),
            Text(
              data.message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16.0,
              ),
            ),
            const SizedBox(height: 4.0),
            Text(
              'via ${data.fromNode}',
              style: const TextStyle(
                fontSize: 10.0,
                color: Colors.white54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
