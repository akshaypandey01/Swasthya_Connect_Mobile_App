  import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/router/app_router.dart';
import 'core/services/connectivity_service.dart';
import 'core/services/sync_service.dart';
import 'core/services/notification_service.dart';
import 'core/theme/app_theme.dart';
import 'core/l10n/app_localizations.dart';
import 'core/constants/hive_constants.dart';
import 'data/local/hive_adapters.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Portrait-only — optimised for one-handed use on low-end devices
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Status bar style
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  // Hive offline storage
  await Hive.initFlutter();
  registerHiveAdapters();
  
  // Close all boxes if already open (hot reload safety)
  if (Hive.isBoxOpen(HiveConstants.settingsBox)) {
    await Hive.box(HiveConstants.settingsBox).close();
  }
  if (Hive.isBoxOpen(HiveConstants.pendingSyncBox)) {
    await Hive.box(HiveConstants.pendingSyncBox).close();
  }
  if (Hive.isBoxOpen(HiveConstants.encounterBox)) {
    await Hive.box(HiveConstants.encounterBox).close();
  }
  if (Hive.isBoxOpen(HiveConstants.patientBox)) {
    await Hive.box(HiveConstants.patientBox).close();
  }
  if (Hive.isBoxOpen(HiveConstants.trackerBox)) {
    await Hive.box(HiveConstants.trackerBox).close();
  }
  
  await HiveConstants.openBoxes();

  // Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Local notifications - temporarily disabled
  // await NotificationService().init();

  runApp(const ProviderScope(child: SwasthyaConnectApp()));
}

class SwasthyaConnectApp extends ConsumerWidget {
  const SwasthyaConnectApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final locale = ref.watch(localeProvider);

    // Start connectivity monitor + background sync listener
    ref.watch(connectivityServiceProvider);
    ref.watch(syncServiceProvider);

    return MaterialApp.router(
      title: 'SwasthyaConnect',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: router,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      builder: (context, child) {
        // Cap text scale to prevent layout overflow on accessibility settings
        final mediaQuery = MediaQuery.of(context);
        final clampedTextScaler = mediaQuery.textScaler.clamp(
          minScaleFactor: 0.85,
          maxScaleFactor: 1.3,
        );
        return MediaQuery(
          data: mediaQuery.copyWith(textScaler: clampedTextScaler),
          child: child!,
        );
      },
    );
  }
}
