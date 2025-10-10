class SignalData {
  final int? id;
  final int? pduSessionId;
  final double? avgDelay;
  final double? minDelay;
  final double? maxDelay;
  final int? ulPdcpRate;
  final int? dlPdcpRate;
  final int? rsrp;
  final double? rsrq;
  final double? sinr;

  SignalData({
    this.id,
    this.pduSessionId,
    this.avgDelay,
    this.minDelay,
    this.maxDelay,
    this.ulPdcpRate,
    this.dlPdcpRate,
    this.rsrp,
    this.rsrq,
    this.sinr,
  });

  factory SignalData.fromJson(Map<String, dynamic> json) {
    return SignalData(
      id: json['id'],
      pduSessionId: json['pduSessionId'],
      avgDelay: json['avgDelay']?.toDouble(),
      minDelay: json['minDelay']?.toDouble(),
      maxDelay: json['maxDelay']?.toDouble(),
      ulPdcpRate: json['ulPdcpRate'],
      dlPdcpRate: json['dlPdcpRate'],
      rsrp: json['rsrp'],
      rsrq: json['rsrq']?.toDouble(),
      sinr: json['sinr']?.toDouble(),
    );
  }

  // 信号质量评级
  String get signalQuality {
    if (rsrp == null) return '未知';
    if (rsrp! >= -85) return '优秀';
    if (rsrp! >= -95) return '良好';
    if (rsrp! >= -105) return '一般';
    return '较差';
  }

  // 上行速率（格式化）
  String get uploadSpeedFormatted {
    if (ulPdcpRate == null) return '0 Kbps';
    if (ulPdcpRate! < 1024) return '$ulPdcpRate Kbps';
    return '${(ulPdcpRate! / 1024).toStringAsFixed(2)} Mbps';
  }

  // 下行速率（格式化）
  String get downloadSpeedFormatted {
    if (dlPdcpRate == null) return '0 Kbps';
    if (dlPdcpRate! < 1024) return '$dlPdcpRate Kbps';
    return '${(dlPdcpRate! / 1024).toStringAsFixed(2)} Mbps';
  }
}

