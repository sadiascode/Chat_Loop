import 'package:flutter/material.dart';
import 'features/chat_room/data/websocket_controller.dart';
import 'features/chat_room/presentation/screens/chat_setup_screen.dart.dart';
import 'features/chatlist/presentation/screen/list_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ChatLoop());
}

class ChatLoop extends StatelessWidget {
  const ChatLoop({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = WebSocketController();

    return MaterialApp(
      title: " ChatLoop",
      debugShowCheckedModeBanner: false,
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(
              builder: (_) => ChatSetupScreen(
                controller: controller,
                primaryColor: const Color(0xFF6C63FF),
              ),
            );
          case '/list':
            return MaterialPageRoute(
              builder: (_) => ListScreen(
                controller: controller,
                primaryColor: const Color(0xFF6C63FF),
              ),
            );
          default:
            return MaterialPageRoute(
              builder: (_) => ChatSetupScreen(
                controller: controller,
                primaryColor: const Color(0xFF6C63FF),
              ),
            );
        }
      },
      initialRoute: '/',
    );
  }
}
