import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  Locale _locale = const Locale('fr');
  Map<String, String> _localizedStrings = {};

  Locale get locale => _locale;

  Future<void> loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final langCode = prefs.getString('locale') ?? 'fr';
    await setLocale(Locale(langCode));
  }

  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    final jsonString = await rootBundle.loadString(
      'assets/l10n/${locale.languageCode}.json',
    );
    Map<String, dynamic> jsonMap = json.decode(jsonString);

    _localizedStrings = jsonMap.map(
      (key, value) => MapEntry(key, value.toString()),
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('locale', locale.languageCode);

    notifyListeners();
  }

  String translate(String key) {
    return _localizedStrings[key] ?? '**$key**';
  }
}
