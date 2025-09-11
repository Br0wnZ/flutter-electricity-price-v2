import 'dart:io';
import 'package:flutter/services.dart';

class ExactAlarmPermission {
  static const MethodChannel _channel = MethodChannel('exact_alarm');

  static Future<bool> canScheduleExactAlarms() async {
    if (!Platform.isAndroid) return true;
    try {
      final result = await _channel.invokeMethod<bool>('canScheduleExactAlarms');
      return result ?? true;
    } catch (_) {
      return true;
    }
  }

  static Future<void> requestPermission() async {
    if (!Platform.isAndroid) return;
    try {
      await _channel.invokeMethod('requestExactAlarmPermission');
    } catch (_) {
      // no-op
    }
  }
}

