import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../constants/app_colors.dart';
import '../client_screens/chatscreen/clent_chat_screen.dart';
import '../../services/session_service.dart';
import 'courses/mentor_courses_screen.dart';
import 'home/women_home_screen.dart';
import 'orders/women_order_screen.dart';
import 'profile/women_profile_screen.dart';
import 'services/women_service_screen.dart';

class MentorMainNav extends StatefulWidget {
  const MentorMainNav({super.key});

  @override
  State<MentorMainNav> createState() => _MentorMainNavState();
}

class _MentorMainNavState extends State<MentorMainNav> {
  int index = 0;
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
          MentorDashboardScreen(userId: userId),
          MyServicesScreen(userId: userId),
          MentorCoursesScreen(userId: userId),
          MentorOrdersScreen(userId: userId),
          ChatScreen(userId: userId),
          MentorProfileScreen(userId: userId),
        ];

        return Scaffold(
          body: screens[index],
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: index,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: Colors.grey,
            onTap: (i) => setState(() => index = i),
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: "Home"),
              BottomNavigationBarItem(icon: Icon(Icons.work), label: "Services"),
              BottomNavigationBarItem(
                icon: Icon(Icons.menu_book_rounded),
                label: "Courses",
              ),
              BottomNavigationBarItem(icon: Icon(Icons.shopping_bag), label: "Orders"),
              BottomNavigationBarItem(icon: Icon(Icons.chat), label: "Chat"),
              BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
            ],
          ),
        );
      },
    );
  }
}
