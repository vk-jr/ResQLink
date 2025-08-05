import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../user_session.dart';

class RegionDetailsScreen extends StatefulWidget {
  final String regionName;
  final int selectedIndex;
  final void Function(int)? onNavItemTapped;
  
  const RegionDetailsScreen({
    Key? key, 
    required this.regionName, 
    this.selectedIndex = 1, 
    this.onNavItemTapped
  }) : super(key: key);

  @override
  State<RegionDetailsScreen> createState() => _RegionDetailsScreenState();
}

class _RegionDetailsScreenState extends State<RegionDetailsScreen> {
  bool isNeedHelp = true; // Default to Need Help mode
  final TextEditingController controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Map<String, dynamic>> messages = [];
  bool isLoading = true;
  bool isSending = false;
  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _subscribeToMessages();
  }

  Future<void> _loadMessages() async {
    try {
      final response = await supabase
          .from('regional_messages')
          .select()
          .eq('region_name', widget.regionName)
          .order('timestamp', ascending: true);

      setState(() {
        messages = List<Map<String, dynamic>>.from(response);
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading messages: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _subscribeToMessages() {
    final channel = supabase.channel('regional_messages');
    
    channel.onPostgresChanges(
      event: PostgresChangeEvent.insert,
      schema: 'public',
      table: 'regional_messages',
      callback: (payload) {
        if (mounted && payload.newRecord['region_name'] == widget.regionName) {
          setState(() {
            messages.add(Map<String, dynamic>.from(payload.newRecord));
          });
        }
      },
    ).subscribe();
  }

  Future<void> _sendMessage() async {
    if (controller.text.trim().isEmpty || UserSession.email == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a message and ensure you are logged in')),
      );
      return;
    }

    setState(() => isSending = true);
    try {
      final newMessage = {
        'region_name': widget.regionName,
        'user_id': UserSession.email,
        'name': UserSession.name ?? UserSession.email ?? 'Anonymous',
        'message': controller.text.trim(),
        'is_need_help': isNeedHelp,
        'timestamp': DateTime.now().toIso8601String(),
      };

      print('Sending message: $newMessage'); // Debug print
      
      final response = await supabase
          .from('regional_messages')
          .insert(newMessage)
          .select();
      
      print('Response: $response'); // Debug print

      controller.clear();
      setState(() {
        isSending = false;
      });
      // Auto-scroll to latest
      Future.delayed(const Duration(milliseconds: 200), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            0.0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e, stackTrace) {
      print('Error sending message: $e');
      print('Stack trace: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sending message: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isSending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final contacts = [
      {'role': 'Relief Officer', 'name': 'Anil Kumar', 'number': '9876543210'},
      {'role': 'Medical Help', 'name': 'Dr. Priya', 'number': '9123456780'},
      {'role': 'Local Volunteer', 'name': 'Suresh', 'number': '9988776655'},
    ];
    
    final camps = [
      {'name': 'Camp Alpha', 'location': 'Govt. School, Main Road'},
      {'name': 'Camp Beta', 'location': 'Community Hall, Market Area'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.regionName),
        leading: BackButton(onPressed: () => Navigator.pop(context)),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showModalBottomSheet(
                context: context,
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                    reverse: true,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[messages.length - 1 - index];
                      final isNeedHelp = message['is_need_help'] == true;
                      final senderName = message['name'] ?? message['user_id'] ?? 'Anonymous';
                      final initials = _getInitials(senderName);
                      final circleColor = _getColorFromName(senderName);
                      final time = DateTime.tryParse(message['timestamp'] ?? '')?.toLocal().toString().substring(11, 16) ?? '';
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: isNeedHelp ? MainAxisAlignment.end : MainAxisAlignment.start,
                        children: [
                          if (!isNeedHelp) ...[
                            CircleAvatar(
                              radius: 18,
                              backgroundColor: circleColor,
                              child: Text(
                                initials,
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Flexible(
                            child: Column(
                              crossAxisAlignment: isNeedHelp ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 2, right: 2, bottom: 2),
                                  child: Text(
                                    senderName,
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87),
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: isNeedHelp ? const Color(0xFFFFE5E5) : const Color(0xFFE5F6E5),
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(isNeedHelp ? 16 : 4),
                                      topRight: Radius.circular(isNeedHelp ? 4 : 16),
                                      bottomLeft: const Radius.circular(16),
                                      bottomRight: const Radius.circular(16),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.04),
                                        blurRadius: 3,
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    message['message'] ?? '',
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: isNeedHelp ? const Color(0xFFD32F2F) : const Color(0xFF2E7D32),
                                      height: 1.3,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 2, right: 2, top: 2),
                                  child: Text(
                                    time,
                                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isNeedHelp) ...[
                            const SizedBox(width: 8),
                            CircleAvatar(
                              radius: 18,
                              backgroundColor: circleColor,
                              child: Text(
                                initials,
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ],
                      );
                    },
                  ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                    reverse: true,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[messages.length - 1 - index];
                      final isNeedHelp = message['is_need_help'] == true;
                      final userShort = message['user_id']?.toString().split('@')[0] ?? 'Anonymous';
                      final time = DateTime.tryParse(message['timestamp'] ?? '')?.toLocal().toString().substring(11, 16) ?? '';
                      return Row(
                        mainAxisAlignment: isNeedHelp ? MainAxisAlignment.end : MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (!isNeedHelp) const SizedBox(width: 8),
                          Flexible(
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: isNeedHelp ? const Color(0xFFFFE5E5) : const Color(0xFFE5F6E5),
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(isNeedHelp ? 16 : 4),
                                  topRight: Radius.circular(isNeedHelp ? 4 : 16),
                                  bottomLeft: const Radius.circular(16),
                                  bottomRight: const Radius.circular(16),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.04),
                                    blurRadius: 3,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: isNeedHelp ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    message['message'] ?? '',
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: isNeedHelp ? const Color(0xFFD32F2F) : const Color(0xFF2E7D32),
                                      height: 1.3,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        userShort,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: isNeedHelp ? const Color(0xFFD32F2F).withOpacity(0.7) : const Color(0xFF2E7D32).withOpacity(0.7),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        time,
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (isNeedHelp) const SizedBox(width: 8),
                        ],
                      );
                                style: TextStyle(
                                  color: message['is_need_help']
                                      ? Colors.red[900]
                                      : Colors.green[900],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                DateTime.parse(message['timestamp'])
                                    .toLocal()
                                    .toString()
                                    .substring(0, 16),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: message['is_need_help']
                                      ? Colors.red[700]
                                      : Colors.green[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, -1),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.emergency_outlined, size: 16),
                      label: const Text('Need Help'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isNeedHelp ? Colors.red : Colors.grey[200],
                        foregroundColor:
                            isNeedHelp ? Colors.white : Colors.grey[600],
                        elevation: isNeedHelp ? 2 : 0,
                      ),
                      onPressed: () => setState(() => isNeedHelp = true),
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.volunteer_activism, size: 16),
                      label: const Text('Offer Help'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            !isNeedHelp ? Colors.green : Colors.grey[200],
                        foregroundColor:
                            !isNeedHelp ? Colors.white : Colors.grey[600],
                        elevation: !isNeedHelp ? 2 : 0,
                      ),
                      onPressed: () => setState(() => isNeedHelp = false),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller,
                        key: const Key('message_input'),
                        autofillHints: const ['message-input'],
                        onSubmitted: (_) => _sendMessage(),
                        decoration: InputDecoration(
                          hintText: isNeedHelp
                              ? 'Type your request...'
                              : 'Type your offer...',
                          filled: true,
                          fillColor: Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isNeedHelp ? Colors.red : Colors.green,
                      ),
                      child: IconButton(
                        icon: isSending
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Icon(Icons.send, color: Colors.white),
                        onPressed: isSending ? null : _sendMessage,
// Helper to get initials from name/email
String _getInitials(String name) {
  final parts = name.trim().split(RegExp(r'\s+'));
  if (parts.length == 1) {
    return parts[0].isNotEmpty ? parts[0][0].toUpperCase() : '?';
  }
  return (parts[0][0] + parts[1][0]).toUpperCase();
}

// Helper to get a color from a string (name/email)
Color _getColorFromName(String name) {
  final colors = [
    Colors.blue, Colors.red, Colors.green, Colors.orange, Colors.purple, Colors.teal, Colors.indigo, Colors.brown
  ];
  final hash = name.codeUnits.fold(0, (prev, c) => prev + c);
  return colors[hash % colors.length].shade700;
}
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: widget.onNavItemTapped != null
          ? BottomNavigationBar(
              currentIndex: widget.selectedIndex,
              onTap: widget.onNavItemTapped,
              items: const [
                BottomNavigationBarItem(
                    icon: Icon(Icons.home), label: 'Home'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.people), label: 'Community'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.map), label: 'Map'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.menu_book), label: 'Guide'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.person), label: 'Profile'),
              ],
            )
          : null,
    );
  }
}
