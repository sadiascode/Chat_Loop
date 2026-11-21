import 'package:flutter/material.dart';

import '../../../chat_room/data/websocket_controller.dart';
import '../../../chat_room/presentation/screens/chat_room_screen.dart';

class ListScreen extends StatefulWidget {
  const ListScreen({
    super.key,
    required this.controller,
    required this.primaryColor,
  });

  final WebSocketController controller;
  final Color primaryColor;

  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: const Color(0xFFF8F8FC),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
            leading: IconButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/');
              },
              icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
            ),
            title: Text(
              'Chat Loop',
              style: TextStyle(
                color: widget.primaryColor,
                fontSize: 23,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: widget.controller.users.length,
            separatorBuilder: (_, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final user = widget.controller.users[index];
              final userName = user['name'] as String? ?? 'unknown';
              final userStatus = user['status'] as String? ?? 'offline';
              final isOnline = userStatus.toLowerCase() == 'online';

              // Exclude my own username from the list
              if (widget.controller.myUsername != null &&
                  userName.toLowerCase() == widget.controller.myUsername!.toLowerCase()) {
                return const SizedBox.shrink();
              }

              return InkWell(
                borderRadius: BorderRadius.circular(15),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatRoomScreen(
                        selectedUser: userName,
                        controller: widget.controller,
                        primaryColor: widget.primaryColor,
                      ),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    children: [
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 25,
                            backgroundColor: const Color(0xFFEDEBFF),
                            child: Icon(
                              Icons.person,
                              color: widget.primaryColor,
                              size: 28,
                            ),
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              height: 12,
                              width: 12,
                              decoration: BoxDecoration(
                                color: isOnline ? Colors.green : Colors.grey,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              isOnline ? 'online' : 'offline',
                              style: TextStyle(
                                fontSize: 12,
                                color: isOnline ? Colors.green : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios,
                        size: 15,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
