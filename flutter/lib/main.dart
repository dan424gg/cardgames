import 'package:flutter/material.dart';
import 'widgets/floating_suits_background.dart';
import 'theme/app_theme.dart';
import 'dart:io';
import 'package:window_manager/window_manager.dart';
import 'package:flutter/foundation.dart';
import 'screens/home.dart';
import 'routes/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    await windowManager.ensureInitialized();
    WindowOptions windowOptions = const WindowOptions(
      size: Size(800, 600),
      minimumSize: Size(800, 600),
      center: true,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.normal,
    );

    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appRouter = AppRouter();

    return MaterialApp.router(
      theme: AppTheme.theme,
      builder: (context, child) {
        return SuitsBackgroundWrapper(child: child ?? const SizedBox());
      },
      routerConfig: appRouter.config(),
      // home: SuitsBackgroundWrapper(child: const HomeScreen()),
    );
  }
}
