import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final connectivityServiceProvider =
    StreamProvider<List<ConnectivityResult>>((ref) {
  return Connectivity().onConnectivityChanged.map((result) => [result]);
});

final isOnlineProvider = Provider<bool>((ref) {
  final results = ref.watch(connectivityServiceProvider).valueOrNull;
  if (results == null || results.isEmpty) return false;
  return results.any((r) =>
      r == ConnectivityResult.mobile ||
      r == ConnectivityResult.wifi ||
      r == ConnectivityResult.ethernet);
});
