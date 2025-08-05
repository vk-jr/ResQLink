import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_client_sse/flutter_client_sse.dart' show SSEClient;
import 'package:flutter_client_sse/constants/sse_request_type_enum.dart' show SSERequestType;
import 'user_session.dart';

const String esp32Ip = '192.168.4.1';

void main() {
  runApp(const MeshApp());
}

class MeshApp extends StatelessWidget {
  const MeshApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ESP32 Mesh Chat',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.cyan,
        colorScheme: const ColorScheme.dark(
          primary: Colors.cyan,
          secondary: Colors.cyanAccent,
        ),
      ),
      home: const ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _connectToSse();
  }

  void _connectToSse() {
    SSEClient.subscribeToSSE(
      method: SSERequestType.GET,
      url: 'http://$esp32Ip/events',
      header: {"Accept": "text/event-stream"},
    ).listen((event) {
      if (event.data != null && event.data!.isNotEmpty) {
        try {
          final data = jsonDecode(event.data!);

          // Check if this is an echo of a message we just sent.
          final isMe = data['username'] == (UserSession.name ?? 'User');
          if (isMe) {
            // If it's our own message coming back, find the temporary local one...
            final int existingIndex = _messages.indexWhere(
                (m) => m['isLocal'] == true && m['message'] == data['message']);
            // ...and if found, remove it before adding the final version from the network.
            if (existingIndex != -1) {
              setState(() {
                _messages.removeAt(existingIndex);
              });
            }
          }

          setState(() {
            _messages.insert(0, data);
          });
          _scrollController.animateTo(0.0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut);
        } catch (e) {
          print('Error parsing SSE data: $e');
        }
      }
    }, onError: (error) {
      print('SSE Client Error: $error');
    });
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.isEmpty || UserSession.name == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Message cannot be empty and you must be logged in.'),
            backgroundColor: Colors.orangeAccent),
      );
      return;
    }

    final messageText = _messageController.text;
    final username = UserSession.name!;

    // *** FIX PART 1: INSTANTLY DISPLAY SENT MESSAGE ***
    // Create a temporary "local" message and add it to the list right away.
    final localMessage = {
      "username": username,
      "message": messageText,
      "isLocal": true, // A temporary flag to identify this message
      "from_node": "Sending...", // Show a temporary status
    };
    setState(() {
      _messages.insert(0, localMessage);
    });
    _scrollController.animateTo(0.0,
        duration: const Duration(milliseconds: 300), curve: Curves.easeOut);

    _messageController.clear();

    // Now, send the actual message to the ESP32
    final messageBody = {
      "username": username,
      "message": messageText,
    };

    try {
      await http.post(
        Uri.parse('http://$esp32Ip/send'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(messageBody),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Failed to send. Check Wi-Fi connection.'),
              backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Offline Mesh Chat'),
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              reverse: true,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                // A message is "mine" if the username matches OR if it's a local temporary message.
                final isMe = msg['isLocal'] == true ||
                    msg['username'] == (UserSession.name ?? 'User');
                return MessageBubble(data: msg, isMe: isMe);
              },
            ),
          ),
          _buildMessageComposer(),
        ],
      ),
    );
  }

  Widget _buildMessageComposer() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                filled: true,
                fillColor: Colors.black26,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    borderSide: BorderSide.none),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8.0),
          IconButton.filled(
            style: IconButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor),
            icon: const Icon(Icons.send),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  final Map<String, dynamic> data;
  final bool isMe;
  const MessageBubble({super.key, required this.data, required this.isMe});

  @override
  Widget build(BuildContext context) {
    final username = data['username'] ?? 'Unknown';
    final message = data['message'] ?? '';
    final fromNode = data['from_node'] ?? 'N/A';

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: isMe ? Colors.cyan.shade800 : Colors.grey.shade800,
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(username,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isMe ? Colors.cyanAccent : Colors.white70)),
            const SizedBox(height: 4.0),
            Text(message, style: const TextStyle(fontSize: 16.0)),
            const SizedBox(height: 4.0),
            Text('via $fromNode',
                style: const TextStyle(fontSize: 10.0, color: Colors.white54)),
          ],
        ),
      ),
    );
  }
}