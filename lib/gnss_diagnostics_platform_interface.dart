import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'src/models.dart';
import 'gnss_diagnostics_method_channel.dart';

abstract class GnssDiagnosticsPlatform extends PlatformInterface {
  GnssDiagnosticsPlatform() : super(token: _token);

  static final Object _token = Object();

  static GnssDiagnosticsPlatform _instance = MethodChannelGnssDiagnostics();

  /// The default instance of [GnssDiagnosticsPlatform] to use.
  static GnssDiagnosticsPlatform get instance => _instance;

  static set instance(GnssDiagnosticsPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Stream of GNSS status snapshots
  Stream<GnssStatusSnapshot> get statusStream;
}
