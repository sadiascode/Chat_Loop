import 'package:flutter/material.dart';

class ChatRoomScreen extends StatefulWidget {
  const ChatRoomScreen({
    super.key,
    required this.isConnected,
    required this.scrollController,
    required this.textEditController,
    required this.messages,
    required this.primaryColor,
    required this.onSubmitted,
    required this.onTap,
  });

  final bool isConnected;
  final ScrollController scrollController;
  final TextEditingController textEditController;
  final List<Map<String, dynamic>> messages;
  final Color? primaryColor;
  final void Function(String)? onSubmitted;
  final void Function()? onTap;

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Messages
        Expanded(
          child: ListView.builder(
            controller: widget.scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            itemCount: widget.messages.length,
            itemBuilder: (context, index) {
              final message = widget.messages[index];

              final bool isMe = message['senderId'] == 'me';

              return Align(
                alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,

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
                    color: isMe ? widget.primaryColor : Colors.white,

                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(18),
                      topRight: const Radius.circular(18),
                      bottomLeft: Radius.circular(isMe ? 18 : 4),
                      bottomRight: Radius.circular(isMe ? 4 : 18),
                    ),

                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
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
                color: Colors.black.withValues(alpha: 0.04),
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
                  color: widget.primaryColor,
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
                    controller: widget.textEditController,
                    minLines: 1,
                    maxLines: 4,

                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: InputBorder.none,
                    ),

                    onSubmitted: widget.onSubmitted,
                  ),
                ),
              ),

              const SizedBox(width: 10),

              GestureDetector(
                onTap: widget.onTap,
                child: Container(
                  height: 48,
                  width: 48,

                  decoration: BoxDecoration(
                    color: widget.isConnected
                        ? widget.primaryColor
                        : Colors.grey,
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
    );
  }
}
