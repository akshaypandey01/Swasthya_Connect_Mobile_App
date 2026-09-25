import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

// Reuses the same call UI as the worker teleconsult
class TeleconsultScreen extends StatefulWidget {
  const TeleconsultScreen({super.key});
  @override
  State<TeleconsultScreen> createState() => _TeleconsultScreenState();
}

class _TeleconsultScreenState extends State<TeleconsultScreen> {
  bool _inCall = false;
  bool _micMuted = false;
  bool _videoOff = false;
  final _chatCtrl = TextEditingController();
  final List<String> _messages = [];
  bool _chatOpen = false;

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
        title: const Text('Tele-consultation',
            style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text('PATIENT',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.white)),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                Container(
                  color: const Color(0xFF0D1117),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: AppColors.primary.withOpacity(0.2),
                          child: const Icon(Icons.medical_services_rounded,
                              size: 50, color: AppColors.primary),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _inCall ? 'Doctor Connected' : 'Connecting to doctor…',
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
                // Self view
                Positioned(
                  top: 16, right: 16,
                  child: Container(
                    width: 90, height: 120,
                    decoration: BoxDecoration(
                      color: const Color(0xFF252D3E),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: const Center(
                      child: Icon(Icons.person_rounded,
                          color: Colors.white38, size: 36),
                    ),
                  ),
                ),
                if (_chatOpen)
                  Positioned.fill(
                    child: Container(
                      color: const Color(0xE6000000),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Text('Chat',
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
                              itemCount: _messages.length,
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
                                  child: Text(_messages[i],
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
                                    hintStyle: const TextStyle(color: Colors.white38),
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
                                      _messages.add(_chatCtrl.text);
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
          Container(
            color: const Color(0xFF1A1F2E),
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 32),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _CtrlBtn(
                  icon: _micMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
                  label: _micMuted ? 'Unmute' : 'Mute',
                  onTap: () => setState(() => _micMuted = !_micMuted),
                ),
                _CtrlBtn(
                  icon: Icons.chat_rounded,
                  label: 'Chat',
                  onTap: () => setState(() => _chatOpen = !_chatOpen),
                ),
                GestureDetector(
                  onTap: () => setState(() => _inCall = !_inCall),
                  child: Container(
                    width: 64, height: 64,
                    decoration: BoxDecoration(
                      color: _inCall
                          ? AppColors.triageRed
                          : AppColors.syncSynced,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _inCall ? Icons.call_end_rounded : Icons.call_rounded,
                      color: Colors.white, size: 28,
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

class _CtrlBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _CtrlBtn({required this.icon, required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 52, height: 52,
            decoration: const BoxDecoration(
              color: Color(0xFF252D3E),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white70, size: 24),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.white54)),
        ],
      ),
    );
  }
}
