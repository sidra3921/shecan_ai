import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../constants/app_colors.dart';
import '../../../models/dispute_model.dart';
import '../../../models/order_event_model.dart';
import '../../../models/project_model.dart';
import '../../../models/review_model.dart';
import '../../../screens/project_mentor_matches_screen.dart';
import '../../../screens/client_screens/chatscreen/client_detail_chat_screen.dart';
import '../../../services/chat_service.dart';
import '../../../services/supabase_database_service.dart';

class ClientOrderDetailScreen extends StatefulWidget {
  final String userId;
  final String projectId;

  const ClientOrderDetailScreen({
    super.key,
    required this.userId,
    required this.projectId,
  });

  @override
  State<ClientOrderDetailScreen> createState() =>
      _ClientOrderDetailScreenState();
}

class _ClientOrderDetailScreenState extends State<ClientOrderDetailScreen> {
  final _db = GetIt.instance<SupabaseDatabaseService>();
  final _chatService = ChatService();
  bool _isBusy = false;

  Future<void> _submitReview(ProjectModel project) async {
    final mentorId = project.mentorId;
    if (mentorId == null || mentorId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mentor not found for this order.')),
      );
      return;
    }

    final commentController = TextEditingController();
    double rating = 5;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Submit Review'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Rating: ${rating.toStringAsFixed(1)}'),
                  Slider(
                    min: 1,
                    max: 5,
                    divisions: 8,
                    value: rating,
                    onChanged: (value) {
                      setDialogState(() => rating = value);
                    },
                  ),
                  TextField(
                    controller: commentController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Write your feedback',
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Submit'),
                ),
              ],
            );
          },
        );
      },
    );

    if (confirmed != true) return;

    try {
      await _db.createReview(
        ReviewModel(
          id: '',
          projectId: project.id,
          reviewerId: widget.userId,
          reviewedUserId: mentorId,
          rating: rating,
          comment: commentController.text.trim(),
          verified: true,
        ),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Review submitted successfully.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not submit review: $e')));
    }
  }

  Future<void> _raiseDispute(ProjectModel project) async {
    final mentorId = project.mentorId;
    if (mentorId == null || mentorId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mentor not found for this order.')),
      );
      return;
    }

    final reasonController = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Raise Dispute'),
        content: TextField(
          controller: reasonController,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: 'Describe the issue clearly...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () =>
                Navigator.pop(context, reasonController.text.trim()),
            child: const Text('Submit'),
          ),
        ],
      ),
    );

    if (reason == null || reason.isEmpty) return;

    try {
      await _db.createDispute(
        DisputeModel(
          id: '',
          projectId: project.id,
          raisedBy: widget.userId,
          againstUser: mentorId,
          reason: reason,
        ),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dispute raised successfully.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not raise dispute: $e')));
    }
  }

  void _openMatches(ProjectModel project) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProjectMentorMatchesScreen(
          projectId: project.id,
          projectTitle: project.title,
        ),
      ),
    );
  }

  Future<void> _approve(ProjectModel project) async {
    if (_isBusy) return;
    setState(() => _isBusy = true);
    try {
      await _db.approveOrderDelivery(
        projectId: project.id,
        clientId: widget.userId,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order approved and completed.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not approve order: $e')));
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _requestRevision(ProjectModel project) async {
    final controller = TextEditingController();
    final note = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Request Revision'),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'What changes are needed?',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Send'),
          ),
        ],
      ),
    );

    if (note == null || note.isEmpty || _isBusy) return;

    setState(() => _isBusy = true);
    try {
      await _db.requestOrderRevision(
        projectId: project.id,
        clientId: widget.userId,
        revisionNote: note,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Revision request sent.')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not request revision: $e')));
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _openMentorChat(ProjectModel project) async {
    final mentorId = project.mentorId;
    if (mentorId == null || mentorId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mentor is not assigned yet.')),
      );
      return;
    }

    try {
      final otherUser = await _db.getUser(mentorId);
      if (otherUser == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open chat right now.')),
        );
        return;
      }

      final authUser = Supabase.instance.client.auth.currentUser;
      final currentName =
          authUser?.userMetadata?['display_name']
                  ?.toString()
                  .trim()
                  .isNotEmpty ==
              true
          ? authUser!.userMetadata!['display_name'].toString().trim()
          : (authUser?.email?.split('@').first ?? 'You');

      final conversation = await _chatService.getOrCreateDirectConversation(
        currentUserId: widget.userId,
        currentUserName: currentName,
        otherUser: otherUser,
      );

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatDetailScreen(
            title: otherUser.displayName,
            isAI: false,
            currentUserId: widget.userId,
            conversation: conversation,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not open chat: $e')));
    }
  }

  String _eventTitle(String type) {
    switch (type) {
      case 'delivery_submitted':
        return 'Delivery submitted';
      case 'delivery_approved':
        return 'Delivery approved';
      case 'revision_requested':
        return 'Revision requested';
      default:
        return type.replaceAll('_', ' ');
    }
  }

  String _eventTime(DateTime timestamp) {
    final t = timestamp.toLocal();
    final mm = t.minute.toString().padLeft(2, '0');
    return '${t.day}/${t.month}/${t.year} ${t.hour}:$mm';
  }

  Widget _timeline(String projectId) {
    return StreamBuilder<List<OrderEventModel>>(
      stream: _db.streamOrderEvents(projectId),
      builder: (context, snapshot) {
        final events = snapshot.data ?? const <OrderEventModel>[];

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Order Timeline',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
              ),
              const SizedBox(height: 10),
              if (events.isEmpty)
                const Text(
                  'No timeline updates yet.',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ...events.map((event) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.fiber_manual_record,
                        size: 10,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _eventTitle(event.eventType),
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (event.note != null &&
                                event.note!.trim().isNotEmpty)
                              Text(
                                event.note!,
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            Text(
                              _eventTime(event.createdAt),
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textHint,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _completionActions(ProjectModel project) {
    return StreamBuilder<List<ReviewModel>>(
      stream: _db.streamProjectReviews(project.id),
      builder: (context, reviewSnapshot) {
        final hasReview = (reviewSnapshot.data ?? const <ReviewModel>[]).any(
          (review) => review.reviewerId == widget.userId,
        );

        return StreamBuilder<List<DisputeModel>>(
          stream: _db.streamProjectDisputes(project.id),
          builder: (context, disputeSnapshot) {
            final hasDispute = (disputeSnapshot.data ?? const <DisputeModel>[])
                .any((dispute) => dispute.raisedBy == widget.userId);

            return Column(
              children: [
                const ListTile(
                  leading: Icon(Icons.check_circle, color: Colors.green),
                  title: Text('Order completed successfully'),
                  subtitle: Text('You can submit a review or raise a dispute.'),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: hasReview
                            ? null
                            : () => _submitReview(project),
                        child: Text(
                          hasReview ? 'Review Submitted' : 'Submit Review',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: hasDispute
                            ? null
                            : () => _raiseDispute(project),
                        child: Text(
                          hasDispute ? 'Dispute Raised' : 'Raise Dispute',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Order Details')),
      body: StreamBuilder<ProjectModel?>(
        stream: _db.streamProject(widget.projectId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final project = snapshot.data;
          if (project == null) {
            return const Center(child: Text('Order not found'));
          }

          final status = project.status.toLowerCase();
          final isDelivered = status == 'delivered';
          final isCompleted = status == 'completed';

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      project.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(project.description),
                    const SizedBox(height: 10),
                    Text('Status: ${project.status}'),
                    Text('Budget: Rs ${project.budget.toStringAsFixed(0)}'),
                    Text('Progress: ${project.progress}%'),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              OutlinedButton.icon(
                onPressed: () => _openMentorChat(project),
                icon: const Icon(Icons.chat_bubble_outline),
                label: const Text('Message Mentor'),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () => _openMatches(project),
                icon: const Icon(Icons.psychology_alt_outlined),
                label: const Text('View Mentor Matches'),
              ),
              const SizedBox(height: 12),
              _timeline(project.id),
              const SizedBox(height: 14),
              if (isDelivered) ...[
                ElevatedButton(
                  onPressed: _isBusy ? null : () => _approve(project),
                  child: _isBusy
                      ? const CircularProgressIndicator(strokeWidth: 2)
                      : const Text('Approve Delivery'),
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: _isBusy ? null : () => _requestRevision(project),
                  child: const Text('Request Revision'),
                ),
              ] else if (isCompleted) ...[
                _completionActions(project),
              ] else ...[
                const ListTile(
                  leading: Icon(Icons.schedule, color: AppColors.warning),
                  title: Text('Waiting for mentor delivery update...'),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
