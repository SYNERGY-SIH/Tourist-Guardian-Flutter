import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// These delegates are used to handle cases where a language (like Nyishi 'njz')
// is supported by our app but not by Flutter's default Material/Cupertino widgets.
// It attempts to load the requested locale, but if it fails, it falls back to English ('en').

class FallbackMaterialLocalisationsDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const FallbackMaterialLocalisationsDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<MaterialLocalizations> load(Locale locale) async {
    try {
      // The default delegate is a static method, so we can call it directly.
      return await DefaultMaterialLocalizations.load(locale);
    } catch (e) {
      // If it fails, fall back to English.
      return await DefaultMaterialLocalizations.load(const Locale('en'));
    }
  }

  @override
  bool shouldReload(FallbackMaterialLocalisationsDelegate old) => false;
}

class FallbackCupertinoLocalisationsDelegate
    extends LocalizationsDelegate<CupertinoLocalizations> {
  const FallbackCupertinoLocalisationsDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<CupertinoLocalizations> load(Locale locale) async {
    try {
      return await DefaultCupertinoLocalizations.load(locale);
    } catch (e) {
      // If it fails, fall back to English.
      return await DefaultCupertinoLocalizations.load(const Locale('en'));
    }
  }

  @override
  bool shouldReload(FallbackCupertinoLocalisationsDelegate old) => false;
}