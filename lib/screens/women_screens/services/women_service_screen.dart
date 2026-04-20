import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../../constants/app_colors.dart';
import '../../../models/mentor_gig_model.dart';
import '../../../services/supabase_database_service.dart';
import 'women_add_service.dart';

class MyServicesScreen extends StatelessWidget {
  final String userId;

  const MyServicesScreen({super.key, required this.userId});

  Future<void> _deleteGig(BuildContext context, MentorGigModel gig) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Service'),
        content: Text('Delete "${gig.title}" permanently?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete != true || !context.mounted) return;

    try {
      await GetIt.instance<SupabaseDatabaseService>().deleteMentorGig(gig.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Service deleted')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to delete: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final db = GetIt.instance<SupabaseDatabaseService>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text("My Services")),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddServiceScreen(mentorId: userId),
            ),
          );
        },
        child: const Icon(Icons.add, color: AppColors.cardBackground),
      ),
      body: StreamBuilder<List<MentorGigModel>>(
        stream: db.streamMentorGigs(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Failed to load services: ${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final gigs = snapshot.data ?? const [];
          if (gigs.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'No services yet. Create your first AI-assisted gig.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: gigs.length,
            itemBuilder: (context, index) {
              final gig = gigs[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (gig.imageUrl.isNotEmpty) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          gig.imageUrl,
                          width: double.infinity,
                          height: 130,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            height: 130,
                            color: AppColors.surface,
                            alignment: Alignment.center,
                            child: const Icon(Icons.broken_image_outlined),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            gig.title,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                        Icon(
                          gig.isActive ? Icons.verified : Icons.pause_circle,
                          color: gig.isActive ? Colors.green : Colors.orange,
                          size: 18,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Rs ${gig.hourlyRate.toStringAsFixed(0)}/hr'
                      ' • ${gig.category ?? 'general'}'
                      ' • ${gig.experienceLevel ?? 'intermediate'}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                    if (gig.skills.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: gig.skills
                            .take(5)
                            .map(
                              (skill) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.10),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  skill,
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                    if (gig.packages.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text(
                        'Packages (${gig.packages.length})',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 6),
                      ...gig.packages.take(3).map((pkg) {
                        final name = pkg['name']?.toString() ?? 'Tier';
                        final price = pkg['price']?.toString() ?? '0';
                        final days = pkg['deliveryDays']?.toString() ?? '0';
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            '$name: Rs $price • $days days',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        );
                      }),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AddServiceScreen(
                                  mentorId: userId,
                                  initialGig: gig,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.edit, color: AppColors.primary),
                        ),
                        IconButton(
                          onPressed: () => _deleteGig(context, gig),
                          icon: const Icon(Icons.delete, color: AppColors.primary),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
