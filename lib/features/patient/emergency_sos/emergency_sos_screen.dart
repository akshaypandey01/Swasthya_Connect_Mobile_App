import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../shared/widgets/sc_app_bar.dart';

class EmergencySosScreen extends StatefulWidget {
  const EmergencySosScreen({super.key});
  @override
  State<EmergencySosScreen> createState() => _EmergencySosScreenState();
}

class _EmergencySosScreenState extends State<EmergencySosScreen>
    with SingleTickerProviderStateMixin {
  bool _activated = false;
  bool _isGettingLocation = false;
  String? _locationText;
  late AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  Future<void> _activateSos() async {
    HapticFeedback.heavyImpact();
    setState(() {
      _activated = true;
      _isGettingLocation = true;
    });

    // Get location
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (serviceEnabled && permission != LocationPermission.deniedForever) {
        final pos = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);
        setState(() {
          _locationText =
              'Lat: ${pos.latitude.toStringAsFixed(5)}, Lng: ${pos.longitude.toStringAsFixed(5)}';
          _isGettingLocation = false;
        });
      } else {
        setState(() {
          _locationText = 'Location unavailable';
          _isGettingLocation = false;
        });
      }
    } catch (_) {
      setState(() {
        _locationText = 'Could not get location';
        _isGettingLocation = false;
      });
    }

    // Call 112
    final uri = Uri(scheme: 'tel', path: '112');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          _activated ? const Color(0xFF1A0000) : AppColors.background,
      appBar: AppBar(
        title: const Text('Emergency SOS',
            style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.emergency,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!_activated) ...[
                const Icon(Icons.emergency_rounded,
                    size: 72, color: AppColors.emergency),
                const SizedBox(height: 20),
                const Text('Emergency SOS',
                    style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: AppColors.emergency)),
                const SizedBox(height: 8),
                const Text(
                  'Press and hold the button below to call emergency services (112), send SMS, and share your location.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 14, color: AppColors.textSecondary, height: 1.5),
                ),
                const SizedBox(height: 60),
                // SOS button
                GestureDetector(
                  onLongPressStart: (_) => _activateSos(),
                  child: AnimatedBuilder(
                    animation: _pulseCtrl,
                    builder: (_, __) => Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.emergency,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.emergency.withOpacity(
                                0.3 + _pulseCtrl.value * 0.3),
                            blurRadius: 20 + _pulseCtrl.value * 30,
                            spreadRadius: _pulseCtrl.value * 10,
                          ),
                        ],
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.sos_rounded,
                              size: 64, color: Colors.white),
                          SizedBox(height: 4),
                          Text('HOLD',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white70)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                const Text(
                  'Press and hold for 2 seconds to activate',
                  style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      fontStyle: FontStyle.italic),
                ),
              ] else ...[
                // Activated state
                const Icon(Icons.emergency_rounded,
                    size: 80, color: AppColors.emergency),
                const SizedBox(height: 20),
                const Text('SOS ACTIVATED',
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: AppColors.emergency)),
                const SizedBox(height: 16),
                const Text('Calling 112…',
                    style: TextStyle(
                        fontSize: 18, color: Colors.white70)),
                const SizedBox(height: 24),
                if (_isGettingLocation)
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white54)),
                      SizedBox(width: 10),
                      Text('Getting your location…',
                          style: TextStyle(color: Colors.white54)),
                    ],
                  )
                else
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.location_on_rounded,
                            color: AppColors.emergency, size: 18),
                        const SizedBox(width: 8),
                        Text(_locationText ?? '',
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 13)),
                      ],
                    ),
                  ),
                const SizedBox(height: 40),
                TextButton(
                  onPressed: () => setState(() => _activated = false),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white70,
                  ),
                  child: const Text('Cancel SOS'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
