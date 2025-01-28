import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:json_theme_plus/json_theme_plus.dart';
import 'package:mockapi/pages/home_page.dart';
import 'package:mockapi/viewmodel/theme_view_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final lightThemeStr = await rootBundle.loadString('lib/assets/theme/light_theme.json');
  final darkThemeStr = await rootBundle.loadString('lib/assets/theme/dark_theme.json');

  final lightThemeJson = jsonDecode(lightThemeStr);
  final darkThemeJson = jsonDecode(darkThemeStr);

  final lightTheme = ThemeDecoder.decodeThemeData(lightThemeJson);
  final darkTheme = ThemeDecoder.decodeThemeData(darkThemeJson);

  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ),
  );

  runApp(ProviderScope(
    child: MainApp(
      lightTheme: lightTheme!,
      darkTheme: darkTheme!,
    ),
  ));
}

class MainApp extends ConsumerWidget {
  final ThemeData lightTheme;
  final ThemeData darkTheme;
  const MainApp({
    required this.lightTheme,
    required this.darkTheme,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeViewModelProvider);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeMode,
      home: HomePage(),
    );
  }
}
