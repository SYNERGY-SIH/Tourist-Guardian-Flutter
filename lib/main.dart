import 'package:flutter/material.dart';
import 'package:my_app/pages/login_page.dart';
import 'package:my_app/pages/trip_details_page.dart';
import 'package:my_app/pages/trip_places_page.dart';
import 'package:my_app/pages/home_page.dart';
import 'package:my_app/pages/basic_info_page.dart';
import 'package:my_app/pages/stats_page.dart';
import 'package:my_app/pages/offline_map_page.dart';
import 'package:my_app/utils/colors.dart'; // Import colors for theme

void main() {
  runApp(const TouristApp());
}

class TouristApp extends StatelessWidget {
  const TouristApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tourist App',
      // CHANGE THE THEME DATA
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppColors.background,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.background,
          foregroundColor: AppColors.text,
          elevation: 0, // A modern, flat app bar
        ),
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        useMaterial3: true,
      ),
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
  }
}