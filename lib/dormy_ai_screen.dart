import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'dart:math' as math;
import 'debug_agent_log.dart';
import 'theme.dart';
import 'splash_screen.dart';
import 'services/chat_service.dart';

enum _ChatRole { user, bot }

class _ChatMessage {
  _ChatMessage({required this.role, required this.text, required this.time});

  final _ChatRole role;
  final String text;
  final String time;
}

class DormyAiScreen extends StatefulWidget {
  const DormyAiScreen({super.key});

  @override
  State<DormyAiScreen> createState() => _DormyAiScreenState();
}

class _DormyAiScreenState extends State<DormyAiScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textController = TextEditingController();
  final ChatService _chatService = ChatService();
  final List<_ChatMessage> _messages = [];
  bool _isLoading = false;

  void _scheduleScrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  @override
  void initState() {
    super.initState();
    // #region agent log
    agentDebugLog(
      hypothesisId: 'H5,H6',
      location: 'dormy_ai_screen.dart:initState',
      message: 'DormyAiScreen initState',
      data: {
        'chatServiceHash': identityHashCode(_chatService),
      },
    );
    // #endregion
    _messages.add(
      _ChatMessage(
        role: _ChatRole.bot,
        text:
            "أهلاً، أنا مدير السكن في Dorm Mate. كيف يمكنني مساعدتك؟",
        time: "الآن",
      ),
    );
    _scheduleScrollToBottom();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _resetChat() {
    _chatService.resetChat();
    setState(() {
      _messages
        ..clear()
        ..add(
          _ChatMessage(
            role: _ChatRole.bot,
            text:
                "تمام، بدأنا من جديد. أهلاً، أنا مدير السكن في Dorm Mate. كيف يمكنني مساعدتك؟",
            time: "الآن",
          ),
        );
      _isLoading = false;
      _textController.clear();
    });
    _scheduleScrollToBottom();
  }

  Future<void> _handleSend() async {
    if (_isLoading) return;
    final raw = _textController.text;
    final text = raw.trim();
    if (text.isEmpty) return;
    final now = TimeOfDay.now().format(context);

    setState(() {
      _messages.add(_ChatMessage(role: _ChatRole.user, text: text, time: now));
      _isLoading = true;
      _textController.clear();
    });
    _scheduleScrollToBottom();

    try {
      final reply = await _chatService.sendMessage(text);
      if (!mounted) return;
      setState(() {
        _messages.add(
          _ChatMessage(role: _ChatRole.bot, text: reply, time: now),
        );
        _isLoading = false;
      });
      _scheduleScrollToBottom();
    } catch (e) {
      if (!mounted) return;
      // ignore: avoid_print
      print('CHAT UI ERROR: ${e.toString()}');
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'فيه مشكلة تقنية دلوقتي… جرّب تاني كمان شوية لو سمحت.',
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppTheme.onSurface,
          action: SnackBarAction(
            label: 'إعادة المحاولة',
            textColor: AppTheme.primaryContainer,
            onPressed: _handleSend,
          ),
        ),
      );
      _scheduleScrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppTheme.schemeSurface(context),
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight + 8),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: AppBar(
              backgroundColor: AppTheme.frostedBarBg(context),
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: AppTheme.primary),
                onPressed: () => Navigator.pop(context),
              ),
              titleSpacing: 0,
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(1),
                child: Container(
                    color: AppTheme.schemeContainerHighest(context), height: 1),
              ),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Dormy AI Assistant',
                      style: textTheme.headlineMedium
                          ?.copyWith(color: AppTheme.primary, fontSize: 18)),
                  Text('ONLINE NOW',
                      style: textTheme.labelSmall?.copyWith(
                          color: AppTheme.outline,
                          letterSpacing: 1.5,
                          fontSize: 10)),
                ],
              ),
              actions: [
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border:
                        Border.all(color: AppTheme.primaryContainer, width: 2),
                    image: const DecorationImage(
                      image: NetworkImage(
                          'https://lh3.googleusercontent.com/aida-public/AB6AXuAjnmcMaF7Fo6tE7vbwKADi871dM-X8gks5ZOyu7fB_CWrNg4CT_ytth2EjQCDL6e0WRtTfo9_2MnandTC_I7iZhrG7TRupTRm1YC2mbuqUK4WsfHbY9E4znfIIIooE3MaYw92j-EpQ2H0eVmovN9scZFqZwHjcEpiBtS8rCfX7MadCGLbppZ_FdJdkrMfAToG5XclPq6fvHb9mqG6dfTw7CDAfROWsQMlqqT2AryVfpxtejGKIOpICSWUQQkEjUE89FTYDFpJYBNI'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Reset chat',
                  icon: const Icon(Icons.refresh, color: AppTheme.outline),
                  onPressed: _isLoading ? null : _resetChat,
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert, color: AppTheme.outline),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Background Grid
          Positioned.fill(
            child: CustomPaint(
              painter: BlueprintPainter(brightness: Theme.of(context).brightness),
            ),
          ),

          // Decorative Blueprint Elements
          Positioned(
            top: 80,
            left: 40,
            child: Transform.rotate(
              angle: -12 * math.pi / 180,
              child: Container(
                width: 256,
                height: 256,
                decoration: BoxDecoration(
                  border: Border.all(
                      color: AppTheme.primaryContainerOpacity20, width: 2),
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.center,
                child: Text('FLOOR_PLAN_REF_01',
                    style: textTheme.labelSmall?.copyWith(
                        color: AppTheme.primaryContainer,
                        fontFamily: 'monospace')),
              ),
            ),
          ),
          Positioned(
            bottom: 160,
            right: -20,
            child: Transform.rotate(
              angle: 15 * math.pi / 180,
              child: Container(
                width: 320,
                height: 160,
                decoration: const BoxDecoration(
                  border: Border(
                    left: BorderSide(
                        color: AppTheme.primaryContainerOpacity20, width: 1),
                    bottom: BorderSide(
                        color: AppTheme.primaryContainerOpacity20, width: 1),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 16, top: 8),
                  child: Text('KITCHEN_ZONE_A',
                      style: textTheme.labelSmall?.copyWith(
                          color: AppTheme.primaryContainer,
                          fontFamily: 'monospace')),
                ),
              ),
            ),
          ),

          // Chat Area
          Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.only(
                    top: kToolbarHeight + 48,
                    bottom: 24,
                    left: 20,
                    right: 20,
                  ),
                  itemCount: _messages.length + (_isLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (_isLoading && index == _messages.length) {
                      return _buildTypingIndicator();
                    }

                    final m = _messages[index];
                    if (m.role == _ChatRole.user) {
                      return _buildUserMessage(textTheme, m.text, m.time);
                    }
                    return _buildBotMessage(textTheme, m.text, m.time);
                  },
                ),
              ),
              _buildBottomInput(context),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBotMessage(TextTheme textTheme, String text, String time) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: AppTheme.surfaceContainerLowest,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(4),
                      topRight: Radius.circular(24),
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                    boxShadow: [
                      BoxShadow(
                          color: AppTheme.primaryContainerOpacity8,
                          blurRadius: 20,
                          offset: Offset(0, 4)),
                    ],
                  ),
                  child: Text(text, style: textTheme.bodyLarge),
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.only(left: 4.0),
                  child: Text(time,
                      style: textTheme.labelSmall
                          ?.copyWith(color: AppTheme.outlineVariant)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 48), // Force max width constraint
        ],
      ),
    );
  }

  Widget _buildUserMessage(TextTheme textTheme, String text, String time) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const SizedBox(width: 48),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: AppTheme.primaryContainer,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(4),
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                    boxShadow: [
                      BoxShadow(
                          color: AppTheme.primaryContainerOpacity20,
                          blurRadius: 12,
                          offset: Offset(0, 4)),
                    ],
                  ),
                  child: Text(text,
                      style: textTheme.bodyLarge
                          ?.copyWith(color: AppTheme.onPrimaryContainer)),
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.only(right: 4.0),
                  child: Text(time,
                      style: textTheme.labelSmall
                          ?.copyWith(color: AppTheme.outlineVariant)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppTheme.surfaceContainerHighest),
              boxShadow: const [
                BoxShadow(
                    color: Color(0x05000000),
                    blurRadius: 4,
                    offset: Offset(0, 2)),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                        color: AppTheme.primaryContainerOpacity40,
                        shape: BoxShape.circle)),
                const SizedBox(width: 4),
                Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                        color: AppTheme.primaryContainerOpacity60,
                        shape: BoxShape.circle)),
                const SizedBox(width: 4),
                Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                        color: AppTheme.primary, shape: BoxShape.circle)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomInput(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return ClipRRect(
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12).copyWith(
            bottom: MediaQuery.of(context).padding.bottom + 12,
          ),
          decoration: BoxDecoration(
            color: AppTheme.frostedBottomBarBg(context),
            border: Border(top: BorderSide(color: AppTheme.schemeContainerHighest(context))),
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.add_circle_outline,
                    color: AppTheme.outline),
                onPressed: () {},
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: TextField(
                    controller: _textController,
                    enabled: !_isLoading,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _handleSend(),
                    decoration: InputDecoration(
                      hintText: 'Message Dormy...',
                      hintStyle: textTheme.bodyMedium
                          ?.copyWith(color: AppTheme.outlineVariant),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 14),
                      suffixIcon:
                          const Icon(Icons.mic, color: AppTheme.outline),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primaryContainer,
                  boxShadow: [
                    BoxShadow(
                        color: AppTheme.primaryContainerOpacity40,
                        blurRadius: 12,
                        offset: Offset(0, 4)),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(Icons.send,
                      color: AppTheme.onPrimaryContainer),
                  onPressed: _isLoading ? null : _handleSend,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
