import 'package:flutter/foundation.dart';

/// 热路径日志只在 debug 输出，避免 release 里每包 AT 数据都 print。
void appLog(String message) {
  if (kDebugMode) {
    print(message);
  }
}
