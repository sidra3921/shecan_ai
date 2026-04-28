import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../constants/app_colors.dart';
import '../../../models/course_model.dart';
import '../../../models/mentor_gig_model.dart';
import '../../../services/supabase_database_service.dart';
import '../courses/client_course_detail_screen.dart';
import 'client_gig_detail_screen.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key, this.currentUserId});

  final String? currentUserId;

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final _searchController = TextEditingController();
  String _selectedCategory = 'all';
  bool _showCourses = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<MentorGigModel> _filter(
    List<MentorGigModel> gigs,
    String query,
    String category,
  ) {
    final q = query.trim().toLowerCase();
    return gigs.where((gig) {
      final matchesCategory =
          category == 'all' || (gig.category?.toLowerCase() == category);
      final matchesQuery =
          q.isEmpty ||
          gig.title.toLowerCase().contains(q) ||
          gig.description.toLowerCase().contains(q) ||
          gig.skills.any((s) => s.toLowerCase().contains(q));
      return matchesCategory && matchesQuery;
    }).toList();
  }

  List<String> _buildCategories(List<MentorGigModel> gigs) {
    final set = <String>{'all'};
    for (final gig in gigs) {
      final c = gig.category?.trim().toLowerCase();
      if (c != null && c.isNotEmpty) {
        set.add(c);
      }
    }
    return set.toList();
  }

  List<CourseModel> _filterCourses(List<CourseModel> courses, String query) {
    final q = query.trim().toLowerCase();
    return courses.where((course) {
      if (q.isEmpty) return true;
      return course.title.toLowerCase().contains(q) ||
          course.description.toLowerCase().contains(q) ||
          course.category.toLowerCase().contains(q) ||
          course.level.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final db = GetIt.instance<SupabaseDatabaseService>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.background,
        title: const Text("Explore"),
        elevation: 0,
        centerTitle: true,
      ),
      body: StreamBuilder<List<MentorGigModel>>(
        stream: db.streamPublicMentorGigs(),
        builder: (context, serviceSnapshot) {
          return StreamBuilder<List<CourseModel>>(
            stream: db.streamPublicCourses(),
            builder: (context, courseSnapshot) {
              if ((serviceSnapshot.connectionState == ConnectionState.waiting &&
                      !serviceSnapshot.hasData) ||
                  (courseSnapshot.connectionState == ConnectionState.waiting &&
                      !courseSnapshot.hasData)) {
                return const Center(child: CircularProgressIndicator());
              }

              final allGigs = serviceSnapshot.data ?? const <MentorGigModel>[];
              final allCourses = courseSnapshot.data ?? const <CourseModel>[];
              final categories = _buildCategories(allGigs);
              final filteredServices = _filter(
                allGigs,
                _searchController.text,
                _selectedCategory,
              );
              final filteredCourses = _filterCourses(
                allCourses,
                _searchController.text,
              );

              return Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          hintText: _showCourses
                              ? 'Search courses, category, level...'
                              : 'Search gigs, skills, categories...',
                          border: InputBorder.none,
                          icon: const Icon(Icons.search),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _switchChip(
                            title: 'Services',
                            selected: !_showCourses,
                            onTap: () => setState(() => _showCourses = false),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _switchChip(
                            title: 'Courses',
                            selected: _showCourses,
                            onTap: () => setState(() => _showCourses = true),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (!_showCourses) ...[
                      const Text(
                        'Service Categories',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 40,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: categories
                              .map(
                                (c) => CategoryChip(
                                  title: c[0].toUpperCase() + c.substring(1),
                                  isSelected: c == _selectedCategory,
                                  onTap: () =>
                                      setState(() => _selectedCategory = c),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Featured Services (${filteredServices.length})',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: filteredServices.isEmpty
                            ? const Center(
                                child: Text('No matching services found'),
                              )
                            : GridView.builder(
                                itemCount: filteredServices.length,
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      mainAxisSpacing: 12,
                                      crossAxisSpacing: 12,
                                      mainAxisExtent: 300,
                                    ),
                                itemBuilder: (context, index) {
                                  return MentorCard(
                                    gig: filteredServices[index],
                                  );
                                },
                              ),
                      ),
                    ] else ...[
                      Text(
                        'Popular Courses (${filteredCourses.length})',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: filteredCourses.isEmpty
                            ? const Center(
                                child: Text('No matching courses found'),
                              )
                            : ListView.builder(
                                itemCount: filteredCourses.length,
                                itemBuilder: (context, index) {
                                  return CourseCard(
                                    course: filteredCourses[index],
                                    currentUserId: widget.currentUserId,
                                  );
                                },
                              ),
                      ),
                    ],
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _switchChip({
    required String title,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: TextStyle(
            color: selected ? Colors.white : AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class CategoryChip extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryChip({
    super.key,
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.primaryLight,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ),
      ),
    );
  }
}

class MentorCard extends StatelessWidget {
  final MentorGigModel gig;

  const MentorCard({super.key, required this.gig});

  @override
  Widget build(BuildContext context) {
    final displayPrice = gig.packages.isNotEmpty
        ? (gig.packages.first['price']?.toString() ??
              gig.hourlyRate.toStringAsFixed(0))
        : gig.hourlyRate.toStringAsFixed(0);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ClientGigDetailScreen(gig: gig)),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [const BoxShadow(color: Colors.black12, blurRadius: 8)],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: gig.imageUrl.isNotEmpty
                      ? Image.network(
                          gig.imageUrl,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const Center(child: Icon(Icons.person, size: 40)),
                        )
                      : const Center(child: Icon(Icons.person, size: 40)),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                gig.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                gig.category ?? 'General',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${gig.packages.length} pkg'),
                  Text(
                    'Rs $displayPrice',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CourseCard extends StatelessWidget {
  const CourseCard({super.key, required this.course, this.currentUserId});

  final CourseModel course;
  final String? currentUserId;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ClientCourseDetailScreen(
                course: course,
                currentUserId: currentUserId,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: course.thumbnailUrl.isNotEmpty
                    ? Image.network(
                        course.thumbnailUrl,
                        width: 90,
                        height: 90,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 90,
                          height: 90,
                          color: AppColors.surface,
                          child: const Icon(Icons.school_outlined),
                        ),
                      )
                    : Container(
                        width: 90,
                        height: 90,
                        color: AppColors.surface,
                        child: const Icon(Icons.school_outlined),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${course.category} • ${course.level} • ${course.duration}',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          'Rs ${course.price.toStringAsFixed(0)}',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Spacer(),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ClientCourseDetailScreen(
                                  course: course,
                                  currentUserId: currentUserId,
                                ),
                              ),
                            );
                          },
                          child: const Text('Enroll Now'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
