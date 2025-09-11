import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  ConnectivityService._();

  static final ConnectivityService instance = ConnectivityService._();

  final Connectivity _connectivity = Connectivity();

  /// Emits `true` if there is any network available, otherwise `false`.
  /// Includes an initial value followed by updates, with distinct filtering.
  Stream<bool> get status$ async* {
    final initial = await _connectivity.checkConnectivity();
    yield initial != ConnectivityResult.none;
    yield* _connectivity.onConnectivityChanged
        .map((event) => event != ConnectivityResult.none)
        .distinct();
  }
}

