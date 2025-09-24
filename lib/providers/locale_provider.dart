// lib/providers/locale_provider.dart

import 'package:flutter/material.dart';

class LocaleProvider with ChangeNotifier {
  Locale _locale = const Locale('en'); // Default to English

  Locale get locale => _locale;

  void setLocale(Locale locale) {
    _locale = locale;
    notifyListeners(); // Notify widgets to rebuild
  }
}