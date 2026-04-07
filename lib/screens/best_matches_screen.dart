import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../constants/app_colors.dart';
import '../services/recommendation_service.dart';

class BestMatchesScreen extends StatefulWidget {
  const BestMatchesScreen({super.key});

  @override
  State<BestMatchesScreen> createState() => _BestMatchesScreenState();
}

class _BestMatchesScreenState extends State<BestMatchesScreen> {
  late RecommendationService _recommendationService;
  late Future<List<RecommendedGig>> _recommendations;

  @override
  void initState() {
    super.initState();
    _recommendationService = RecommendationService();
    _loadRecommendations();
  }

  void _loadRecommendations() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      _recommendations = _recommendationService.getGigRecommendations(
        userId: userId,
        limit: 15,
      );
    } else {
      _recommendations = Future.value([]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('AI Recommended Gigs'),
            Text(
              'Personalized matches based on your skills',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            ),
          ],
        ),
      ),
      body: FutureBuilder<List<RecommendedGig>>(
        future: _recommendations,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error loading recommendations: ${snapshot.error}'),
            );
          }

          final recommendations = snapshot.data ?? [];

          if (recommendations.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inbox_outlined,
                    size: 64,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No available gigs at the moment',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Check back soon for new opportunities!',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: recommendations.length,
            itemBuilder: (context, index) {
              return _RecommendedGigCard(
                recommendedGig: recommendations[index],
              );
            },
          );
        },
      ),
    );
  }
}

class _RecommendedGigCard extends StatefulWidget {
  final RecommendedGig recommendedGig;

  const _RecommendedGigCard({required this.recommendedGig});

  @override
  State<_RecommendedGigCard> createState() => _RecommendedGigCardState();
}

class _RecommendedGigCardState extends State<_RecommendedGigCard> {
  late RecommendationService _recommendationService;
  late bool _isSaved;
  late bool _isApplied;

  @override
  void initState() {
    super.initState();
    _recommendationService = RecommendationService();
    _isSaved = widget.recommendedGig.isSaved;
    _isApplied = widget.recommendedGig.isApplied;
  }

  Future<void> _toggleSave() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    try {
      if (_isSaved) {
        await _recommendationService.unsaveGig(
          userId: userId,
          projectId: widget.recommendedGig.project.id,
        );
      } else {
        await _recommendationService.saveGig(
          userId: userId,
          project: widget.recommendedGig.project,
        );
      }

      setState(() {
        _isSaved = !_isSaved;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isSaved ? 'Project saved!' : 'Project removed from saves',
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error updating save status')),
        );
      }
    }
  }

  Future<void> _applyForGig() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    try {
      await _recommendationService.trackProjectView(
        userId: userId,
        project: widget.recommendedGig.project,
        applied: true,
      );

      setState(() {
        _isApplied = true;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Application submitted!'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error submitting application')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final gig = widget.recommendedGig.project;
    final client = widget.recommendedGig.client;
    final matchScore = widget.recommendedGig.matchScore.toStringAsFixed(0);
    final daysUntilDeadline = widget.recommendedGig.daysUntilDeadline ?? -1;
    final deadlineUrgency = _recommendationService.getDeadlineUrgency(
      daysUntilDeadline,
    );

    // Color based on match score
    Color matchScoreColor;
    if (widget.recommendedGig.matchScore >= 80) {
      matchScoreColor = AppColors.success;
    } else if (widget.recommendedGig.matchScore >= 60) {
      matchScoreColor = AppColors.warning;
    } else {
      matchScoreColor = AppColors.info;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with match score
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        gig.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'By ${client.displayName}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Location with distance
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 14,
                            color: AppColors.info,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              widget.recommendedGig.locationDisplay ??
                                  'Location not specified',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (widget.recommendedGig.distance != null) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.info.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '${widget.recommendedGig.distance!.toStringAsFixed(0)} km',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.info,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: matchScoreColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: matchScoreColor, width: 1),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '$matchScore%',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: matchScoreColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Match',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Description
            Text(
              gig.description,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            // Skills section
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.recommendedGig.matchedSkills.isNotEmpty) ...[
                  const Text(
                    'Matched Skills',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.success,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: widget.recommendedGig.matchedSkills
                        .map(
                          (skill) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.success.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.success,
                                width: 1,
                              ),
                            ),
                            child: Text(
                              skill,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.success,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  if (widget.recommendedGig.missingSkills.isNotEmpty)
                    const SizedBox(height: 12),
                ],
                if (widget.recommendedGig.missingSkills.isNotEmpty) ...[
                  const Text(
                    'Skills to Learn',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.warning,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: widget.recommendedGig.missingSkills
                        .map(
                          (skill) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.warning.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.warning,
                                width: 1,
                              ),
                            ),
                            child: Text(
                              skill,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.warning,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            // Budget and client rating
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Budget',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'PKR ${gig.budget.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Client Rating',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            size: 14,
                            color: AppColors.warning,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            client.rating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Deadline and status badges
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Deadline',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: daysUntilDeadline < 3 && daysUntilDeadline >= 0
                              ? AppColors.warning.withOpacity(0.1)
                              : AppColors.info.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          deadlineUrgency,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color:
                                daysUntilDeadline < 3 && daysUntilDeadline >= 0
                                ? AppColors.warning
                                : AppColors.info,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Status',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 4,
                        children: [
                          if (widget.recommendedGig.project.isUrgent)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.warning.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'Urgent',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: AppColors.warning,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          if (widget.recommendedGig.isViewed)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.info.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'Viewed',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: AppColors.info,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Action buttons
            Row(
              children: [
                // Save button
                IconButton(
                  onPressed: _toggleSave,
                  style: IconButton.styleFrom(
                    backgroundColor: _isSaved
                        ? AppColors.primary.withOpacity(0.1)
                        : Colors.grey[200],
                    padding: const EdgeInsets.all(12),
                  ),
                  icon: Icon(
                    _isSaved ? Icons.favorite : Icons.favorite_border,
                    color: _isSaved ? AppColors.primary : Colors.grey,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 8),
                // Apply button
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isApplied ? null : _applyForGig,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: _isApplied ? Colors.grey[300] : null,
                      disabledBackgroundColor: Colors.grey[300],
                    ),
                    child: Text(
                      _isApplied ? 'Already Applied' : 'Apply Now',
                      style: TextStyle(
                        color: _isApplied ? Colors.grey[700] : null,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
