import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../analytics_screen.dart';
import '../../sprint3_ai_assistant_screen.dart';
import '../../../constants/app_colors.dart';
import '../../../models/course_model.dart';
import '../../../models/mentor_gig_model.dart';
import '../../../models/user_model.dart';
import '../../../services/supabase_auth_service.dart';
import '../../../services/supabase_database_service.dart';
import '../../client_screens/chatscreen/clent_chat_screen.dart';
import '../courses/mentor_course_students_screen.dart';
import '../courses/mentor_courses_screen.dart';
import '../orders/women_order_screen.dart';
import '../profile/women_profile_screen.dart';
import '../services/women_service_screen.dart';

class MentorDashboardScreen extends StatelessWidget {
  final String userId;

  const MentorDashboardScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final db = GetIt.instance<SupabaseDatabaseService>();

    return StreamBuilder<UserModel?>(
      stream: db.streamUser(userId),
      builder: (context, userSnapshot) {
        final firstName = _firstName(userSnapshot.data?.displayName);
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(title: Text('Hello, $firstName')),
          drawer: _buildDrawer(context),
          body: StreamBuilder<List<MentorGigModel>>(
            stream: db.streamMentorGigs(userId),
            builder: (context, serviceSnapshot) {
              return StreamBuilder<List<CourseModel>>(
                stream: db.streamMentorCourses(userId),
                builder: (context, courseSnapshot) {
                  final services =
                      serviceSnapshot.data ?? const <MentorGigModel>[];
                  final courses = courseSnapshot.data ?? const <CourseModel>[];
                  final courseStudents = courses.fold<int>(
                    0,
                    (sum, course) => sum + course.totalStudents,
                  );
                  final courseEarnings = courses.fold<double>(
                    0,
                    (sum, course) =>
                        sum + (course.price * course.totalStudents),
                  );

                  return ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _sectionTitle('Services'),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _miniCard(
                              'My Services',
                              '${services.length}',
                              Icons.work,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _miniCard(
                              'Orders',
                              'Open',
                              Icons.shopping_bag,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _shortcutCard(
                              title: 'Manage Services',
                              subtitle: 'My Services and Add Service',
                              icon: Icons.design_services,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        MyServicesScreen(userId: userId),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _shortcutCard(
                              title: 'Service Orders',
                              subtitle: 'Track client work',
                              icon: Icons.assignment_turned_in,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        MentorOrdersScreen(userId: userId),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      _sectionTitle('Courses'),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _miniCard(
                              'My Courses',
                              '${courses.length}',
                              Icons.menu_book_rounded,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _miniCard(
                              'Students',
                              '$courseStudents',
                              Icons.groups_2_rounded,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _miniCard(
                              'Course Earnings',
                              'Rs ${courseEarnings.toStringAsFixed(0)}',
                              Icons.monetization_on,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _shortcutCard(
                              title: 'Manage Courses',
                              subtitle: 'Add and edit courses',
                              icon: Icons.school,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        MentorCoursesScreen(userId: userId),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      _shortcutCard(
                        title: 'Students List',
                        subtitle: 'View enrolled students by course',
                        icon: Icons.people_alt_outlined,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  MentorCourseStudentsScreen(mentorId: userId),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 18),
                      _sectionTitle('Common'),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _shortcutCard(
                              title: 'AI Proposal Assistant',
                              subtitle: 'Generate winning proposals',
                              icon: Icons.auto_awesome,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => Sprint3AiAssistantScreen(
                                      userId: userId,
                                      userType: 'mentor',
                                      initialTabIndex: 1,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _shortcutCard(
                              title: 'Analytics',
                              subtitle: 'Total earnings and insights',
                              icon: Icons.insights,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => AnalyticsScreen(
                                      userId: userId,
                                      userType: 'mentor',
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  Drawer _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: AppColors.primary),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                'Mentor Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          _drawerTile(
            context,
            icon: Icons.dashboard,
            title: 'Dashboard',
            onTap: () => Navigator.pop(context),
          ),
          _drawerTile(
            context,
            icon: Icons.work,
            title: 'Services',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MyServicesScreen(userId: userId),
                ),
              );
            },
          ),
          _drawerTile(
            context,
            icon: Icons.menu_book_rounded,
            title: 'Courses',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MentorCoursesScreen(userId: userId),
                ),
              );
            },
          ),
          _drawerTile(
            context,
            icon: Icons.shopping_bag,
            title: 'Orders',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MentorOrdersScreen(userId: userId),
                ),
              );
            },
          ),
          _drawerTile(
            context,
            icon: Icons.chat,
            title: 'Chat',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ChatScreen(userId: userId)),
              );
            },
          ),
          _drawerTile(
            context,
            icon: Icons.person,
            title: 'Profile',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MentorProfileScreen(userId: userId),
                ),
              );
            },
          ),
          const Divider(),
          _drawerTile(
            context,
            icon: Icons.logout,
            title: 'Logout',
            onTap: () async {
              Navigator.pop(context);
              await SupabaseAuthService().signOut();
              if (context.mounted) {
                Navigator.of(context).popUntil((route) => route.isFirst);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _drawerTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title),
      onTap: onTap,
    );
  }

  String _firstName(String? displayName) {
    final cleaned = (displayName ?? '').trim();
    if (cleaned.isEmpty) return 'Mentor';
    return cleaned.split(RegExp(r'\s+')).first;
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
    );
  }

  Widget _shortcutCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(height: 6),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _miniCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          const SizedBox(height: 2),
          Text(title, style: const TextStyle(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
