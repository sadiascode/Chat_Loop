import 'package:flutter/material.dart';

class ChatSetupScreen extends StatefulWidget {
  const ChatSetupScreen({
    super.key,
    required this.isConnecting,
    required this.primaryColor,
    required this.usernameController,
    required this.recipientController,
    required this.connectionError,
    required this.onPressed,
    required this.onSubmitted,
  });

  final bool isConnecting;
  final Color primaryColor;
  final TextEditingController? usernameController;
  final TextEditingController? recipientController;
  final String? connectionError;
  final void Function()? onPressed;
  final void Function(String)? onSubmitted;

  @override
  State<ChatSetupScreen> createState() => _ChatSetupScreenState();
}

class _ChatSetupScreenState extends State<ChatSetupScreen> {
  @override
  Widget build(BuildContext context) {
    return Center(
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
                'Enter username and recipient to start conversation',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),

              const SizedBox(height: 28),

              TextField(
                controller: widget.usernameController,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.done,

                onSubmitted: (_) {
                  if (!widget.isConnecting) {
                    widget.onSubmitted;
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
              SizedBox(height: 10),
              TextField(
                controller: widget.recipientController,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.done,

                onSubmitted: (_) {
                  if (!widget.isConnecting) {
                    widget.onSubmitted;
                  }
                },
                decoration: InputDecoration(
                  hintText: 'Enter Recipient',
                  prefixIcon: const Icon(Icons.person_outline),
                  filled: true,
                  fillColor: Colors.white,

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),

                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: const Color.fromARGB(255, 200, 100, 100),
                    ),
                  ),

                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: widget.primaryColor),
                  ),
                ),
              ),

              if (widget.connectionError != null) ...[
                const SizedBox(height: 12),

                Text(
                  widget.connectionError!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red, fontSize: 13),
                ),
              ],

              const SizedBox(height: 18),

              SizedBox(
                height: 50,

                child: ElevatedButton(
                  onPressed: widget.isConnecting ? null : widget.onPressed,
                  // onPressed: widget.isConnecting ? null : connectWebSocket,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.primaryColor,
                    foregroundColor: Colors.white,

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),

                  child: widget.isConnecting
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
    );
  }
}
