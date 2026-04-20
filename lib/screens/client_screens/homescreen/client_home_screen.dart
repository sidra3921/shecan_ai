import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../../constants/app_colors.dart';
import '../../../models/course_model.dart';
import '../../../models/mentor_gig_model.dart';
import '../../../models/user_model.dart';
import '../../../services/supabase_auth_service.dart';
import '../../../services/supabase_database_service.dart';
import '../../analytics_screen.dart';
import '../../sprint3_ai_assistant_screen.dart';
import '../courses/client_my_learning_screen.dart';
import '../explorescreen/client_explore_screen.dart';
import '../courses/client_course_detail_screen.dart';
import '../explorescreen/client_gig_detail_screen.dart';
import '../notificationsscreen/client_notifications_screen.dart';
import '../orderscreen/client_order_screen.dart';
import '../profilescreen/client_profile_screen.dart';

class HomeScreen extends StatelessWidget {
  final String userId;

  const HomeScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final db = GetIt.instance<SupabaseDatabaseService>();

    return StreamBuilder<UserModel?>(
      stream: db.streamUser(userId),
      builder: (context, userSnapshot) {
        final firstName = _firstName(userSnapshot.data?.displayName);

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: Text('Hello, $firstName'),
            backgroundColor: Colors.transparent,
            elevation: 0,
            foregroundColor: AppColors.textPrimary,
          ),
          drawer: _buildDrawer(context),
          body: StreamBuilder<List<MentorGigModel>>(
            stream: db.streamPublicMentorGigs(),
            builder: (context, serviceSnapshot) {
              return StreamBuilder<List<CourseModel>>(
                stream: db.streamPublicCourses(),
                builder: (context, courseSnapshot) {
                  return FutureBuilder<List<UserModel>>(
                    future: db.getMentors(),
                    builder: (context, mentorSnapshot) {
                      final services =
                          (serviceSnapshot.data ?? const <MentorGigModel>[])
                              .take(4)
                              .toList();
                      final courses =
                          (courseSnapshot.data ?? const <CourseModel>[])
                              .take(4)
                              .toList();
                      final mentors =
                          (mentorSnapshot.data ?? const <UserModel>[])
                              .take(5)
                              .toList();

                      return ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _actionCard(
                                  context,
                                  title: 'AI Brief Assistant',
                                  subtitle: 'Generate project brief in seconds',
                                  icon: Icons.auto_awesome,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            Sprint3AiAssistantScreen(
                                              userId: userId,
                                              userType: 'client',
                                              initialTabIndex: 0,
                                            ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _actionCard(
                                  context,
                                  title: 'Analytics',
                                  subtitle: 'Track projects and value',
                                  icon: Icons.insights,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => AnalyticsScreen(
                                          userId: userId,
                                          userType: 'client',
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          _sectionTitle('Featured Services'),
                          const SizedBox(height: 10),
                          if (services.isEmpty)
                            const Text('No services yet')
                          else
                            ...services.map((service) {
                              return _serviceTile(context, service);
                            }),
                          const SizedBox(height: 18),
                          _sectionTitle('Popular Courses'),
                          const SizedBox(height: 10),
                          if (courses.isEmpty)
                            const Text('No courses yet')
                          else
                            ...courses.map((course) {
                              return _courseTile(context, course);
                            }),
                          const SizedBox(height: 18),
                          _sectionTitle('Top Mentors'),
                          const SizedBox(height: 10),
                          if (mentors.isEmpty)
                            const Text('No mentors found')
                          else
                            ...mentors.map((mentor) {
                              return Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: AppColors.surface,
                                      backgroundImage:
                                          mentor.photoURL.isNotEmpty
                                          ? NetworkImage(mentor.photoURL)
                                          : null,
                                      child: mentor.photoURL.isEmpty
                                          ? const Icon(Icons.person)
                                          : null,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            mentor.displayName,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Text(
                                            mentor.skills.isEmpty
                                                ? 'Mentor'
                                                : mentor.skills
                                                      .take(2)
                                                      .join(', '),
                                            style: const TextStyle(
                                              color: AppColors.textSecondary,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.surface,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Text(
                                        '⭐ ${mentor.rating.toStringAsFixed(1)}',
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                        ],
                      );
                    },
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
                'Client Menu',
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
            icon: Icons.home,
            title: 'Home',
            onTap: () => Navigator.pop(context),
          ),
          _drawerTile(
            context,
            icon: Icons.search,
            title: 'Explore',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ExploreScreen(currentUserId: userId),
                ),
              );
            },
          ),
          _drawerTile(
            context,
            icon: Icons.school,
            title: 'My Learning',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ClientMyLearningScreen(userId: userId),
                ),
              );
            },
          ),
          _drawerTile(
            context,
            icon: Icons.work,
            title: 'Orders',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => OrdersScreen(userId: userId)),
              );
            },
          ),
          _drawerTile(
            context,
            icon: Icons.notifications_none,
            title: 'Notifications',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ClientNotificationsScreen(userId: userId),
                ),
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
                  builder: (_) => ProfileScreen(userId: userId),
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
    if (cleaned.isEmpty) return 'there';
    return cleaned.split(RegExp(r'\s+')).first;
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
    );
  }

  Widget _serviceTile(BuildContext context, MentorGigModel gig) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  gig.title,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  'Rs ${gig.hourlyRate.toStringAsFixed(0)}/hr',
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ClientGigDetailScreen(gig: gig),
                ),
              );
            },
            child: const Text('Hire Now'),
          ),
        ],
      ),
    );
  }

  Widget _courseTile(BuildContext context, CourseModel course) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course.title,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  'Rs ${course.price.toStringAsFixed(0)} • ${course.level}',
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ClientCourseDetailScreen(
                    course: course,
                    currentUserId: userId,
                  ),
                ),
              );
            },
            child: const Text('Enroll Now'),
          ),
        ],
      ),
    );
  }

  Widget _actionCard(
    BuildContext context, {
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
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
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
}
