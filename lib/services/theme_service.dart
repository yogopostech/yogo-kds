// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class ThemeService extends GetxService {
//   static ThemeService get to => Get.find();

//   static const _key = 'is_dark_mode';

//   final _isDark = true.obs;
//   bool get isDark => _isDark.value;
//   ThemeMode get themeMode => _isDark.value ? ThemeMode.dark : ThemeMode.light;

//   @override
//   void onInit() {
//     super.onInit();
//     _loadFromPrefs();
//   }

//   Future<void> _loadFromPrefs() async {
//     final prefs = await SharedPreferences.getInstance();
//     _isDark.value = prefs.getBool(_key) ?? true;
//   }

//   Future<void> toggle() async {
//     _isDark.value = !_isDark.value;
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setBool(_key, _isDark.value);
//     Get.changeThemeMode(_isDark.value ? ThemeMode.dark : ThemeMode.light);
//   }
// }