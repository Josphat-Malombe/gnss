import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:gnss_diagnostics/gnss_diagnostics.dart';
import 'package:gnss_diagnostics/src/models.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Stream<GnssStatusSnapshot>? _stream;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _requestPermission();
  }

  Future<void> _requestPermission() async {
    var status = await Permission.location.status;
    if (status.isDenied) {
      status = await Permission.location.request();
    }

    if (!mounted) return;

    if (status.isGranted) {
      setState(() {
        _stream = GnssDiagnostics.statusStream;
        _errorMessage = null;
      });
    } else if (status.isPermanentlyDenied) {
      setState(() {
        _errorMessage =
            'Location permission is permanently denied. Please go to the app settings to enable it.';
      });
    } else {
      setState(() {
        _errorMessage = 'Location permission denied';
      });
    }
  }

  Widget _buildConstellationTable(GnssStatusSnapshot snapshot) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Total In View: ${snapshot.totalInView}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        Text(
          'Total Used In Fix: ${snapshot.totalUsedInFix}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...snapshot.constellations.entries.map((entry) {
          final info = entry.value;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Text(
              '${entry.key}: In View=${info.inView}, Used=${info.usedInFix}',
            ),
          );
        }),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('GNSS Diagnostics')),
      body: _errorMessage != null
          ? Center(
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            )
          : _stream == null
              ? const Center(child: Text('Waiting for permission...'))
              : StreamBuilder<GnssStatusSnapshot>(
                  stream: _stream,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Error: ${snapshot.error}',
                          style: const TextStyle(color: Colors.red),
                        ),
                      );
                      
                    }

                    if (!snapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: _buildConstellationTable(snapshot.data!),
                    );
                  },
                ),
    );
  }
}
