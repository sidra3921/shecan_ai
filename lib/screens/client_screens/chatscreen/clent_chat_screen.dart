import 'package:flutter/material.dart';
import 'package:shecan_ai/screens/client_screens/chatscreen/client_detail_chat_screen.dart';
import '../../../constants/app_colors.dart';
import '../../../models/chat_model.dart';
import '../../../models/user_model.dart';
import '../../../services/supabase_auth_service.dart';
import '../../../services/supabase_database_service.dart';
import '../../../services/chat_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.userId});

  final String userId;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _chatService = ChatService();
  final _authService = SupabaseAuthService();
  final _dbService = SupabaseDatabaseService();
  bool _isStartingConversation = false;

  Future<void> _showChatCreateOptions() async {
    if (_isStartingConversation) return;

    final action = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.auto_awesome),
                title: const Text('Chat with AI Assistant'),
                subtitle: const Text('Ask about skills, jobs & mentors'),
                onTap: () => Navigator.pop(context, 'ai'),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.chat_bubble_outline),
                title: const Text('Start direct chat'),
                onTap: () => Navigator.pop(context, 'direct'),
              ),
              ListTile(
                leading: const Icon(Icons.groups_outlined),
                title: const Text('Create community group'),
                onTap: () => Navigator.pop(context, 'community'),
              ),
            ],
          ),
        );
      },
    );

    if (!mounted || action == null) return;
    if (action == 'ai') {
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatDetailScreen(
            title: 'SheCan AI Assistant',
            isAI: true,
            currentUserId: widget.userId,
          ),
        ),
      );
      return;
    }
    if (action == 'direct') {
      await _startNewConversation();
      return;
    }
    if (action == 'community') {
      await _createCommunityConversation();
    }
  }

  Future<void> _createCommunityConversation() async {
    if (_isStartingConversation) return;

    setState(() => _isStartingConversation = true);
    try {
      final mentors = await _dbService.getUsersByType(
        'mentor',
        excludeUserId: widget.userId,
      );
      final clients = await _dbService.getUsersByType(
        'client',
        excludeUserId: widget.userId,
      );

      final candidatesById = <String, UserModel>{
        for (final user in [...mentors, ...clients]) user.id: user,
      };
      final candidates = candidatesById.values.toList()
        ..sort(
          (a, b) => a.displayName.toLowerCase().compareTo(
            b.displayName.toLowerCase(),
          ),
        );

      if (!mounted) return;
      if (candidates.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No users available to add in a community.'),
          ),
        );
        return;
      }

      final nameController = TextEditingController();
      final selectedIds = <String>{};

      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setDialogState) {
              return AlertDialog(
                title: const Text('Create Community'),
                content: SizedBox(
                  width: 420,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: nameController,
                          decoration: const InputDecoration(
                            labelText: 'Community name',
                            hintText: 'Women Flutter Learners',
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Select members',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...candidates.map((user) {
                          final selected = selectedIds.contains(user.id);
                          return CheckboxListTile(
                            dense: true,
                            controlAffinity: ListTileControlAffinity.leading,
                            value: selected,
                            title: Text(user.displayName),
                            subtitle: Text(user.email),
                            onChanged: (checked) {
                              setDialogState(() {
                                if (checked == true) {
                                  selectedIds.add(user.id);
                                } else {
                                  selectedIds.remove(user.id);
                                }
                              });
                            },
                          );
                        }),
                      ],
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Create'),
                  ),
                ],
              );
            },
          );
        },
      );

      if (!mounted || confirmed != true) return;

      final groupName = nameController.text.trim();
      if (groupName.isEmpty || selectedIds.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Add a group name and select at least one member.'),
          ),
        );
        return;
      }

      final selectedUsers = selectedIds
          .map((id) => candidatesById[id])
          .whereType<UserModel>()
          .toList();

      final authUser = _authService.currentUser;
      final currentName =
          authUser?.userMetadata?['display_name']
                  ?.toString()
                  .trim()
                  .isNotEmpty ==
              true
          ? authUser!.userMetadata!['display_name'].toString().trim()
          : (authUser?.email?.split('@').first ?? 'You');

      final conversation = await _chatService.createCommunityConversation(
        creatorId: widget.userId,
        creatorName: currentName,
        communityName: groupName,
        members: selectedUsers,
      );

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatDetailScreen(
            title: conversation.displayTitle,
            isAI: false,
            currentUserId: widget.userId,
            conversation: conversation,
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _isStartingConversation = false);
    }
  }

  Future<void> _startNewConversation() async {
    if (_isStartingConversation) return;

    setState(() => _isStartingConversation = true);
    try {
      final userType = await _authService.getCurrentUserType() ?? 'client';
      final targetType = userType == 'mentor' ? 'client' : 'mentor';
      final contacts = await _dbService.getUsersByType(
        targetType,
        excludeUserId: widget.userId,
      );

      if (!mounted) return;

      if (contacts.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No $targetType users found to chat with.')),
        );
        return;
      }

      final selected = await showModalBottomSheet<UserModel>(
        context: context,
        showDragHandle: true,
        builder: (context) {
          return SafeArea(
            child: ListView.builder(
              itemCount: contacts.length,
              itemBuilder: (context, index) {
                final user = contacts[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primaryLight,
                    backgroundImage: user.photoURL.isNotEmpty
                        ? NetworkImage(user.photoURL)
                        : null,
                    child: user.photoURL.isEmpty
                        ? const Icon(Icons.person, color: Colors.white)
                        : null,
                  ),
                  title: Text(user.displayName),
                  subtitle: Text(user.email),
                  onTap: () => Navigator.pop(context, user),
                );
              },
            ),
          );
        },
      );

      if (!mounted || selected == null) return;

      final authUser = _authService.currentUser;
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
        otherUser: selected,
      );

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatDetailScreen(
            title: selected.displayName,
            isAI: false,
            currentUserId: widget.userId,
            conversation: conversation,
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _isStartingConversation = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.background,
        title: const Text("Chats"),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _isStartingConversation ? null : _showChatCreateOptions,
            icon: _isStartingConversation
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.add_comment_outlined),
            tooltip: 'New Chat',
          ),
        ],
      ),

      body: StreamBuilder<List<Conversation>>(
        stream: _chatService.getConversationsStream(widget.userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Failed to load conversations',
                style: TextStyle(color: AppColors.error),
              ),
            );
          }

          final conversations = snapshot.data ?? const <Conversation>[];

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _chatCard(
                context,
                name: 'SheCan AI Assistant',
                message: 'Ask anything about skills, jobs or mentors...',
                icon: Icons.auto_awesome,
                isAI: true,
              ),
              const SizedBox(height: 10),
              if (conversations.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 40),
                  child: Center(
                    child: Text(
                      'No conversations yet',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                ),
              ...conversations.map(
                (conversation) => _conversationCard(context, conversation),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _conversationCard(BuildContext context, Conversation conversation) {
    final name = conversation.displayTitle;
    final preview = conversation.lastMessage.isEmpty
        ? 'Start your conversation'
        : conversation.lastMessage;

    return _chatCard(
      context,
      name: name,
      message: conversation.isGroup && conversation.displaySubtitle.isNotEmpty
          ? '${conversation.displaySubtitle} • $preview'
          : preview,
      icon: conversation.isGroup ? Icons.groups : Icons.person,
      avatarUrl: conversation.isGroup
          ? conversation.groupAvatarUrl
          : conversation.otherUserAvatar,
      isAI: false,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatDetailScreen(
              title: name,
              isAI: false,
              currentUserId: widget.userId,
              conversation: conversation,
            ),
          ),
        );
      },
    );
  }

  Widget _chatCard(
    BuildContext context, {
    required String name,
    required String message,
    required IconData icon,
    required bool isAI,
    String? avatarUrl,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap:
          onTap ??
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChatDetailScreen(
                  title: 'SheCan AI Assistant',
                  isAI: true,
                  currentUserId: widget.userId,
                ),
              ),
            );
          },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: isAI
                  ? AppColors.primary
                  : AppColors.primaryLight,
              backgroundImage:
                  (avatarUrl != null && avatarUrl.trim().isNotEmpty)
                  ? NetworkImage(avatarUrl)
                  : null,
              child: (avatarUrl == null || avatarUrl.trim().isEmpty)
                  ? Icon(icon, color: Colors.white)
                  : null,
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            const Icon(Icons.arrow_forward_ios, size: 14),
          ],
        ),
      ),
    );
  }
}
