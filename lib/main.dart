import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'data/notification_helper.dart';
import 'l10n/l10n.dart';
import 'utils/app_language.dart';
import 'utils/firebase_service.dart';
import 'theme/app_theme.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await FirebaseService.initialize();

  NotificationHelper().attachNavigatorKey(navigatorKey);
  await NotificationHelper().init();

  await AppLanguage.load();

  await AppTheme.load();

  runApp(const BabyBloomApp());
}

class BabyBloomApp extends StatelessWidget {
  const BabyBloomApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: AppLanguage.notifier,
      builder: (context, languageCode, _) {
        return ValueListenableBuilder<bool>(
          valueListenable: AppTheme.notifier,
          builder: (context, isDark, child) {
            return MaterialApp(
              navigatorKey: navigatorKey,
              title: 'BabyBloom',
              debugShowCheckedModeBanner: false,
              locale: Locale(languageCode),
              supportedLocales: AppLocalizations.supportedLocales,
              localizationsDelegates: AppLocalizations.localizationsDelegates,

              theme: ThemeData(
                colorSchemeSeed: AppColors.primary,
                brightness: isDark ? Brightness.dark : Brightness.light,
                scaffoldBackgroundColor: AppColors.background,
                useMaterial3: true,
                appBarTheme: AppBarTheme(
                  backgroundColor: AppColors.background,
                  foregroundColor: AppColors.textPrimary,
                  elevation: 0,
                  centerTitle: false,
                  titleTextStyle: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                elevatedButtonTheme: ElevatedButtonThemeData(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    textStyle: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
                inputDecorationTheme: InputDecorationTheme(
                  filled: true,
                  fillColor: AppColors.cardBackground,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.divider),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.divider),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppColors.primary,
                      width: 1.4,
                    ),
                  ),
                ),
              ),

              home: const SplashScreen(),
            );
          },
        );
      },
    );
  }
}
