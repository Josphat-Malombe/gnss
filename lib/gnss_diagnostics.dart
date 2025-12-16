import 'gnss_diagnostics_platform_interface.dart';
import 'src/models.dart';

class GnssDiagnostics {
  /// Returns a broadcast stream of GNSS status snapshots
  static Stream<GnssStatusSnapshot> get statusStream =>
      GnssDiagnosticsPlatform.instance.statusStream;

      
}
