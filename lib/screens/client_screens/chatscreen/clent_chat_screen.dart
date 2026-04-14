import 'package:flutter/material.dart';
import 'package:shecan_ai/screens/client_screens/chatscreen/client_detail_chat_screen.dart';
import '../../../constants/app_colors.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        title: const Text("Chats"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 🤖 AI Chatbot Card
          _chatCard(
            context,
            name: "SheCan AI Assistant",
            message: "Ask anything about skills, jobs or mentors...",
            icon: Icons.auto_awesome,
            isAI: true,
          ),

          const SizedBox(height: 10),

          // 👩‍🏫 Mentor Chats
          ...List.generate(5, (index) {
            return _chatCard(
              context,
              name: "Mentor ${index + 1}",
              message: "Last message preview...",
              icon: Icons.person,
              isAI: false,
            );
          }),
        ],
      ),
    );
  }

  Widget _chatCard(
    BuildContext context, {
    required String name,
    required String message,
    required IconData icon,
    required bool isAI,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatDetailScreen(title: name, isAI: isAI),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: isAI
                  ? AppColors.primary
                  : AppColors.primaryLight,
              child: Icon(icon, color: Colors.white),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            const Icon(Icons.arrow_forward_ios, size: 14),
          ],
        ),
      ),
    );
  }
}
