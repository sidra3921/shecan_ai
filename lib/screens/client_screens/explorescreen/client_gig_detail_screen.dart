import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../constants/app_colors.dart';
import '../../../models/mentor_gig_model.dart';
import '../../../models/project_model.dart';
import '../../../services/chat_service.dart';
import '../../../services/session_service.dart';
import '../../../services/supabase_database_service.dart';
import '../chatscreen/client_detail_chat_screen.dart';

class ClientGigDetailScreen extends StatefulWidget {
  final MentorGigModel gig;

  const ClientGigDetailScreen({super.key, required this.gig});

  @override
  State<ClientGigDetailScreen> createState() => _ClientGigDetailScreenState();
}

class _ClientGigDetailScreenState extends State<ClientGigDetailScreen> {
  bool _isHiring = false;
  bool _isSaveBusy = false;
  String? _currentUserId;
  late final SupabaseDatabaseService _db;

  @override
  void initState() {
    super.initState();
    _db = GetIt.instance<SupabaseDatabaseService>();
    final session = GetIt.instance<SessionService>();
    _currentUserId = session.currentUserId;
  }

  Future<void> _toggleSavedGig(bool isSaved) async {
    if (_isSaveBusy) return;

    final userId = _currentUserId;
    if (userId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please sign in first.')));
      return;
    }

    setState(() => _isSaveBusy = true);
    try {
      bool nowSaved;
      if (isSaved) {
        await _db.removeSavedGig(userId: userId, gigId: widget.gig.id);
        nowSaved = false;
      } else {
        nowSaved = await _db.toggleSavedGig(
          userId: userId,
          gigId: widget.gig.id,
          gigTitle: widget.gig.title,
        );
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            nowSaved
                ? 'Mentor saved to your list.'
                : 'Mentor removed from saved list.',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaveBusy = false);
    }
  }

  double _toDouble(dynamic value, {double fallback = 0}) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? fallback;
  }

  int _toInt(dynamic value, {int fallback = 5}) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }

  String _currentUserDisplayName() {
    final authUser = Supabase.instance.client.auth.currentUser;
    final metadataName = authUser?.userMetadata?['display_name']?.toString();
    if (metadataName != null && metadataName.trim().isNotEmpty) {
      return metadataName.trim();
    }
    final email = authUser?.email ?? '';
    if (email.contains('@')) {
      return email.split('@').first;
    }
    return 'Client';
  }

  Future<void> _hirePackage(Map<String, dynamic> package) async {
    if (_isHiring) return;

    final session = GetIt.instance<SessionService>();
    final db = GetIt.instance<SupabaseDatabaseService>();
    final chatService = GetIt.instance<ChatService>();

    final currentUserId = session.currentUserId;
    if (currentUserId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please sign in first.')));
      return;
    }

    if (currentUserId == widget.gig.mentorId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You cannot hire your own service.')),
      );
      return;
    }

    setState(() => _isHiring = true);

    try {
      final mentor = await db.getUser(widget.gig.mentorId);
      if (mentor == null) {
        throw Exception('Mentor profile not found');
      }

      final packageName = package['name']?.toString() ?? 'Standard';
      final packagePrice = _toDouble(
        package['price'],
        fallback: widget.gig.hourlyRate > 0 ? widget.gig.hourlyRate : 2500,
      );
      final deliveryDays = _toInt(package['deliveryDays'], fallback: 5);
      final packageDescription =
          package['description']?.toString() ??
          'Please proceed with this package for the selected gig.';

      final project = ProjectModel(
        id: '',
        title: '${widget.gig.title} - $packageName Package',
        description:
            '$packageDescription\n\nGig: ${widget.gig.description}\n\nCategory: ${widget.gig.category ?? 'general'}',
        budget: packagePrice,
        deadline: DateTime.now().add(Duration(days: deliveryDays)),
        status: 'pending',
        clientId: currentUserId,
        mentorId: widget.gig.mentorId,
        skills: widget.gig.skills,
        category: widget.gig.category,
        experienceLevel: widget.gig.experienceLevel,
      );

      final projectId = await db.createProject(project);

      final conversation = await chatService.getOrCreateDirectConversation(
        currentUserId: currentUserId,
        currentUserName: _currentUserDisplayName(),
        otherUser: mentor,
      );

      await chatService.sendMessage(
        conversationId: conversation.id,
        senderId: currentUserId,
        senderName: _currentUserDisplayName(),
        senderAvatar: '',
        content:
            'Hi ${mentor.displayName}, I hired your $packageName package for "${widget.gig.title}". Project ID: $projectId. Budget: Rs ${packagePrice.toStringAsFixed(0)}. Delivery: $deliveryDays days.',
      );

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatDetailScreen(
            title: mentor.displayName,
            isAI: false,
            currentUserId: currentUserId,
            conversation: conversation,
          ),
        ),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Package hired. Project + chat started.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not hire package: $e')));
    } finally {
      if (mounted) setState(() => _isHiring = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final db = _db;
    final packages = widget.gig.packages.isEmpty
        ? [
            {
              'name': 'Standard',
              'price': widget.gig.hourlyRate > 0 ? widget.gig.hourlyRate : 2500,
              'deliveryDays': 5,
              'description': 'Default package for this gig.',
            },
          ]
        : widget.gig.packages;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.background,
        title: const Text('Gig Details'),
        actions: [
          if (_currentUserId != null)
            StreamBuilder<Set<String>>(
              stream: db.streamSavedGigIds(_currentUserId!),
              builder: (context, snapshot) {
                final isSaved = (snapshot.data ?? const <String>{}).contains(
                  widget.gig.id,
                );
                return IconButton(
                  onPressed: _isSaveBusy
                      ? null
                      : () => _toggleSavedGig(isSaved),
                  icon: Icon(
                    isSaved ? Icons.favorite : Icons.favorite_border,
                    color: isSaved ? Colors.red : null,
                  ),
                  tooltip: isSaved ? 'Unsave mentor' : 'Save mentor',
                );
              },
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: widget.gig.imageUrl.isNotEmpty
                ? Image.network(
                    widget.gig.imageUrl,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 200,
                      color: AppColors.surface,
                      alignment: Alignment.center,
                      child: const Icon(Icons.image_not_supported_outlined),
                    ),
                  )
                : Container(
                    height: 200,
                    color: AppColors.surface,
                    alignment: Alignment.center,
                    child: const Icon(Icons.design_services_outlined, size: 38),
                  ),
          ),
          const SizedBox(height: 14),
          Text(
            widget.gig.title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            '${widget.gig.category ?? 'general'} • ${widget.gig.experienceLevel ?? 'intermediate'}',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 10),
          Text(widget.gig.description),
          if (widget.gig.skills.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.gig.skills
                  .map(
                    (s) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(s, style: const TextStyle(fontSize: 12)),
                    ),
                  )
                  .toList(),
            ),
          ],
          const SizedBox(height: 18),
          const Text(
            'Choose a package',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          ...packages.map((p) {
            final name = p['name']?.toString() ?? 'Package';
            final price = _toDouble(p['price']);
            final days = _toInt(p['deliveryDays']);
            final desc = p['description']?.toString() ?? '';

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        'Rs ${price.toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('Delivery: $days days'),
                  const SizedBox(height: 8),
                  Text(desc),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary, // button bg color
                        foregroundColor: Colors.white, // text/icon color
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 14,
                        ),
                      ),

                      onPressed: _isHiring ? null : () => _hirePackage(p),

                      child: _isHiring
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              'Hire This Package ($name)',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
