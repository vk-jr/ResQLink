import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:http_parser/http_parser.dart';

class ChatMessage {
  final String message;
  final bool isUser;
  final Uint8List? imageData;
  final DateTime timestamp;

  ChatMessage({
    required this.message,
    required this.isUser,
    this.imageData,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

class MedicalChatScreen extends StatefulWidget {
  const MedicalChatScreen({Key? key}) : super(key: key);

  @override
  _MedicalChatScreenState createState() => _MedicalChatScreenState();
}

class _MedicalChatScreenState extends State<MedicalChatScreen> {
  final ImagePicker _picker = ImagePicker();
  XFile? _pickedFile;
  final List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  Future<bool> _requestCameraPermission() async {
    try {
      final status = await Permission.camera.request();
      if (status.isPermanentlyDenied) {
        // Show dialog to open app settings
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Camera Permission'),
              content: const Text('Camera permission is required to take photos. Please enable it in app settings.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    openAppSettings();
                    Navigator.pop(context);
                  },
                  child: const Text('Open Settings'),
                ),
              ],
            ),
          );
        }
        return false;
      }
      return status.isGranted;
    } catch (e) {
      return false;
    }
  }

  void _addMessage(ChatMessage message) {
    setState(() {
      _messages.add(message);
    });
    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        preferredCameraDevice: CameraDevice.rear,
        imageQuality: 100,
      );
      
      if (image != null) {
        _pickedFile = image;
        final bytes = await image.readAsBytes();
        
        _addMessage(ChatMessage(
          message: 'Image captured',
          isUser: true,
          imageData: bytes,
        ));
        
        await _uploadImage();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error accessing camera: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _uploadImage() async {
    if (_pickedFile == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      var uri = Uri.parse('https://razyergg.app.n8n.cloud/webhook/medical-image');
      final bytes = await _pickedFile!.readAsBytes();
      
      var request = http.MultipartRequest('POST', uri);
      request.files.add(
        http.MultipartFile.fromBytes(
          'image',
          bytes,
          filename: '${DateTime.now().millisecondsSinceEpoch}.jpg',
          contentType: MediaType('image', 'jpeg')
        )
      );

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 200) {
        try {
          String formattedMessage = '';
          
          try {
            // Print response for debugging
            print('Webhook Response: ${response.body}');
            
            if (response.body.isNotEmpty) {
              // Try to parse the response as a JSON string first
              try {
                final jsonResponse = json.decode(response.body);
                // Handle the response as a simple string if it's directly in the response
                if (jsonResponse is Map) {
                  // If it's an object, look for the result in common field names
                  var result = jsonResponse['result']?.toString() ?? 
                             jsonResponse['analysis']?.toString() ?? 
                             jsonResponse['response']?.toString() ?? 
                             jsonResponse['message']?.toString();
                  if (result != null) {
                    // Remove the [ai_response: prefix and closing bracket if present
                    result = result.replaceAll(RegExp(r'^\[{ai_response:\s*'), '')
                                 .replaceAll(RegExp(r'\}]$'), '');
                    formattedMessage = result.trim();
                  } else {
                    formattedMessage = jsonResponse.toString();
                  }
                } else {
                  var response = jsonResponse.toString();
                  response = response.replaceAll(RegExp(r'^\[{ai_response:\s*'), '')
                                   .replaceAll(RegExp(r'\}]$'), '');
                  formattedMessage = response.trim();
                }
              } catch (e) {
                // If it's not JSON, use the response body directly
                var cleanResponse = response.body
                    .replaceAll(RegExp(r'^\[{ai_response:\s*'), '')
                    .replaceAll(RegExp(r'\}]$'), '');
                formattedMessage = cleanResponse.trim();
              }
            } else {
              formattedMessage = 'Received empty response from server.';
            }
          } catch (e) {
            print('Error parsing response: $e');
            formattedMessage = 'Could not process response from medical AI: $e';
          }
          
          // Clean up the message
          formattedMessage = formattedMessage.trim();          _addMessage(ChatMessage(
            message: formattedMessage,
            isUser: false,
          ));
        } catch (e) {
          _addMessage(ChatMessage(
            message: 'Error processing response: $e',
            isUser: false,
          ));
        }
      } else {
        _addMessage(ChatMessage(
          message: 'Failed to upload image: ${response.statusCode}\n${response.body}',
          isUser: false,
        ));
      }
    } catch (e) {
      _addMessage(ChatMessage(
        message: 'Error uploading image: $e',
        isUser: false,
      ));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        margin: EdgeInsets.only(
          left: message.isUser ? 48.0 : 16.0,
          right: message.isUser ? 16.0 : 48.0,
          top: 4.0,
          bottom: 4.0,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        decoration: BoxDecoration(
          color: message.isUser 
              ? Theme.of(context).primaryColor.withOpacity(0.9)
              : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(message.isUser ? 16.0 : 4.0),
            topRight: Radius.circular(message.isUser ? 4.0 : 16.0),
            bottomLeft: const Radius.circular(16.0),
            bottomRight: const Radius.circular(16.0),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: message.isUser 
              ? CrossAxisAlignment.end 
              : CrossAxisAlignment.start,
          children: [
            if (message.imageData != null)
              Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.3,
                  maxWidth: MediaQuery.of(context).size.width * 0.75,
                ),
                margin: const EdgeInsets.only(bottom: 8.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: Image.memory(
                    message.imageData!,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            if (!message.isUser)
              RichText(
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.black87,
                    height: 1.4,
                    letterSpacing: 0.3,
                    fontWeight: FontWeight.w400,
                  ),
                  children: _parseAIResponse(message.message),
                ),
              )
            else
              Text(
                message.message,
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.white,
                  height: 1.4,
                ),
              ),
            const SizedBox(height: 4),
            Text(
              '${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
              style: TextStyle(
                fontSize: 11,
                color: message.isUser 
                    ? Colors.white.withOpacity(0.7)
                    : Colors.black38,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<TextSpan> _parseAIResponse(String response) {
    List<TextSpan> spans = [];
    
    // Split by double asterisks for bold text while preserving empty strings
    final parts = response.split(RegExp(r'(\*\*)'));
    bool isBold = false;
    
    for (var i = 0; i < parts.length; i++) {
      final part = parts[i];
      if (part.isEmpty) {
        isBold = !isBold;
        continue;
      }
      
      if (part == '**') {
        isBold = !isBold;
        continue;
      }

      // Preserve all whitespace and newlines
      spans.add(TextSpan(
        text: part,
        style: TextStyle(
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          fontSize: 16,
          height: 1.5,
        ),
      ));
      
      isBold = !isBold;
    }
    
    return spans;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Medical AI Assistant',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _buildMessageBubble(_messages[index]);
              },
            ),
          ),
          if (_isLoading)
            Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  SizedBox(
                    width: 32,
                    height: 32,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Analyzing image...',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  offset: const Offset(0, -1),
                  blurRadius: 8,
                  color: Colors.black.withOpacity(0.06),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Material(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(24),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(24),
                      onTap: () async {
                        if (await _requestCameraPermission()) {
                          await _pickImage(ImageSource.camera);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Material(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(24),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(24),
                      onTap: () => _pickImage(ImageSource.gallery),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        child: const Icon(
                          Icons.photo_library,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
