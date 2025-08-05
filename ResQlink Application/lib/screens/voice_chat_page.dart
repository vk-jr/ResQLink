import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class VoiceChatPage extends StatefulWidget {
  const VoiceChatPage({Key? key}) : super(key: key);

  @override
  State<VoiceChatPage> createState() => _VoiceChatPageState();
}

class _VoiceChatPageState extends State<VoiceChatPage> {
  final FlutterTts _flutterTts = FlutterTts();
  bool _isRecording = false;
  bool _isLoading = false;
  String _userMessage = '';
  String _aiReply = '';
  final List<Map<String, String>> _chat = [];
  
  MediaStream? _localStream;
  RTCPeerConnection? _peerConnection;
  List<int> _audioData = [];

  Future<void> _initializeWebRTC() async {
    _peerConnection = await createPeerConnection({
      'iceServers': [
        {
          'urls': 'stun:stun.l.google.com:19302',
        }
      ]
    });

    // Get audio stream
    _localStream = await navigator.mediaDevices.getUserMedia({
      'audio': true,
      'video': false
    });

    // Add stream to peer connection
    _localStream?.getTracks().forEach((track) {
      _peerConnection?.addTrack(track, _localStream!);
    });
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      // Stop recording
      _localStream?.getTracks().forEach((track) {
        if (track.kind == 'audio') {
          track.enabled = false;
          track.stop();
        }
      });
      
      setState(() {
        _isRecording = false;
      });

      // Process recorded audio
      // Here you would typically send the audio data to your server
      // For now, we'll simulate by sending a placeholder message
      setState(() {
        _userMessage = "Audio message recorded";
        _chat.add({'user': _userMessage});
        _isLoading = true;
      });
      await _sendToWebhook(_userMessage);
    } else {
      if (_localStream == null) {
        await _initializeWebRTC();
      }

      // Start recording
      _localStream?.getTracks().forEach((track) {
        if (track.kind == 'audio') {
          track.enabled = true;
        }
      });
      
      setState(() {
        _isRecording = true;
      });
    }
  }

  Future<void> _sendToWebhook(String message) async {
    try {
      final response = await http.post(
        Uri.parse('https://razyeryt.app.n8n.cloud/webhook/native-language'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'message': message}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _aiReply = data['solution'] ?? '';
          _chat.add({'ai': _aiReply});
          _isLoading = false;
        });
        await _speak(_aiReply);
      } else {
        setState(() {
          _aiReply = 'Error: ${response.statusCode}';
          _chat.add({'ai': _aiReply});
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _aiReply = 'Error: $e';
        _chat.add({'ai': _aiReply});
        _isLoading = false;
      });
    }
  }

  Future<void> _speak(String text) async {
    await _flutterTts.setLanguage('en-US');
    await _flutterTts.setPitch(1.0);
    await _flutterTts.speak(text);
  }

  @override
  void dispose() {
    _localStream?.getTracks().forEach((track) {
      track.enabled = false;
      track.stop();
    });
    _localStream?.dispose();
    _peerConnection?.close();
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Voice Chat')),
      body: Column(
        children: [
          if (_isRecording)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Recording...',
                style: TextStyle(fontSize: 18, color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _chat.length,
              itemBuilder: (context, index) {
                final entry = _chat[index];
                if (entry.containsKey('user')) {
                  return Align(
                    alignment: Alignment.centerRight,
                    child: Card(
                      color: Colors.blue[100],
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(entry['user']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  );
                } else {
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: Card(
                      color: Colors.green[100],
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(entry['ai']!, style: const TextStyle(fontStyle: FontStyle.italic)),
                      ),
                    ),
                  );
                }
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: GestureDetector(
              onTap: _toggleRecording,
              child: CircleAvatar(
                radius: 36,
                backgroundColor: _isRecording ? Colors.red : Colors.blue,
                child: const Icon(
                  Icons.mic,
                  color: Colors.white,
                  size: 36,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
} 