import 'package:flutter/material.dart';

import '../../data/websocket_controller.dart';

class ChatSetupScreen extends StatefulWidget {
  const ChatSetupScreen({
    super.key,
    required this.primaryColor,
    required this.controller,
  });

  final Color primaryColor;
  final WebSocketController controller;

  @override
  State<ChatSetupScreen> createState() => _ChatSetupScreenState();
}

class _ChatSetupScreenState extends State<ChatSetupScreen> {
  final TextEditingController _usernameController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _connect() async {
    final username = _usernameController.text.trim();
    if (username.isEmpty) return;

    await widget.controller.connect(username);

    if (mounted && widget.controller.isConnected) {
      Navigator.pushReplacementNamed(context, '/list');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: const Color(0xFFF8F8FC),
          body: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),

              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),

                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,

                  children: [
                    Icon(
                      Icons.wifi_tethering_rounded,
                      size: 64,
                      color: widget.primaryColor,
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      'Connect to Chat Server',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                    ),

                    const SizedBox(height: 10),

                    const Text(
                      'Enter username to start conversation',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),

                    const SizedBox(height: 28),

                    TextField(
                      controller: _usernameController,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.done,

                      onSubmitted: (_) {
                        if (!widget.controller.isConnecting) {
                          _connect();
                        }
                      },

                      decoration: InputDecoration(
                        hintText: 'Enter Username',
                        prefixIcon: const Icon(Icons.person_outline),
                        filled: true,
                        fillColor: Colors.white,

                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),

                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),

                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: widget.primaryColor),
                        ),
                      ),
                    ),

                    if (widget.controller.connectionError != null) ...[
                      const SizedBox(height: 12),

                      Text(
                        widget.controller.connectionError!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red, fontSize: 13),
                      ),
                    ],

                    const SizedBox(height: 18),

                    SizedBox(
                      height: 50,

                      child: ElevatedButton(
                        onPressed: widget.controller.isConnecting ? null : _connect,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: widget.primaryColor,
                          foregroundColor: Colors.white,

                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),

                        child: widget.controller.isConnecting
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Start Conversation',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
