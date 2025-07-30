import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:naspend/ui/home/view/home_screen.dart';
import 'package:naspend/ui/home/view_model/home_view_model.dart';
import 'package:naspend/ui/setting/view_model/theme_settings_view_model.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeSettingsViewModel()),
        ChangeNotifierProvider(create: (_) => HomeViewModel()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeSettingsViewModel>(
      builder: (context, themeSettings, child) {

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Naspend',
          themeMode: themeSettings.themeMode,
          theme: ThemeData(
            colorSchemeSeed: themeSettings.colorSelected.color,
            useMaterial3: true,
            brightness: Brightness.light,
          ),
          darkTheme: ThemeData(
            colorSchemeSeed: themeSettings.colorSelected.color,
            useMaterial3: true,
            brightness: Brightness.dark,
          ),
          home: HomeScreen(),
        );
      },
    );
  }
}
