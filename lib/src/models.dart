class GnssConstellationInfo {
  final int inView;
  final int usedInFix;

  const GnssConstellationInfo({
    required this.inView,
    required this.usedInFix,
  });

  factory GnssConstellationInfo.fromMap(Map<String, dynamic> map) {
    return GnssConstellationInfo(
      inView: map['inView'] as int? ?? 0,
      usedInFix: map['usedInFix'] as int? ?? 0,
    );
  }
}

class GnssStatusSnapshot {
  final int totalInView;
  final int totalUsedInFix;
  final Map<String, GnssConstellationInfo> constellations;

  const GnssStatusSnapshot({
    required this.totalInView,
    required this.totalUsedInFix,
    required this.constellations,
  });

  factory GnssStatusSnapshot.fromMap(Map<String, dynamic> map) {
    final rawConstellations = map['constellations'] as Map? ?? const {};

    final parsedConstellations = <String, GnssConstellationInfo>{};

    rawConstellations.forEach((key, value) {
      parsedConstellations[key as String] = GnssConstellationInfo.fromMap(
        (value as Map).cast<String, dynamic>(),
      );
    });

    return GnssStatusSnapshot(
      totalInView: map['totalInView'] as int? ?? 0,
      totalUsedInFix: map['totalUsedInFix'] as int? ?? 0,
      constellations: parsedConstellations,
    );
  }
}
