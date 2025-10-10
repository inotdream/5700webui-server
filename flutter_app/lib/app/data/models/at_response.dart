class ATResponse {
  final bool success;
  final String? data;
  final String? error;

  ATResponse({
    required this.success,
    this.data,
    this.error,
  });

  factory ATResponse.fromJson(Map<String, dynamic> json) {
    return ATResponse(
      success: json['success'] ?? false,
      data: json['data'],
      error: json['error'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data,
      'error': error,
    };
  }
}

