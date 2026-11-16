import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();

  final ScrollController _scrollController = ScrollController();

  WebSocketChannel? _channel;

  bool _isConnected = false;
  bool _isConnecting = true;

  final List<Map<String, dynamic>> _messages = [];

  final Color primaryColor = const Color(0xFF6C63FF);

  // Replace with your actual WebSocket server URL
  final String socketUrl = 'https://gin-chat-demo.onrender.com';

  @override
  void initState() {
    super.initState();
    connectWebSocket();
  }

  // WebSocket Connection
  Future<void> connectWebSocket() async {
    try {
      final channel = WebSocketChannel.connect(Uri.parse(socketUrl));

      _channel = channel;

      await channel.ready;

      if (!mounted) return;

      setState(() {
        _isConnected = true;
        _isConnecting = false;
      });

      channel.stream.listen(
        (data) {
          handleIncomingMessage(data);
        },
        onError: (error) {
          debugPrint('WebSocket Error: $error');
          updateConnectionStatus(false);
        },
        onDone: () {
          debugPrint('WebSocket Disconnected');
          updateConnectionStatus(false);
        },
      );
    } catch (e) {
      debugPrint('Connection Error: $e');
      updateConnectionStatus(false);
    }
  }

  // Update Connection Status
  void updateConnectionStatus(bool connected) {
    if (!mounted) return;

    setState(() {
      _isConnected = connected;
      _isConnecting = false;
    });
  }

  // Receive Message
  void handleIncomingMessage(dynamic data) {
    try {
      final decodedData = jsonDecode(data.toString());

      if (!mounted) return;

      setState(() {
        _messages.add({
          'message': decodedData['message'] ?? '',
          'senderId': decodedData['senderId'] ?? 'unknown',
          'time': TimeOfDay.now().format(context),
        });
      });

      scrollToBottom();
    } catch (e) {
      debugPrint('Message Parsing Error: $e');
    }
  }

  // Send Message
  void sendMessage() {
    final text = _messageController.text.trim();

    if (text.isEmpty || !_isConnected || _channel == null) {
      return;
    }

    final messageData = {
      'message': text,
      'senderId': 'user_123',
      'receiverId': 'user_456',
      'type': 'text',
      'timestamp': DateTime.now().toIso8601String(),
    };

    try {
      _channel!.sink.add(jsonEncode(messageData));
      _messageController.clear();
    } catch (e) {
      debugPrint('Send Error: $e');
    }
  }

  // Scroll to Latest Message
  void scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // Disconnect
  Future<void> disconnectWebSocket() async {
    await _channel?.sink.close();

    if (mounted) {
      setState(() {
        _isConnected = false;
      });
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _channel?.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8FC),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,

        // leading: IconButton(
        //   icon: const Icon(
        //     Icons.arrow_back_ios_new,
        //     color: Colors.black87,
        //     size: 20,
        //   ),
        //   onPressed: () => Navigator.pop(context),
        // ),

        title: Row(
          children: [
            Stack(
              children: [
                const CircleAvatar(
                  radius: 23,
                  backgroundImage: NetworkImage(
                    'https://i.pravatar.cc/150?img=47',
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    height: 12,
                    width: 12,
                    decoration: BoxDecoration(
                      color: _isConnected ? Colors.green : Colors.grey,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(width: 12),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Sadia Rahman',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  _isConnecting
                      ? 'Connecting...'
                      : _isConnected
                      ? 'Online'
                      : 'Disconnected',
                  style: TextStyle(
                    fontSize: 12,
                    color: _isConnected ? Colors.green : Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),

        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.call_outlined, color: Colors.black87),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert, color: Colors.black87),
          ),
        ],
      ),

      body: Column(
        children: [
          // Connection Status
          if (!_isConnected)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              color: Colors.orange.shade50,
              child: Text(
                _isConnecting
                    ? 'Connecting to server...'
                    : 'Not connected to server',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.deepOrange, fontSize: 12),
              ),
            ),

          // Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];

                final bool isMe = message['senderId'] == 'user_123';

                return Align(
                  alignment: isMe
                      ? Alignment.centerRight
                      : Alignment.centerLeft,

                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),

                    margin: const EdgeInsets.only(bottom: 16),

                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),

                    decoration: BoxDecoration(
                      color: isMe ? primaryColor : Colors.white,

                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(18),
                        topRight: const Radius.circular(18),
                        bottomLeft: Radius.circular(isMe ? 18 : 4),
                        bottomRight: Radius.circular(isMe ? 4 : 18),
                      ),

                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          message['message'].toString(),
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.5,
                            color: isMe ? Colors.white : Colors.black87,
                          ),
                        ),

                        const SizedBox(height: 5),

                        Text(
                          message['time'].toString(),
                          style: TextStyle(
                            fontSize: 10,
                            color: isMe ? Colors.white70 : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Message Input
          Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 20),

            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, -3),
                ),
              ],
            ),

            child: Row(
              children: [
                IconButton(
                  onPressed: () {},
                  icon: Icon(
                    Icons.add_circle_outline,
                    color: primaryColor,
                    size: 25,
                  ),
                ),

                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),

                    decoration: BoxDecoration(
                      color: const Color(0xFFF4F4F8),
                      borderRadius: BorderRadius.circular(25),
                    ),

                    child: TextField(
                      controller: _messageController,
                      minLines: 1,
                      maxLines: 4,

                      decoration: const InputDecoration(
                        hintText: 'Type a message...',
                        border: InputBorder.none,
                      ),

                      onSubmitted: (_) => sendMessage(),
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                GestureDetector(
                  onTap: sendMessage,

                  child: Container(
                    height: 48,
                    width: 48,

                    decoration: BoxDecoration(
                      color: _isConnected ? primaryColor : Colors.grey,
                      shape: BoxShape.circle,
                    ),

                    child: const Icon(
                      Icons.send_rounded,
                      color: Colors.white,
                      size: 21,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
