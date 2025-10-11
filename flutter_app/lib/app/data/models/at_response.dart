class ATResponse {
  final bool success;
  final String? data;
  final String? error;
  final String? command;

  ATResponse({
    required this.success,
    this.data,
    this.error,
    this.command,
  });

  factory ATResponse.fromJson(Map<String, dynamic> json) {
    return ATResponse(
      success: json['success'] ?? false,
      data: json['data'],
      error: json['error'],
      command: json['command'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data,
      'error': error,
      'command': command,
    };
  }
}

