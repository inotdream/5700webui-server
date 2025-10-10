part of 'app_pages.dart';

abstract class Routes {
  Routes._();
  static const HOME = _Paths.HOME;
  static const DASHBOARD = _Paths.DASHBOARD;
  static const SMS = _Paths.SMS;
  static const CONSOLE = _Paths.CONSOLE;
  static const SETTINGS = _Paths.SETTINGS;
}

abstract class _Paths {
  _Paths._();
  static const HOME = '/home';
  static const DASHBOARD = '/dashboard';
  static const SMS = '/sms';
  static const CONSOLE = '/console';
  static const SETTINGS = '/settings';
}

