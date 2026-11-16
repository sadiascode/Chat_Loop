import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'chat_room_screen.dart';
import 'chat_setup_screen.dart.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _recipientController = TextEditingController();

  final ScrollController _scrollController = ScrollController();

  WebSocketChannel? _channel;

  bool _isConnected = false;
  bool _isConnecting = false;
  bool _hasConnected = false;
  String? _connectionError;
  String? _myUsername;

  final List<Map<String, dynamic>> _messages = [];

  final Color primaryColor = const Color(0xFF6C63FF);

  @override
  void initState() {
    super.initState();
  }

  // WebSocket Connection
  Future<void> connectWebSocket() async {
    final username = _usernameController.text.trim();

    if (username.isEmpty) {
      setState(() {
        _connectionError = 'Please enter your username.';
      });
      return;
    }

    _myUsername = username;

    final uri = Uri.parse('wss://gin-chat-demo.onrender.com/ws')
        .replace(queryParameters: {'user': username});

    setState(() {
      _isConnecting = true;
      _connectionError = null;
    });

    WebSocketChannel? channel;

    try {
      channel = WebSocketChannel.connect(uri);
      _channel = channel;

      await channel.ready;

      if (!mounted) {
        await channel.sink.close();
        return;
      }

      setState(() {
        _isConnected = true;
        _isConnecting = false;
        _hasConnected = true;
        _connectionError = null;
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

      await channel?.sink.close();

      if (!mounted) return;

      setState(() {
        _isConnected = false;
        _isConnecting = false;
        _connectionError =
            'Connection failed. Check your username and try again.';
      });
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

      final sender =
          decodedData['from'] ??
          decodedData['senderId'] ??
          decodedData['sender'] ??
          'unknown';
      final messageText = decodedData['text'] ?? decodedData['message'] ?? '';

      // Check if this message is from me (my own message echoed back)
      final isFromMe = sender == _myUsername;

      debugPrint(
        'Received message - Text: $messageText, Sender: $sender, IsMe: $isFromMe, MyUsername: $_myUsername',
      );

      setState(() {
        _messages.add({
          'message': messageText,
          'senderId': isFromMe ? 'me' : sender,
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
    final to = _recipientController.text.trim();

    if (text.isEmpty || to.isEmpty || !_isConnected || _channel == null) {
      return;
    }

    final messageData = {'to': to, 'text': text};

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
    _usernameController.dispose();
    _recipientController.dispose();
    _scrollController.dispose();
    _channel?.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8FC),

      appBar: _hasConnected
          ? AppBar(
              backgroundColor: Colors.white,
              elevation: 0,

              title: Row(
                children: [
                  Stack(
                    children: [
                      // const CircleAvatar(
                      //   radius: 23,
                      //   backgroundImage: NetworkImage(
                      //     'https://i.pravatar.cc/150?img=47',
                      //   ),
                      // ),
                      const CircleAvatar(radius: 23, child: Icon(Icons.person)),
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
                      Text(
                        _recipientController.text.trim(),
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
                // IconButton(
                //   onPressed: () {},
                //   icon: const Icon(Icons.call_outlined, color: Colors.black87),
                // ),
                IconButton(
                  onPressed: () {
                    disconnectWebSocket();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ChatScreen(),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.logout_outlined,
                    color: Colors.black87,
                  ),
                ),
                // IconButton(
                //   onPressed: () {},
                //   icon: const Icon(Icons.more_vert, color: Colors.black87),
                // ),
              ],
            )
          : null,

      body: _hasConnected
          ? ChatRoomScreen(
              isConnected: _isConnected,
              messages: _messages,
              scrollController: _scrollController,
              textEditController: _messageController,
              primaryColor: primaryColor,
              onSubmitted: (_) => sendMessage(),
              onTap: sendMessage,
            )
          : ChatSetupScreen(
              isConnecting: _isConnecting,
              primaryColor: primaryColor,
              usernameController: _usernameController,
              recipientController: _recipientController,
              connectionError: _connectionError,
              onPressed: connectWebSocket,
              onSubmitted: (_) => connectWebSocket(),
            ),
    );
  }
}
