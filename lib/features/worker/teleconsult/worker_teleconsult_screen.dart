import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';

class WorkerTeleconsultScreen extends StatefulWidget {
  final String priority; // routine | priority | urgent
  const WorkerTeleconsultScreen({super.key, required this.priority});
  @override
  State<WorkerTeleconsultScreen> createState() => _WorkerTeleconsultScreenState();
}

class _WorkerTeleconsultScreenState extends State<WorkerTeleconsultScreen> {
  bool _inCall = false;
  bool _micMuted = false;
  bool _videoOff = false;
  bool _chatOpen = false;
  final _chatCtrl = TextEditingController();
  final List<String> _chatMessages = [];

  Color get _priorityColor {
    switch (widget.priority) {
      case 'urgent': return AppColors.triageRed;
      case 'priority': return AppColors.triageYellow;
      default: return AppColors.primary;
    }
  }

  String get _priorityLabel {
    switch (widget.priority) {
      case 'urgent': return 'URGENT';
      case 'priority': return 'PRIORITY';
      default: return 'ROUTINE';
    }
  }

  @override
  void dispose() {
    _chatCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1F2E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1F2E),
        title: Row(
          children: [
            const Text('Tele-consultation',
                style: TextStyle(color: Colors.white, fontSize: 17)),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: _priorityColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(_priorityLabel,
                  style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          // ── Video area ────────────────────────────────────────────────────
          Expanded(
            child: Stack(
              children: [
                // Remote video placeholder
                Container(
                  color: const Color(0xFF0D1117),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: _priorityColor.withOpacity(0.2),
                          child: Icon(Icons.person_rounded,
                              size: 50, color: _priorityColor),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _inCall ? 'Doctor Connected' : 'Waiting for Doctor…',
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 16),
                        ),
                        if (!_inCall) ...[
                          const SizedBox(height: 8),
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white38,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                // Self-view
                Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    width: 90,
                    height: 120,
                    decoration: BoxDecoration(
                      color: const Color(0xFF252D3E),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: _videoOff
                        ? const Center(
                            child: Icon(Icons.videocam_off_rounded,
                                color: Colors.white38, size: 28))
                        : const Center(
                            child: Icon(Icons.videocam_rounded,
                                color: Colors.white54, size: 28)),
                  ),
                ),
                // Chat panel
                if (_chatOpen)
                  Positioned.fill(
                    child: Container(
                      color: const Color(0xE6000000),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Text('Chat / चैट',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600)),
                              const Spacer(),
                              IconButton(
                                icon: const Icon(Icons.close_rounded,
                                    color: Colors.white),
                                onPressed: () =>
                                    setState(() => _chatOpen = false),
                              ),
                            ],
                          ),
                          Expanded(
                            child: ListView.builder(
                              itemCount: _chatMessages.length,
                              itemBuilder: (_, i) => Align(
                                alignment: Alignment.centerRight,
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(_chatMessages[i],
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 14)),
                                ),
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _chatCtrl,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: InputDecoration(
                                    hintText: 'Type message…',
                                    hintStyle: const TextStyle(
                                        color: Colors.white38),
                                    filled: true,
                                    fillColor: const Color(0xFF252D3E),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.send_rounded,
                                    color: AppColors.primary),
                                onPressed: () {
                                  if (_chatCtrl.text.isNotEmpty) {
                                    setState(() {
                                      _chatMessages.add(_chatCtrl.text);
                                      _chatCtrl.clear();
                                    });
                                  }
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // ── Controls ──────────────────────────────────────────────────────
          Container(
            color: const Color(0xFF1A1F2E),
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ControlBtn(
                  icon: _micMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
                  label: _micMuted ? 'Unmute' : 'Mute',
                  active: !_micMuted,
                  onTap: () => setState(() => _micMuted = !_micMuted),
                ),
                _ControlBtn(
                  icon: _videoOff
                      ? Icons.videocam_off_rounded
                      : Icons.videocam_rounded,
                  label: _videoOff ? 'Start Video' : 'Stop Video',
                  active: !_videoOff,
                  onTap: () => setState(() => _videoOff = !_videoOff),
                ),
                _ControlBtn(
                  icon: Icons.chat_rounded,
                  label: 'Chat',
                  active: _chatOpen,
                  onTap: () => setState(() => _chatOpen = !_chatOpen),
                ),
                // End / Start call
                GestureDetector(
                  onTap: () => setState(() => _inCall = !_inCall),
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color:
                          _inCall ? AppColors.triageRed : AppColors.syncSynced,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _inCall
                          ? Icons.call_end_rounded
                          : Icons.call_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ControlBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _ControlBtn({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: active
                  ? const Color(0xFF252D3E)
                  : Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon,
                color: active ? Colors.white : Colors.white38, size: 24),
          ),
          const SizedBox(height: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 11,
                  color: active ? Colors.white70 : Colors.white38)),
        ],
      ),
    );
  }
}
