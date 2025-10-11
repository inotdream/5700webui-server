import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService extends GetxService {
  late SharedPreferences _prefs;

  Future<StorageService> init() async {
    _prefs = await SharedPreferences.getInstance();
    return this;
  }

  // 连接模式：tcp 或 websocket
  String get connectionMode => _prefs.getString('connection_mode') ?? 'tcp';
  set connectionMode(String value) => _prefs.setString('connection_mode', value);

  // WebSocket服务器地址
  String get serverUrl => _prefs.getString('server_url') ?? 'ws://192.168.8.1:8765';
  set serverUrl(String value) => _prefs.setString('server_url', value);

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
}
