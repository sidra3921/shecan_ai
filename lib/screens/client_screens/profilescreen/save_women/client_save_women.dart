import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../../../constants/app_colors.dart';
import '../../../../models/mentor_gig_model.dart';
import '../../../../models/user_model.dart';
import '../../../../services/supabase_database_service.dart';
import '../../explorescreen/client_gig_detail_screen.dart';

class SavedMentorsScreen extends StatefulWidget {
  const SavedMentorsScreen({super.key, required this.userId});

  final String userId;

  @override
  State<SavedMentorsScreen> createState() => _SavedMentorsScreenState();
}

class _SavedMentorItem {
  final UserModel mentor;
  final MentorGigModel gig;

  const _SavedMentorItem({required this.mentor, required this.gig});
}

class _SavedMentorsScreenState extends State<SavedMentorsScreen> {
  Future<List<_SavedMentorItem>> _buildItems({
    required Set<String> savedGigIds,
    required List<MentorGigModel> gigs,
    required List<UserModel> mentors,
  }) async {
    if (savedGigIds.isEmpty) return const [];

    final mentorById = <String, UserModel>{for (final m in mentors) m.id: m};
    final items = <_SavedMentorItem>[];

    for (final gig in gigs) {
      if (!savedGigIds.contains(gig.id)) continue;
      final mentor = mentorById[gig.mentorId];
      if (mentor == null) continue;
      items.add(_SavedMentorItem(mentor: mentor, gig: gig));
    }

    items.sort(
      (a, b) => a.mentor.displayName.toLowerCase().compareTo(
        b.mentor.displayName.toLowerCase(),
      ),
    );
    return items;
  }

  Future<void> _removeSavedGig(String gigId) async {
    final db = GetIt.instance<SupabaseDatabaseService>();
    await db.removeSavedGig(userId: widget.userId, gigId: gigId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        title: const Text("Saved Mentors"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      body: StreamBuilder<Set<String>>(
        stream: GetIt.instance<SupabaseDatabaseService>().streamSavedGigIds(
          widget.userId,
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final savedGigIds = snapshot.data ?? const <String>{};
          final db = GetIt.instance<SupabaseDatabaseService>();

          return StreamBuilder<List<MentorGigModel>>(
            stream: db.streamPublicMentorGigs(),
            builder: (context, gigsSnapshot) {
              if (gigsSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              return FutureBuilder<List<UserModel>>(
                future: db.getMentors(),
                builder: (context, mentorsSnapshot) {
                  if (mentorsSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final gigs = gigsSnapshot.data ?? const <MentorGigModel>[];
                  final mentors = mentorsSnapshot.data ?? const <UserModel>[];

                  return FutureBuilder<List<_SavedMentorItem>>(
                    future: _buildItems(
                      savedGigIds: savedGigIds,
                      gigs: gigs,
                      mentors: mentors,
                    ),
                    builder: (context, itemsSnapshot) {
                      final items =
                          itemsSnapshot.data ?? const <_SavedMentorItem>[];
                      if (items.isEmpty) {
                        return const Center(
                          child: Text(
                            'No saved mentors yet',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final item = items[index];
                          final subtitle = item.mentor.skills.isNotEmpty
                              ? item.mentor.skills.take(2).join(', ')
                              : item.gig.title;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: AppColors.primaryLight,
                                  backgroundImage:
                                      item.mentor.photoURL.isNotEmpty
                                      ? NetworkImage(item.mentor.photoURL)
                                      : null,
                                  child: item.mentor.photoURL.isEmpty
                                      ? const Icon(
                                          Icons.person,
                                          color: Colors.white,
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.mentor.displayName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        subtitle,
                                        style: const TextStyle(
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  tooltip: 'Remove',
                                  onPressed: () => _removeSavedGig(item.gig.id),
                                  icon: const Icon(
                                    Icons.favorite,
                                    color: Colors.red,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => ClientGigDetailScreen(
                                          gig: item.gig,
                                        ),
                                      ),
                                    );
                                  },
                                  child: const Text('View'),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
