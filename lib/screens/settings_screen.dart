import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rememberme/providers/theme_provider.dart';
import 'package:rememberme/providers/language_provider.dart';
import 'package:rememberme/services/app_localizations.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(t(context, "settings"), style: TextStyle(fontSize: 24)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thème
            Text(
              t(context, "theme"),
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(t(context, "darkMode"), style: TextStyle(fontSize: 16)),
                Switch(
                  value: themeProvider.themeMode == ThemeMode.dark,
                  onChanged: (value) {
                    themeProvider.toggleTheme();
                  },
                ),
              ],
            ),
            SizedBox(height: 30),

            // Langue
            Text(
              t(context, "language"),
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  t(context, "select language"),
                  style: TextStyle(fontSize: 16),
                ),
                DropdownButton<String>(
                  value: languageProvider.locale.languageCode,
                  onChanged: (String? newLang) {
                    if (newLang != null) {
                      languageProvider.setLocale(Locale(newLang));
                    }
                  },
                  items: [
                    DropdownMenuItem(value: 'fr', child: Text('Français')),
                    DropdownMenuItem(value: 'en', child: Text('English')),
                  ],
                  underline: SizedBox(), // Retire la barre en dessous
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
