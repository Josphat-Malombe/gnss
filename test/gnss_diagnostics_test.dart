import 'package:flutter_test/flutter_test.dart';
import 'package:gnss_diagnostics/gnss_diagnostics.dart';
import 'package:gnss_diagnostics/gnss_diagnostics_platform_interface.dart';
import 'package:gnss_diagnostics/gnss_diagnostics_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockGnssDiagnosticsPlatform
    with MockPlatformInterfaceMixin
    implements GnssDiagnosticsPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final GnssDiagnosticsPlatform initialPlatform = GnssDiagnosticsPlatform.instance;

  test('$MethodChannelGnssDiagnostics is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelGnssDiagnostics>());
  });

  test('getPlatformVersion', () async {
    GnssDiagnostics gnssDiagnosticsPlugin = GnssDiagnostics();
    MockGnssDiagnosticsPlatform fakePlatform = MockGnssDiagnosticsPlatform();
    GnssDiagnosticsPlatform.instance = fakePlatform;

    expect(await gnssDiagnosticsPlugin.getPlatformVersion(), '42');
  });
}
