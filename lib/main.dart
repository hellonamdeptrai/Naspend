import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:naspend/core/router/app_router.dart';
import 'package:naspend/data/datasources/local/database.dart';
import 'package:naspend/ui/category/view_model/add_category_view_model.dart';
import 'package:naspend/ui/category/view_model/category_view_model.dart';
import 'package:naspend/ui/dashboard/view_model/dashboard_view_model.dart';
import 'package:naspend/ui/home/view/home_screen.dart';
import 'package:naspend/ui/home/view_model/home_view_model.dart';
import 'package:naspend/ui/note/view_model/note_view_model.dart';
import 'package:naspend/ui/setting/view_model/theme_settings_view_model.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        Provider<AppDatabase>(
          create: (_) => AppDatabase(),
          dispose: (_, db) => db.close(),
        ),
        ChangeNotifierProvider(create: (_) => ThemeSettingsViewModel()),
        ChangeNotifierProvider(create: (_) => HomeViewModel()),
        ChangeNotifierProvider(create: (_) => DashboardViewModel()),
        ChangeNotifierProvider(create: (_) => NoteViewModel()),
        ChangeNotifierProvider(create: (context) => CategoryViewModel(
          context.read<AppDatabase>(),
        )),
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

        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          locale: const Locale('vi', 'VN'), // 2. Đặt ngôn ngữ mặc định là Tiếng Việt
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('vi', 'VN'), // Hỗ trợ Tiếng Việt
            Locale('en', 'US'), // Hỗ trợ Tiếng Anh (dự phòng)
          ],
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
          routerConfig: AppRouter.router,
        );
      },
    );
  }
}
