import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../constants/app_colors.dart';
import '../../../models/chat_model.dart';
import '../../../models/user_model.dart';
import '../../../services/ai_service.dart';
import '../../../services/chat_service.dart';
import '../../../services/content_moderation_service.dart';
import '../../../services/supabase_database_service.dart';
import '../../../services/supabase_storage_service.dart';

class _PendingMessage {
  final String id;
  final String content;
  final DateTime timestamp;

  _PendingMessage({
    required this.id,
    required this.content,
    required this.timestamp,
  });
}

class ChatDetailScreen extends StatefulWidget {
  final String title;
  final bool isAI;
  final Conversation? conversation;
  final String? currentUserId;

  const ChatDetailScreen({
    super.key,
    required this.title,
    required this.isAI,
    this.conversation,
    this.currentUserId,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _controller = TextEditingController();
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();
  bool _isSending = false;
  final _chatService = ChatService();
  final _dbService = SupabaseDatabaseService();
  final _storageService = SupabaseStorageService();
  final _aiService = AIService();
  final List<_PendingMessage> _pendingMessages = [];
  bool _isOtherTyping = false;
  bool _isAiResponding = false;
  bool _isListening = false;
  bool _speechAvailable = false;
  bool _ttsEnabled = true;
  bool _ttsReady = false;
  bool _autoSendVoice = true;
  String _speechStatusNote = '';
  String _speechErrorNote = '';
  String? _speechLocaleId;
  DateTime? _lastReadSyncAt;
  String? _otherUserId;
  Conversation? _conversation;
  List<String> _typingUsers = [];
  StreamSubscription<dynamic>? _typingSubscription;

  Conversation? get _activeConversation => _conversation ?? widget.conversation;
  bool get _isGroupChat => _activeConversation?.isGroup == true;
  String? get _currentUserId => widget.currentUserId;
  bool get _canManageGroup {
    final conversation = _activeConversation;
    final userId = _currentUserId;
    if (conversation == null || userId == null) return false;
    return conversation.canManageGroup(userId);
  }

  final List<Map<String, String>> messages = [
    {"role": "bot", "text": "Hello! How can I help you today?"},
  ];

  @override
  void initState() {
    super.initState();
    _conversation = widget.conversation;
    _ttsEnabled = widget.isAI;
    if (!widget.isAI &&
        widget.conversation != null &&
        widget.currentUserId != null) {
      final currentUserId = widget.currentUserId!;
      if (!_isGroupChat) {
        final ids = _activeConversation!.participantIds;
        _otherUserId = ids.firstWhere(
          (id) => id != currentUserId,
          orElse: () => '',
        );
      }

      _typingSubscription?.cancel();
      if (_isGroupChat) {
        final names = _activeConversation!.visibleParticipantNames;
        _typingSubscription = _chatService
            .streamTypingUsers(
              conversationId: _activeConversation!.id,
              currentUserId: currentUserId,
              participantNames: names,
            )
            .listen((typingUsers) {
              if (!mounted) return;
              setState(() => _typingUsers = typingUsers);
            });
      } else if (_otherUserId != null && _otherUserId!.isNotEmpty) {
        _typingSubscription = _chatService
            .streamTypingStatus(
              conversationId: _activeConversation!.id,
              otherUserId: _otherUserId!,
            )
            .listen((typing) {
              if (!mounted) return;
              setState(() => _isOtherTyping = typing);
            });
      }

      _chatService.setPresence(userId: currentUserId, isOnline: true);
    }

    _controller.addListener(_onInputChanged);
    _initSpeech();
    _initTts();
  }

  @override
  void dispose() {
    _controller.removeListener(_onInputChanged);
    _typingSubscription?.cancel();
    _speech.stop();
    _tts.stop();
    if (!widget.isAI && widget.currentUserId != null) {
      _chatService.setPresence(userId: widget.currentUserId!, isOnline: false);
      final c = _activeConversation;
      if (c != null) {
        _chatService.setTypingStatus(
          conversationId: c.id,
          userId: widget.currentUserId!,
          isTyping: false,
        );
      }
    }
    _controller.dispose();
    super.dispose();
  }

  Future<void> _initSpeech() async {
    if (!widget.isAI) return;
    final available = await _speech.initialize(
      onStatus: _handleSpeechStatus,
      onError: _handleSpeechError,
    );
    if (!mounted) return;
    setState(() {
      _speechAvailable = available;
      _speechStatusNote = available
          ? 'Speech ready'
          : 'Speech unavailable on this browser';
      _speechErrorNote = '';
    });
    if (available) {
      final locale = await _speech.systemLocale();
      if (!mounted) return;
      _speechLocaleId = locale?.localeId;
    }
  }

  Future<bool> _ensureSpeechReady() async {
    if (_speechAvailable) return true;
    final available = await _speech.initialize(
      onStatus: _handleSpeechStatus,
      onError: _handleSpeechError,
    );
    if (!mounted) return false;
    setState(() {
      _speechAvailable = available;
      _speechStatusNote = available
          ? 'Speech ready'
          : 'Speech unavailable on this browser';
      _speechErrorNote = '';
    });
    if (available) {
      final locale = await _speech.systemLocale();
      if (!mounted) return false;
      _speechLocaleId = locale?.localeId;
    }
    return available;
  }

  Future<void> _initTts() async {
    if (!widget.isAI) return;
    await _tts.awaitSpeakCompletion(true);
    await _tts.setSpeechRate(0.45);
    await _tts.setPitch(1.0);
    await _tts.setVolume(1.0);
    if (!mounted) return;
    setState(() => _ttsReady = true);
  }

  void _handleSpeechStatus(String status) {
    if (!mounted) return;
    if (status == 'notListening' || status == 'done') {
      setState(() => _isListening = false);
    }
    setState(() => _speechStatusNote = 'Speech status: $status');
  }

  void _handleSpeechError(dynamic error) {
    if (!mounted) return;
    setState(() => _isListening = false);
    setState(() => _speechErrorNote = error.toString());
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Speech recognition error: ${error.toString()}'),
      ),
    );
  }

  Future<void> _toggleListening() async {
    if (!await _ensureSpeechReady()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Speech recognition unavailable. Check microphone permission.',
          ),
        ),
      );
      return;
    }
    if (_isListening) {
      await _speech.stop();
      if (!mounted) return;
      setState(() => _isListening = false);
      return;
    }

    final started = await _speech.listen(
      onResult: (result) {
        if (!mounted) return;
        setState(() {
          _controller.text = result.recognizedWords;
          _controller.selection = TextSelection.fromPosition(
            TextPosition(offset: _controller.text.length),
          );
          if (result.finalResult) {
            _isListening = false;
            _speechStatusNote = 'Speech final result received';
          }
        });
        if (result.finalResult &&
            _autoSendVoice &&
            !_isAiResponding &&
            _controller.text.trim().isNotEmpty) {
          Future<void>.delayed(Duration.zero, sendMessage);
        }
      },
      listenMode: stt.ListenMode.dictation,
      localeId: _speechLocaleId,
      listenFor: const Duration(seconds: 60),
      pauseFor: const Duration(seconds: 3),
      partialResults: true,
      cancelOnError: true,
    );

    if (!mounted) return;
    setState(() => _isListening = started);
    if (!started) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not start listening. Check microphone permissions.',
          ),
        ),
      );
      setState(() => _speechStatusNote = 'Speech listen failed to start');
    } else {
      setState(() => _speechStatusNote = 'Listening...');
    }
  }

  void _toggleTts() {
    setState(() => _ttsEnabled = !_ttsEnabled);
    if (!_ttsEnabled) {
      _tts.stop();
    }
  }

  Future<void> _speak(String text) async {
    if (!widget.isAI || !_ttsEnabled || !_ttsReady) return;
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    await _tts.stop();
    await _tts.speak(trimmed);
  }

  void _onInputChanged() {
    if (widget.isAI ||
        widget.conversation == null ||
        widget.currentUserId == null) {
      return;
    }

    _chatService.setTypingStatus(
      conversationId: _activeConversation!.id,
      userId: widget.currentUserId!,
      isTyping: _controller.text.trim().isNotEmpty,
    );
  }

  Future<void> _refreshConversation() async {
    final c = _activeConversation;
    final userId = _currentUserId;
    if (c == null || userId == null) return;

    final latest = await _chatService.getConversationById(c.id, userId);
    if (!mounted || latest == null) return;
    setState(() => _conversation = latest);
  }

  Future<void> _renameCommunity() async {
    final c = _activeConversation;
    final userId = _currentUserId;
    if (c == null || userId == null) return;

    final controller = TextEditingController(text: c.groupName);
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename Community'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Community name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (name == null || name.trim().isEmpty) return;
    try {
      final updated = await _chatService.renameCommunity(
        conversationId: c.id,
        adminUserId: userId,
        newName: name,
      );
      if (!mounted || updated == null) return;
      setState(() => _conversation = updated);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not rename community: $e')));
    }
  }

  Future<void> _changeCommunityAvatar() async {
    final c = _activeConversation;
    final userId = _currentUserId;
    if (c == null || userId == null) return;

    try {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (picked == null) return;

      final bytes = await picked.readAsBytes();
      final parts = picked.name.split('.');
      final ext = parts.length > 1 ? parts.last.toLowerCase() : 'jpg';

      final url = await _storageService.uploadCommunityImageBytes(
        communityId: c.id,
        bytes: bytes,
        extension: ext,
      );

      final updated = await _chatService.updateCommunityAvatar(
        conversationId: c.id,
        adminUserId: userId,
        avatarUrl: url,
      );
      if (!mounted || updated == null) return;
      setState(() => _conversation = updated);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not update community image: $e')),
      );
    }
  }

  Future<void> _addMembersToCommunity() async {
    final c = _activeConversation;
    final userId = _currentUserId;
    if (c == null || userId == null) return;

    try {
      final mentors = await _dbService.getUsersByType(
        'mentor',
        excludeUserId: userId,
      );
      final clients = await _dbService.getUsersByType(
        'client',
        excludeUserId: userId,
      );
      final existing = c.participantIds.toSet();

      final options =
          <String, UserModel>{
            for (final user in [...mentors, ...clients]) user.id: user,
          }.values.where((u) => !existing.contains(u.id)).toList()..sort(
            (a, b) => a.displayName.toLowerCase().compareTo(
              b.displayName.toLowerCase(),
            ),
          );

      if (!mounted) return;
      if (options.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No additional users available to add.'),
          ),
        );
        return;
      }

      final selected = <String>{};
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setDialogState) {
              return AlertDialog(
                title: const Text('Add Members'),
                content: SizedBox(
                  width: 420,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: options.map((user) {
                        final checked = selected.contains(user.id);
                        return CheckboxListTile(
                          dense: true,
                          controlAffinity: ListTileControlAffinity.leading,
                          value: checked,
                          title: Text(user.displayName),
                          subtitle: Text(user.email),
                          onChanged: (value) {
                            setDialogState(() {
                              if (value == true) {
                                selected.add(user.id);
                              } else {
                                selected.remove(user.id);
                              }
                            });
                          },
                        );
                      }).toList(),
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
                    child: const Text('Add'),
                  ),
                ],
              );
            },
          );
        },
      );

      if (confirmed != true || selected.isEmpty) return;

      final users = options.where((u) => selected.contains(u.id)).toList();
      final updated = await _chatService.addMembersToCommunity(
        conversationId: c.id,
        adminUserId: userId,
        newMembers: users,
      );
      if (!mounted || updated == null) return;
      setState(() => _conversation = updated);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not add members: $e')));
    }
  }

  Future<void> _removeMembersFromCommunity() async {
    final c = _activeConversation;
    final userId = _currentUserId;
    if (c == null || userId == null) return;

    final memberIds = c.visibleParticipantNames.keys
        .where((id) => id != userId)
        .toList();

    if (memberIds.isEmpty) return;

    final selectedMemberId = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: memberIds.map((id) {
              final name = c.visibleParticipantNames[id] ?? 'Member';
              return ListTile(
                leading: const Icon(Icons.person_remove_outlined),
                title: Text(name),
                subtitle: Text(id),
                onTap: () => Navigator.pop(context, id),
              );
            }).toList(),
          ),
        );
      },
    );

    if (selectedMemberId == null) return;

    try {
      final updated = await _chatService.removeMemberFromCommunity(
        conversationId: c.id,
        adminUserId: userId,
        memberId: selectedMemberId,
      );
      if (!mounted || updated == null) return;
      setState(() => _conversation = updated);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not remove member: $e')));
    }
  }

  Future<void> _openGroupActions() async {
    final c = _activeConversation;
    if (c == null || !_isGroupChat) return;

    final action = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.refresh),
                title: const Text('Refresh community info'),
                onTap: () => Navigator.pop(context, 'refresh'),
              ),
              if (_canManageGroup) ...[
                ListTile(
                  leading: const Icon(Icons.drive_file_rename_outline),
                  title: const Text('Rename community'),
                  onTap: () => Navigator.pop(context, 'rename'),
                ),
                ListTile(
                  leading: const Icon(Icons.image_outlined),
                  title: const Text('Change community image'),
                  onTap: () => Navigator.pop(context, 'avatar'),
                ),
                ListTile(
                  leading: const Icon(Icons.group_add_outlined),
                  title: const Text('Add members'),
                  onTap: () => Navigator.pop(context, 'add_members'),
                ),
                ListTile(
                  leading: const Icon(Icons.person_remove_outlined),
                  title: const Text('Remove member'),
                  onTap: () => Navigator.pop(context, 'remove_member'),
                ),
              ],
            ],
          ),
        );
      },
    );

    if (action == null) return;
    if (action == 'refresh') {
      await _refreshConversation();
      return;
    }
    if (action == 'rename') {
      await _renameCommunity();
      return;
    }
    if (action == 'avatar') {
      await _changeCommunityAvatar();
      return;
    }
    if (action == 'add_members') {
      await _addMembersToCommunity();
      return;
    }
    if (action == 'remove_member') {
      await _removeMembersFromCommunity();
      return;
    }
  }

  String _groupTypingLabel(List<String> users) {
    if (users.isEmpty) return '';
    if (users.length == 1) return '${users.first} is typing...';
    if (users.length == 2) return '${users[0]} and ${users[1]} are typing...';
    return '${users[0]} and ${users.length - 1} others are typing...';
  }

  Future<void> sendMessage() async {
    if (_controller.text.isEmpty) return;
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    if (_isListening) {
      await _speech.stop();
      if (!mounted) return;
      setState(() => _isListening = false);
    }
    try {
      ContentModerationService().validateText(text);
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(ContentModerationService.violationMessage),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (widget.isAI) {
      final historyBeforeSend = messages
          .where((item) => (item['text'] ?? '').trim().isNotEmpty)
          .map(
            (item) => <String, String>{
              'role': item['role'] ?? 'user',
              'text': item['text'] ?? '',
            },
          )
          .toList()
          .reversed
          .take(10)
          .toList();

      setState(() {
        messages.add({"role": "user", "text": text});
        messages.add({"role": "bot", "text": ""});
        _isAiResponding = true;
        _controller.clear();
      });

      try {
        final assistantText = await _aiService.generateAssistantReply(
          userId: widget.currentUserId ?? 'guest',
          userMessage: text,
          history: historyBeforeSend,
        );

        await for (final partial in _aiService.streamTextDraft(assistantText)) {
          if (!mounted) return;
          setState(() {
            messages[messages.length - 1] = {"role": "bot", "text": partial};
          });
        }
        await _speak(assistantText);
      } catch (e) {
        if (!mounted) return;
        setState(() {
          messages.removeLast();
          _controller.text = text;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(ContentModerationService.violationMessage),
            backgroundColor: AppColors.error,
          ),
        );
      }

      if (!mounted) return;
      setState(() => _isAiResponding = false);
      return;
    }

    final conversation = widget.conversation;
    final currentUserId = widget.currentUserId;
    if (conversation == null || currentUserId == null) return;

    final authUser = Supabase.instance.client.auth.currentUser;
    final senderName =
        authUser?.userMetadata?['display_name']?.toString() ??
        authUser?.email?.toString() ??
        'You';

    final optimisticId = 'pending_${DateTime.now().microsecondsSinceEpoch}';
    setState(() {
      _isSending = true;
      _pendingMessages.add(
        _PendingMessage(
          id: optimisticId,
          content: text,
          timestamp: DateTime.now(),
        ),
      );
      _controller.clear();
    });

    try {
      await _chatService.sendMessage(
        conversationId: _activeConversation!.id,
        senderId: currentUserId,
        senderName: senderName,
        senderAvatar: '',
        content: text,
      );
      if (!mounted) return;
      setState(() {
        _pendingMessages.removeWhere((m) => m.id == optimisticId);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _pendingMessages.removeWhere((m) => m.id == optimisticId);
        _controller.text = text;
        _controller.selection = TextSelection.fromPosition(
          TextPosition(offset: _controller.text.length),
        );
      });
      final message =
          e.toString().contains(ContentModerationService.violationMessage)
          ? ContentModerationService.violationMessage
          : 'Failed to send message: $e';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.background,
        title:
            widget.isAI ||
                _isGroupChat ||
                _otherUserId == null ||
                _otherUserId!.isEmpty
            ? Text(widget.title)
            : StreamBuilder<PresenceStatus>(
                stream: _chatService.streamPresence(_otherUserId!),
                builder: (context, snapshot) {
                  final presence = snapshot.data;
                  final subtitle = presence == null
                      ? ''
                      : (presence.isOnline
                            ? 'Online'
                            : (presence.lastSeenAt == null
                                  ? 'Offline'
                                  : 'Last seen recently'));
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.title),
                      if (subtitle.isNotEmpty)
                        Text(
                          subtitle,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                    ],
                  );
                },
              ),
        actions: [
          if (widget.isAI)
            IconButton(
              onPressed: _toggleTts,
              icon: Icon(
                _ttsEnabled
                    ? Icons.volume_up_outlined
                    : Icons.volume_off_outlined,
              ),
              tooltip: _ttsEnabled ? 'Voice replies on' : 'Voice replies off',
            ),
          if (_isGroupChat)
            IconButton(
              onPressed: _openGroupActions,
              icon: const Icon(Icons.settings_outlined),
              tooltip: 'Community settings',
            ),
        ],
        elevation: 0,
      ),

      body: Column(
        children: [
          //  Messages
          Expanded(
            child: widget.isAI
                ? ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index];
                      final isUser = msg["role"] == "user";
                      return _messageBubble(
                        isUser: isUser,
                        text: msg["text"] ?? '',
                        isMarkdown: widget.isAI && !isUser,
                      );
                    },
                  )
                : StreamBuilder<List<ChatMessage>>(
                    stream: _chatService.getMessagesStream(
                      _activeConversation!.id,
                    ),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            'Failed to load messages',
                            style: TextStyle(color: AppColors.error),
                          ),
                        );
                      }

                      final rows = snapshot.data ?? const <ChatMessage>[];
                      final ordered = rows.reversed.toList();

                      final now = DateTime.now();
                      final shouldSyncRead =
                          _lastReadSyncAt == null ||
                          now.difference(_lastReadSyncAt!).inSeconds >= 2;
                      if (shouldSyncRead && widget.currentUserId != null) {
                        _lastReadSyncAt = now;
                        _chatService.markConversationAsRead(
                          conversationId: _activeConversation!.id,
                          currentUserId: widget.currentUserId!,
                        );
                      }

                      final pendingUi = _pendingMessages
                          .map(
                            (p) => ChatMessage(
                              id: p.id,
                              conversationId: _activeConversation!.id,
                              senderId: widget.currentUserId ?? '',
                              senderName: 'You',
                              senderAvatar: '',
                              content: p.content,
                              timestamp: p.timestamp,
                              readBy: const [],
                              isRead: false,
                            ),
                          )
                          .toList();

                      final merged = [...ordered, ...pendingUi]
                        ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

                      if (merged.isEmpty) {
                        return const Center(
                          child: Text(
                            'No messages yet. Start the conversation.',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        );
                      }

                      return Column(
                        children: [
                          if (_isAiResponding)
                            const Padding(
                              padding: EdgeInsets.only(
                                left: 16,
                                right: 16,
                                top: 8,
                              ),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'SheCan AI is typing...',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ),
                          if (_isGroupChat && _typingUsers.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 16,
                                right: 16,
                                top: 8,
                              ),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  _groupTypingLabel(_typingUsers),
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            )
                          else if (_isOtherTyping)
                            const Padding(
                              padding: EdgeInsets.only(
                                left: 16,
                                right: 16,
                                top: 8,
                              ),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Typing...',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ),
                          Expanded(
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: merged.length,
                              itemBuilder: (context, index) {
                                final msg = merged[index];
                                final isUser =
                                    msg.senderId == widget.currentUserId;
                                final pending = msg.id.startsWith('pending_');
                                final seenByOther =
                                    isUser &&
                                    _otherUserId != null &&
                                    _otherUserId!.isNotEmpty &&
                                    msg.isSeenBy(_otherUserId!);

                                return _messageBubble(
                                  isUser: isUser,
                                  text: msg.content,
                                  isPending: pending,
                                  showSeen: seenByOther,
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  ),
          ),

          //  Input Box
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.white,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.isAI &&
                    (_speechStatusNote.isNotEmpty ||
                        _speechErrorNote.isNotEmpty))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _speechErrorNote.isNotEmpty
                                ? 'Speech error: $_speechErrorNote'
                                : _speechStatusNote,
                            style: TextStyle(
                              fontSize: 12,
                              color: _speechErrorNote.isNotEmpty
                                  ? AppColors.error
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                Row(
                  children: [
                    if (widget.isAI)
                      IconButton(
                        onPressed: _isAiResponding ? null : _toggleListening,
                        icon: Icon(
                          _isListening ? Icons.mic : Icons.mic_none,
                          color: _isListening
                              ? AppColors.error
                              : AppColors.primary,
                        ),
                        tooltip: _isListening
                            ? 'Stop listening'
                            : 'Speak message',
                      ),
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          hintText: _isListening
                              ? 'Listening...'
                              : 'Type a message...',
                          border: InputBorder.none,
                        ),
                        onSubmitted: (_) {
                          if (!_isSending) {
                            sendMessage();
                          }
                        },
                      ),
                    ),

                    IconButton(
                      onPressed: _isSending ? null : sendMessage,
                      icon: _isSending
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.send, color: AppColors.primary),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _messageBubble({
    required bool isUser,
    required String text,
    bool isPending = false,
    bool showSeen = false,
    bool isMarkdown = false,
  }) {
    final textColor = isUser ? Colors.white : Colors.black;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        constraints: const BoxConstraints(maxWidth: 250),
        decoration: BoxDecoration(
          color: isUser ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: isUser
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            if (isMarkdown)
              MarkdownBody(
                data: text,
                styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context))
                    .copyWith(
                      p: TextStyle(color: textColor),
                      listBullet: TextStyle(color: textColor),
                      strong: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                softLineBreak: true,
              )
            else
              Text(
                text,
                style: TextStyle(color: textColor),
              ),
            if (isPending)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Sending...',
                  style: TextStyle(
                    fontSize: 11,
                    color: isUser
                        ? Colors.white.withValues(alpha: 0.85)
                        : Colors.black54,
                  ),
                ),
              ),
            if (showSeen)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Seen',
                  style: TextStyle(
                    fontSize: 11,
                    color: isUser
                        ? Colors.white.withValues(alpha: 0.85)
                        : Colors.black54,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
