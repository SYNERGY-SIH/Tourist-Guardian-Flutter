// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; // <-- 1. IMPORT THIS
import 'package:my_app/l10n/app_localizations.dart';
import 'package:my_app/providers/locale_provider.dart';
import 'package:my_app/utils/colors.dart';
import 'package:provider/provider.dart';
import 'package:my_app/utils/fallback_localizations_delegate.dart'; // <-- 2. IMPORT OUR NEW HELPER

// Import your page files
import 'package:my_app/pages/login_page.dart';
import 'package:my_app/pages/trip_details_page.dart';
import 'package:my_app/pages/trip_places_page.dart';
import 'package:my_app/pages/home_page.dart';
import 'package:my_app/pages/basic_info_page.dart';
import 'package:my_app/pages/stats_page.dart';
import 'package:my_app/pages/offline_map_page.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => LocaleProvider(),
      child: const TouristApp(),
    ),
  );
}

class TouristApp extends StatelessWidget {
  const TouristApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LocaleProvider>(
      builder: (context, localeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Tourist App',
          theme: ThemeData(
            brightness: Brightness.light,
            scaffoldBackgroundColor: AppColors.background,
            appBarTheme: const AppBarTheme(
              backgroundColor: AppColors.background,
              foregroundColor: AppColors.text,
              elevation: 0,
            ),
            colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
            useMaterial3: true,
          ),
          locale: localeProvider.locale,
          
          // --- 3. USE THE NEW DELEGATES LIST ---
          localizationsDelegates: const [
            AppLocalizations.delegate,
            // Our new custom delegates that handle fallbacks
            FallbackMaterialLocalisationsDelegate(),
            FallbackCupertinoLocalisationsDelegate(),
            // The standard widgets delegate is still needed for text direction
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          initialRoute: '/',
          routes: {
            '/': (context) => const LoginPage(),
            '/tripDetails': (context) => const TripDetailsPage(),
            '/tripPlaces': (context) => const TripPlacesPage(),
            '/home': (context) => const HomePage(),
            '/basicInfo': (context) => const BasicInfoPage(),
            '/stats': (context) => const StatsPage(),
            '/map': (context) => const OfflineMapPage(),
          },
        );
      },
    );
  }
}