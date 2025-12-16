import 'dart:async';
import 'package:flutter/services.dart';

import 'gnss_diagnostics_platform_interface.dart';
import 'src/models.dart';

class MethodChannelGnssDiagnostics extends GnssDiagnosticsPlatform {
  static const EventChannel _eventChannel =
      EventChannel('gnss_diagnostics/status');

  Stream<GnssStatusSnapshot>? _statusStream;

  @override
  Stream<GnssStatusSnapshot> get statusStream {
    _statusStream ??= _eventChannel
        .receiveBroadcastStream()
        .map((event) {
          final map = (event as Map).cast<String, dynamic>();
          return GnssStatusSnapshot.fromMap(map);
        });

    return _statusStream!;
  }
}

  
