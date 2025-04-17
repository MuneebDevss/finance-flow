import 'package:finance/Core/Theme/theme.dart';
import 'package:finance/Features/Settings/Domain/theme_repository.dart';
import 'package:get/get.dart';

class ThemeController extends GetxController {
  final _isDarkMode = true.obs;
  final ThemePreference _themePreference = ThemePreference();

  bool get isDarkMode => _isDarkMode.value;

  @override
  void onInit() {
    super.onInit();
    _loadTheme();
  }

  void _loadTheme() async {
    _isDarkMode.value = await _themePreference.getTheme();
    Get.changeTheme(_isDarkMode.value ? TAppTheme.darkTheme : TAppTheme.lightTheme);
  }

  void toggleTheme(bool isDark) {
    _isDarkMode.value = isDark;
    _themePreference.setTheme(isDark);
    Get.changeTheme(isDark ? TAppTheme.darkTheme : TAppTheme.lightTheme);
  }
}
