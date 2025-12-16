# gnss_diagnostics

A Flutter plugin that provides real-time GNSS (Global Navigation Satellite System) diagnostic
information on Android devices using the native `GnssStatus` API.

The plugin exposes a broadcast stream that reports:
- Total satellites in view
- Total satellites used in fix
- Per-constellation satellite statistics (GPS, Galileo, GLONASS, BeiDou, etc.)

This is useful for GNSS monitoring, diagnostics, and research applications.

---

## Features

- Real-time GNSS satellite status updates
- Per-constellation breakdown (in-view vs used-in-fix)
- Lightweight, event-based API using `EventChannel`
- No polling or background services
- Designed for diagnostics and visualization

---

## Platform Support

| Platform | Support |
|--------|---------|
| Android | ✅ Yes |
| iOS | ❌ No |
| Web | ❌ No |

> This plugin currently supports **Android only**.

---

## Installation

Add the dependency to your `pubspec.yaml`:

```yaml
dependencies:
  gnss_diagnostics: ^0.1.0


Then run:
```
flutter pub get

## Android Setup
- Minimum SDK
Ensure your Android project uses minSdkVersion 24 or higher.


defaultConfig {
    minSdkVersion 24
}


- Permissions
Add the following permission to your app’s AndroidManifest.xml:


<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />

At runtime, you must request location permission before accessing the GNSS stream.

## Usage
The plugin exposes a broadcast stream of GnssStatusSnapshot.


import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:gnss_diagnostics/gnss_diagnostics.dart';

class GnssPage extends StatefulWidget {
  const GnssPage({super.key});

  @override
  State<GnssPage> createState() => _GnssPageState();
}

class _GnssPageState extends State<GnssPage> {
  Stream<GnssStatusSnapshot>? _stream;

  @override
  void initState() {
    super.initState();
    _requestPermission();
  }

  Future<void> _requestPermission() async {
    final status = await Permission.location.request();
    if (status.isGranted) {
      setState(() {
        _stream = GnssDiagnostics.statusStream;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('GNSS Diagnostics')),
      body: _stream == null
          ? const Center(child: Text('Waiting for permission...'))
          : StreamBuilder<GnssStatusSnapshot>(
              stream: _stream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }# gnss_diagnostics


                final status = snapshot.data!;
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Total in view: ${status.totalInView}\n'
                    'Used in fix: ${status.totalUsedInFix}',
                  ),
                );
              },
            ),
    );
  }
}


## Notes
GNSS status callbacks are passive.

Satellite data may remain zero until:

Another app actively requests location updates, or

The device acquires a GNSS fix.

Accuracy and availability depend on device hardware and environment.

Background execution is not supported.


## Example App
A complete working example is provided in the /example directory.

The example demonstrates:

Runtime permission handling

Stream consumption

UI rendering of GNSS constellation data


## Use Cases
GNSS diagnostics and debugging

Satellite visibility monitoring

Navigation system analysis

Educational and research tools

Field testing GNSS performance on devices