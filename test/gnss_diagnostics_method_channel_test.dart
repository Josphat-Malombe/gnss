import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gnss_diagnostics/gnss_diagnostics_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelGnssDiagnostics platform = MethodChannelGnssDiagnostics();
  const MethodChannel channel = MethodChannel('gnss_diagnostics');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        return '42';
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
