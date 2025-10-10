class CallInfo {
  final String time;
  final String number;
  final String state; // ringing, answered, ended

  CallInfo({
    required this.time,
    required this.number,
    required this.state,
  });

  factory CallInfo.fromJson(Map<String, dynamic> json) {
    return CallInfo(
      time: json['time'] ?? '',
      number: json['number'] ?? '',
      state: json['state'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'time': time,
      'number': number,
      'state': state,
    };
  }

  String get stateText {
    switch (state) {
      case 'ringing':
        return '来电振铃';
      case 'answered':
        return '通话中';
      case 'ended':
        return '已结束';
      default:
        return '未知';
    }
  }
}

