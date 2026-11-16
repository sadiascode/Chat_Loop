import 'package:flutter/material.dart';

import 'features/presentation/screen/chat_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ChatLoop());
}

class ChatLoop extends StatelessWidget {
  const ChatLoop({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "SouthEast",
      debugShowCheckedModeBanner: false,
      home: ChatScreen(),
    );
  }
}