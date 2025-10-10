class SmsModel {
  final String sender;
  final String content;
  final String time;
  final bool? isComplete;

  SmsModel({
    required this.sender,
    required this.content,
    required this.time,
    this.isComplete,
  });

  factory SmsModel.fromJson(Map<String, dynamic> json) {
    return SmsModel(
      sender: json['sender'] ?? '',
      content: json['content'] ?? '',
      time: json['time'] ?? '',
      isComplete: json['isComplete'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sender': sender,
      'content': content,
      'time': time,
      'isComplete': isComplete,
    };
  }
}

