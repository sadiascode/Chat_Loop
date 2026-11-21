import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketController extends ChangeNotifier {
  WebSocketChannel? _channel;
  StreamSubscription? _streamSubscription;

  bool _isConnected = false;
  bool _isConnecting = false;
  String? _myUsername;
  String? _connectionError;

  final List<Map<String, dynamic>> _users = [
    {'name': 'sam', 'status': 'online'},
    {'name': 'sadia', 'status': 'online'},
    {'name': 'jim', 'status': 'online'},
    {'name': 'alex', 'status': 'offline'},
    {'name': 'taylor', 'status': 'offline'},
  ];
  final List<Map<String, dynamic>> _messages = [];

  // Getters
  bool get isConnected => _isConnected;
  bool get isConnecting => _isConnecting;
  String? get myUsername => _myUsername;
  String? get connectionError => _connectionError;
  List<Map<String, dynamic>> get users => List.unmodifiable(_users);
  List<Map<String, dynamic>> get messages => List.unmodifiable(_messages);

  // Connect to WebSocket
  Future<void> connect(String username) async {
    if (_isConnected || _isConnecting) return;

    _myUsername = username;
    _isConnecting = true;
    _connectionError = null;
    notifyListeners();

    try {
      final uri = Uri.parse('wss://gin-chat-demo.onrender.com/ws')
          .replace(queryParameters: {'user': username});

      _channel = WebSocketChannel.connect(uri);
      await _channel!.ready;

      _isConnected = true;
      _isConnecting = false;
      _connectionError = null;
      notifyListeners();

      _streamSubscription = _channel!.stream.listen(
        (data) {
          _handleIncomingMessage(data);
        },
        onError: (error) {
          debugPrint('WebSocket Error: $error');
          _updateConnectionStatus(false);
        },
        onDone: () {
          debugPrint('WebSocket Disconnected');
          _updateConnectionStatus(false);
        },
      );
    } catch (e) {
      debugPrint('Connection Error: $e');
      await _channel?.sink.close();
      _isConnected = false;
      _isConnecting = false;
      _connectionError = 'Connection failed. Please try again.';
      notifyListeners();
    }
  }

  // Handle incoming messages
  void _handleIncomingMessage(dynamic data) {
    try {
      final decodedData = jsonDecode(data.toString());
      final messageType = decodedData['type'];

      debugPrint('Received data: $decodedData, type: $messageType');

      switch (messageType) {
        case 'users':
          final usersList = decodedData['users'] as List?;
          if (usersList != null) {
            _users.clear();
            for (var user in usersList) {
              if (user is Map) {
                _users.add({
                  'name': user['name'] ?? user['username'] ?? 'unknown',
                  'status': user['status'] ?? 'offline',
                });
              }
            }
            notifyListeners();
            debugPrint('User list refreshed. Total users: ${_users.length}');
          }
          break;

        case 'presence':
          final user = decodedData['user'] as String?;
          final isOnline = decodedData['online'] as bool? ?? false;
          if (user != null) {
            final userIndex = _users.indexWhere((u) => u['name'] == user);
            if (userIndex != -1) {
              _users[userIndex]['status'] = isOnline ? 'online' : 'offline';
            } else {
              _users.add({
                'name': user,
                'status': isOnline ? 'online' : 'offline',
              });
            }
            notifyListeners();
            debugPrint('Presence updated: $user is ${isOnline ? "online" : "offline"}');
          }
          break;

        case 'message':
          final sender = decodedData['from'] ?? 'unknown';
          final to = decodedData['to'] ?? 'unknown';
          final messageText = decodedData['text'] ?? '';

          final isFromMe = sender == _myUsername;

          debugPrint('$sender → $to: $messageText');

          _messages.add({
            'message': messageText,
            'senderId': isFromMe ? 'me' : sender,
            'time': DateTime.now().toString().substring(11, 16),
          });
          notifyListeners();
          break;

        case 'ack':
          final to = decodedData['to'] ?? 'unknown';
          final status = decodedData['status'] ?? 'unknown';
          debugPrint('Message to $to: $status');
          break;

        case 'error':
          final errorText = decodedData['text'] ?? 'Unknown error';
          debugPrint('Error: $errorText');
          _connectionError = errorText;
          notifyListeners();
          break;

        default:
          debugPrint('Received: $data');
      }
    } catch (e) {
      debugPrint('Message Parsing Error: $e');
    }
  }

  // Send message
  void sendMessage(String to, String text) {
    if (!_isConnected || _channel == null) return;

    final messageData = {'to': to, 'text': text};
    try {
      _channel!.sink.add(jsonEncode(messageData));

      // Add message to UI immediately
      _messages.add({
        'message': text,
        'senderId': 'me',
        'time': DateTime.now().toString().substring(11, 16),
      });
      notifyListeners();
    } catch (e) {
      debugPrint('Send Error: $e');
    }
  }

  // Update connection status
  void _updateConnectionStatus(bool connected) {
    _isConnected = connected;
    _isConnecting = false;
    notifyListeners();
  }

  // Disconnect
  Future<void> disconnect() async {
    await _streamSubscription?.cancel();
    await _channel?.sink.close();

    _channel = null;
    _streamSubscription = null;
    _isConnected = false;
    _isConnecting = false;
    _myUsername = null;
    _connectionError = null;
    _users.clear();
    _messages.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    _channel?.sink.close();
    super.dispose();
  }
}
