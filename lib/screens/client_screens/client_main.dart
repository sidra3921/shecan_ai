import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:shecan_ai/screens/client_screens/profilescreen/client_profile_screen.dart';
import '../../constants/app_colors.dart';
import 'chatscreen/clent_chat_screen.dart';
import 'courses/client_my_learning_screen.dart';
import 'explorescreen/client_explore_screen.dart';
import 'homescreen/client_home_screen.dart';
import 'orderscreen/client_order_screen.dart';
import '../../services/session_service.dart';

class ClientMainScreen extends StatefulWidget {
  const ClientMainScreen({super.key});

  @override
  State<ClientMainScreen> createState() => _ClientMainScreenState();
}

class _ClientMainScreenState extends State<ClientMainScreen> {
  int _currentIndex = 0;
  late final SessionService _session;

  @override
  void initState() {
    super.initState();
    _session = GetIt.instance<SessionService>();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _session,
      builder: (context, _) {
        final userId = _session.currentUserId;
        if (userId == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final screens = [
          HomeScreen(userId: userId),
          ExploreScreen(currentUserId: userId),
          ClientMyLearningScreen(userId: userId),
          OrdersScreen(userId: userId),
          ChatScreen(userId: userId),
          ProfileScreen(userId: userId),
        ];

        return Scaffold(
          body: screens[_currentIndex],
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: AppColors.textSecondary,
            onTap: (index) {
              setState(() => _currentIndex = index);
            },
            items: [
              const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              const BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Explore'),
              const BottomNavigationBarItem(icon: Icon(Icons.school), label: 'My Learning'),
              const BottomNavigationBarItem(icon: Icon(Icons.work), label: 'Orders'),
              const BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: 'Chats'),
              const BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
            ],
          ),
        );
      },
    );
  }
}
