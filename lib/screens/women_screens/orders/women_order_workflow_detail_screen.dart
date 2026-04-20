import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../constants/app_colors.dart';
import '../../../models/order_event_model.dart';
import '../../../models/project_model.dart';
import '../../client_screens/chatscreen/client_detail_chat_screen.dart';
import '../../../services/chat_service.dart';
import '../../../services/supabase_database_service.dart';

class MentorOrderWorkflowDetailScreen extends StatefulWidget {
  final String userId;
  final String projectId;

  const MentorOrderWorkflowDetailScreen({
    super.key,
    required this.userId,
    required this.projectId,
  });

  @override
  State<MentorOrderWorkflowDetailScreen> createState() => _MentorOrderWorkflowDetailScreenState();
}

class _MentorOrderWorkflowDetailScreenState extends State<MentorOrderWorkflowDetailScreen> {
  final _db = GetIt.instance<SupabaseDatabaseService>();
  final _chatService = ChatService();
  bool _isSubmitting = false;

  Future<void> _submitDelivery(ProjectModel project) async {
    final controller = TextEditingController();
    final note = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Submit Delivery'),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Add delivery summary for client',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Submit'),
          ),
        ],
      ),
    );

    if (note == null || note.isEmpty || _isSubmitting) return;

    setState(() => _isSubmitting = true);
    try {
      await _db.submitOrderDelivery(
        projectId: project.id,
        mentorId: widget.userId,
        deliveryNote: note,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Delivery submitted to client.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not submit delivery: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _openClientChat(ProjectModel project) async {
    try {
      final otherUser = await _db.getUser(project.clientId);
      if (otherUser == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open chat right now.')),
        );
        return;
      }

      final authUser = Supabase.instance.client.auth.currentUser;
      final currentName = authUser?.userMetadata?['display_name']
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open chat: $e')),
      );
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
                      const Icon(Icons.fiber_manual_record, size: 10, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _eventTitle(event.eventType),
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            if (event.note != null && event.note!.trim().isNotEmpty)
                              Text(
                                event.note!,
                                style: const TextStyle(color: AppColors.textSecondary),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Order Details')),
      body: StreamBuilder<ProjectModel?>(
        stream: _db.streamProject(widget.projectId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final project = snapshot.data;
          if (project == null) {
            return const Center(child: Text('Order not found'));
          }

          final status = project.status.toLowerCase();
          final canDeliver = status == 'in-progress' || status == 'pending';

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
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
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
                onPressed: () => _openClientChat(project),
                icon: const Icon(Icons.chat_bubble_outline),
                label: const Text('Message Client'),
              ),
              const SizedBox(height: 12),
              _timeline(project.id),
              const SizedBox(height: 14),
              if (canDeliver)
                ElevatedButton(
                  onPressed: _isSubmitting ? null : () => _submitDelivery(project),
                  child: _isSubmitting
                      ? const CircularProgressIndicator(strokeWidth: 2)
                      : const Text('Submit Delivery'),
                )
              else if (status == 'delivered')
                const ListTile(
                  leading: Icon(Icons.hourglass_top, color: AppColors.warning),
                  title: Text('Delivery submitted. Waiting for client approval.'),
                )
              else if (status == 'completed')
                const ListTile(
                  leading: Icon(Icons.check_circle, color: Colors.green),
                  title: Text('Order completed and approved.'),
                )
              else
                const SizedBox.shrink(),
            ],
          );
        },
      ),
    );
  }
}
