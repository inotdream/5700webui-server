import 'package:get/get.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/dashboard/bindings/dashboard_binding.dart';
import '../modules/dashboard/views/dashboard_view.dart';
import '../modules/sms/bindings/sms_binding.dart';
import '../modules/sms/views/sms_view.dart';
import '../modules/console/bindings/console_binding.dart';
import '../modules/console/views/console_view.dart';
import '../modules/settings/bindings/settings_binding.dart';
import '../modules/settings/views/settings_view.dart';
import '../modules/network/bindings/network_binding.dart';
import '../modules/network/views/network_view.dart';
import '../modules/speedtest/bindings/speedtest_binding.dart';
import '../modules/speedtest/views/speedtest_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.HOME;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.DASHBOARD,
      page: () => const DashboardView(),
      binding: DashboardBinding(),
    ),
    GetPage(
      name: _Paths.SMS,
      page: () => const SmsView(),
      binding: SmsBinding(),
    ),
    GetPage(
      name: _Paths.CONSOLE,
      page: () => const ConsoleView(),
      binding: ConsoleBinding(),
    ),
    GetPage(
      name: _Paths.SETTINGS,
      page: () => const SettingsView(),
      binding: SettingsBinding(),
    ),
    GetPage(
      name: _Paths.NETWORK,
      page: () => const NetworkView(),
      binding: NetworkBinding(),
    ),
    GetPage(
      name: _Paths.SPEEDTEST,
      page: () => const SpeedTestView(),
      binding: SpeedTestBinding(),
    ),
  ];
}

