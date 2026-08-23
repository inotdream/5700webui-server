import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService extends GetxService {
  late SharedPreferences _prefs;

  Future<StorageService> init() async {
    _prefs = await SharedPreferences.getInstance();
    return this;
  }

  // TCP主机地址
  String get tcpHost => _prefs.getString('tcp_host') ?? '192.168.8.1';
  set tcpHost(String value) => _prefs.setString('tcp_host', value);

  // TCP端口
  int get tcpPort => _prefs.getInt('tcp_port') ?? 20249;
  set tcpPort(int value) => _prefs.setInt('tcp_port', value);

  // 自动连接
  bool get autoConnect => _prefs.getBool('auto_connect') ?? true;
  set autoConnect(bool value) => _prefs.setBool('auto_connect', value);

  // 通知设置
  bool get enableNotification => _prefs.getBool('enable_notification') ?? true;
  set enableNotification(bool value) => _prefs.setBool('enable_notification', value);

  // 主题模式
  String get themeMode => _prefs.getString('theme_mode') ?? 'system';
  set themeMode(String value) => _prefs.setString('theme_mode', value);

  // WebSocket服务器端口
  int get wsPort => _prefs.getInt('ws_port') ?? 8765;
  set wsPort(int value) => _prefs.setInt('ws_port', value);

  // 是否允许局域网访问内置Web/WebSocket服务器。
  // 默认仅监听127.0.0.1，防止局域网内任意设备通过WebSocket发送AT命令。
  bool get wsAllowLan => _prefs.getBool('ws_allow_lan') ?? false;
  set wsAllowLan(bool value) => _prefs.setBool('ws_allow_lan', value);
}
