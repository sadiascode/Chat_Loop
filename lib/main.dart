import 'package:flutter/material.dart';
import 'features/chat_room/presentation/screens/chat_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ChatLoop());
}

class ChatLoop extends StatelessWidget {
  const ChatLoop({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: " ChatLoop",
      debugShowCheckedModeBanner: false,
      home: ChatScreen(),
    );
  }
}
