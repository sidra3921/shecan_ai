import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import 'earnings/women_earning_screen.dart';
import 'home/women_home_screen.dart';
import 'orders/women_order_screen.dart';
import 'profile/women_profile_screen.dart';
import 'requests/women_request_screen.dart';
import 'services/women_service_screen.dart';

class MentorMainNav extends StatefulWidget {
  const MentorMainNav({super.key});

  @override
  State<MentorMainNav> createState() => _MentorMainNavState();
}

class _MentorMainNavState extends State<MentorMainNav> {
  int index = 0;

  final screens = const [
    MentorDashboardScreen(),
    MyServicesScreen(),
    RequestsScreen(),
    MentorOrdersScreen(),
    EarningsScreen(),
    MentorProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
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
            icon: Icon(Icons.request_page),
            label: "Requests",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: "Orders",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: "Earnings",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
