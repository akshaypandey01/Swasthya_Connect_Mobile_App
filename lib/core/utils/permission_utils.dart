import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionUtils {
  PermissionUtils._();

  static Future<bool> requestCamera(BuildContext context) async {
    final status = await Permission.camera.request();
    if (status.isPermanentlyDenied && context.mounted) {
      _showSettingsDialog(context, 'Camera',
          'Camera access is required to capture documents and photos.');
    }
    return status.isGranted;
  }

  static Future<bool> requestMicrophone(BuildContext context) async {
    final status = await Permission.microphone.request();
    if (status.isPermanentlyDenied && context.mounted) {
      _showSettingsDialog(context, 'Microphone',
          'Microphone access is required to record voice notes.');
    }
    return status.isGranted;
  }

  static Future<bool> requestLocation(BuildContext context) async {
    final status = await Permission.locationWhenInUse.request();
    if (status.isPermanentlyDenied && context.mounted) {
      _showSettingsDialog(context, 'Location',
          'Location access is required to share your position in emergencies.');
    }
    return status.isGranted;
  }

  static void _showSettingsDialog(
      BuildContext context, String permissionName, String reason) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('$permissionName Permission Required'),
        content: Text(reason),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }
}
