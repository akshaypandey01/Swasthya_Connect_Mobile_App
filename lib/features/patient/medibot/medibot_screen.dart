import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/medibot_service.dart';
import '../../../core/services/connectivity_service.dart';

// ═══════════════════════════════════════════════════════════════════════════
// MEDIBOT SCREEN
// ═══════════════════════════════════════════════════════════════════════════

class MedibotScreen extends ConsumerStatefulWidget {
  const MedibotScreen({super.key});

  @override
  ConsumerState<MedibotScreen> createState() => _MedibotScreenState();
}

class _MedibotScreenState extends ConsumerState<MedibotScreen> {
  final List<MedibotMessage> _messages = [];
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  bool _isSending = false;
  bool _isRecording = false;

  @override
  void initState() {
    super.initState();
    // Add welcome message
    _messages.add(
      MedibotMessage(
        id: const Uuid().v4(),
        content: '''Hello! I'm MediBot, your AI health assistant.

I can help you understand your health records, explain reports, find appointments, discover health schemes, and answer general health questions.

How can I assist you today?''',
        sender: MessageSender.medibot,
        timestamp: DateTime.now(),
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMessage = MedibotMessage(
      id: const Uuid().v4(),
      content: text.trim(),
      sender: MessageSender.user,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(userMessage);
      _textController.clear();
      _isSending = true;
    });

    _scrollToBottom();

    try {
      final medibotService = ref.read(medibotServiceProvider);
      final response = await medibotService.sendMessage(
        userMessage: text.trim(),
        context: {}, // Add patient context if available
      );

      setState(() {
        _messages.add(response);
        _isSending = false;
      });

      _scrollToBottom();
    } on MedibotException catch (e) {
      final errorMessage = MedibotMessage(
        id: const Uuid().v4(),
        content: e.message,
        sender: MessageSender.medibot,
        timestamp: DateTime.now(),
        isError: true,
      );

      setState(() {
        _messages.add(errorMessage);
        _isSending = false;
      });

      _scrollToBottom();
    } catch (e) {
      final errorMessage = MedibotMessage(
        id: const Uuid().v4(),
        content: 'Sorry, something went wrong. Please try again.',
        sender: MessageSender.medibot,
        timestamp: DateTime.now(),
        isError: true,
      );

      setState(() {
        _messages.add(errorMessage);
        _isSending = false;
      });

      _scrollToBottom();
    }
  }

  void _handleVoiceInput() async {
    final isOnline = ref.read(isOnlineProvider);
    if (!isOnline) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Voice input requires internet connection'),
          backgroundColor: AppColors.triageRed,
        ),
      );
      return;
    }

    setState(() => _isRecording = !_isRecording);

    if (!_isRecording) {
      // Stopped recording - process voice
      try {
        final medibotService = ref.read(medibotServiceProvider);
        // TODO: Implement actual voice recording and get file path
        final transcribedText = await medibotService.transcribeVoice(
          audioFilePath: 'path/to/audio', // Replace with actual recording
        );
        
        _textController.text = transcribedText;
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Voice input failed: ${e.toString()}'),
            backgroundColor: AppColors.triageRed,
          ),
        );
      } finally {
        setState(() => _isRecording = false);
      }
    }
  }

  void _handleSuggestedAction(String action) {
    _textController.text = action;
    _sendMessage(action);
  }

  @override
  Widget build(BuildContext context) {
    final isOnline = ref.watch(isOnlineProvider);
    final suggestions = ref.read(medibotServiceProvider).getSuggestedActions();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.smart_toy_outlined, size: 18),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('MediBot', style: TextStyle(fontSize: 18)),
                  Text(
                    'AI Health Assistant',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w400),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.primary,
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isOnline
                  ? AppColors.triageGreen.withOpacity(0.2)
                  : AppColors.triageYellow.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isOnline ? AppColors.triageGreen : AppColors.triageYellow,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isOnline ? Icons.wifi_rounded : Icons.wifi_off_rounded,
                  size: 14,
                  color: isOnline ? AppColors.triageGreen : AppColors.triageYellow,
                ),
                const SizedBox(width: 4),
                Text(
                  isOnline ? 'Online' : 'Offline',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isOnline ? AppColors.triageGreen : AppColors.triageYellow,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // AI Disclaimer
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              border: Border(
                bottom: BorderSide(color: AppColors.divider, width: 1),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, size: 16, color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'AI-generated information. For diagnosis or treatment, consult a healthcare professional.',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Chat messages
          Expanded(
            child: _messages.isEmpty
                ? const Center(child: Text('No messages yet'))
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    itemCount: _messages.length + (_isSending ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _messages.length) {
                        return _buildTypingIndicator();
                      }
                      return _buildMessageBubble(_messages[index]);
                    },
                  ),
          ),

          // Suggested actions (show when no active conversation)
          if (_messages.length <= 1)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Suggestions',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: suggestions.map((suggestion) {
                      return _buildSuggestionChip(suggestion);
                    }).toList(),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),

          // Input area
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border(
                top: BorderSide(color: AppColors.divider, width: 1),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: SafeArea(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Voice input button
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: _isRecording
                          ? AppColors.triageRed.withOpacity(0.1)
                          : AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: _isRecording ? AppColors.triageRed : AppColors.primary,
                        width: 1.5,
                      ),
                    ),
                    child: IconButton(
                      icon: Icon(
                        _isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                        color: _isRecording ? AppColors.triageRed : AppColors.primary,
                      ),
                      onPressed: _handleVoiceInput,
                      iconSize: 22,
                      padding: EdgeInsets.zero,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Text input
                  Expanded(
                    child: Container(
                      constraints: const BoxConstraints(maxHeight: 100),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppColors.border, width: 1),
                      ),
                      child: TextField(
                        controller: _textController,
                        focusNode: _focusNode,
                        maxLines: null,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (text) => _sendMessage(text),
                        decoration: const InputDecoration(
                          hintText: 'Ask about your health...',
                          hintStyle: TextStyle(
                            color: AppColors.textHint,
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Send button
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send_rounded, color: Colors.white),
                      onPressed: _isSending
                          ? null
                          : () => _sendMessage(_textController.text),
                      iconSize: 20,
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(MedibotMessage message) {
    final isUser = message.sender == MessageSender.user;
    final isError = message.isError;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isError
                    ? AppColors.triageRed.withOpacity(0.1)
                    : AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                isError ? Icons.error_outline : Icons.smart_toy_outlined,
                size: 18,
                color: isError ? AppColors.triageRed : AppColors.primary,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: isUser
                    ? AppColors.primary
                    : isError
                        ? AppColors.triageRed.withOpacity(0.1)
                        : AppColors.surface,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isUser ? 16 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 16),
                ),
                border: Border.all(
                  color: isUser
                      ? AppColors.primary
                      : isError
                          ? AppColors.triageRed
                          : AppColors.divider,
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.content,
                    style: TextStyle(
                      fontSize: 14,
                      color: isUser
                          ? Colors.white
                          : isError
                              ? AppColors.triageRed
                              : AppColors.textPrimary,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTimestamp(message.timestamp),
                    style: TextStyle(
                      fontSize: 10,
                      color: isUser
                          ? Colors.white.withOpacity(0.7)
                          : AppColors.textHint,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.person_rounded,
                size: 18,
                color: AppColors.primary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.smart_toy_outlined,
              size: 18,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.divider, width: 1),
            ),
            child: Row(
              children: [
                _buildDot(0),
                const SizedBox(width: 4),
                _buildDot(1),
                const SizedBox(width: 4),
                _buildDot(2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      builder: (context, value, child) {
        final delay = index * 0.2;
        final animValue = ((value + delay) % 1.0);
        final opacity = (animValue < 0.5 ? animValue : 1.0 - animValue) * 2;

        return Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.3 + (opacity * 0.7)),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }

  Widget _buildSuggestionChip(String text) {
    return GestureDetector(
      onTap: () => _handleSuggestedAction(text),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.touch_app_rounded,
                size: 14, color: AppColors.primary),
            const SizedBox(width: 6),
            Text(
              text,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${timestamp.day}/${timestamp.month} ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
  }
}
