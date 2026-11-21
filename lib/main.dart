import 'package:flutter/material.dart';
import 'features/chatlist/presentation/screen/list_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ChatLoop());
}

class ChatLoop extends StatelessWidget {
  const ChatLoop({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Loop",
      debugShowCheckedModeBanner: false,
      home: ListScreen(),
    );
  }
}
