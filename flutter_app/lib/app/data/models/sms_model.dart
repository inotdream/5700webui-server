class SmsModel {
  final String sender;
  final String content;
  final String time;

  /// 模块存储中的短信索引（AT+CMGD删除时使用），实时推送的短信可能为空
  final int? index;
  final bool? isComplete;

  SmsModel({
    required this.sender,
    required this.content,
    required this.time,
    this.index,
    this.isComplete,
  });

  factory SmsModel.fromJson(Map<String, dynamic> json) {
    return SmsModel(
      sender: json['sender'] ?? '',
      content: json['content'] ?? '',
      time: json['time'] ?? '',
      index: json['index'],
      isComplete: json['isComplete'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sender': sender,
      'content': content,
      'time': time,
      'index': index,
      'isComplete': isComplete,
    };
  }
}
