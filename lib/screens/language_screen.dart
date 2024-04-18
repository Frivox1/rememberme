import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:rememberme/models/language_model.dart';
import 'package:rememberme/main.dart';
import 'package:rememberme/providers/langue_provider.dart';
import 'package:rememberme/providers/premium_provider.dart';
import 'package:rememberme/screens/home_screen.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({Key? key}) : super(key: key);

  @override
  _LanguageScreenState createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  String selectedLanguage = '';

  final double fontSize = 24;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pink[200],
        title: const Text(
          'Choose language',
          style: TextStyle(
            fontSize: 30,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const SizedBox(height: 20.0),
            RadioListTile<String>(
              title: Text(
                '🇫🇷 Français',
                style: TextStyle(
                  fontSize: fontSize,
                ),
              ),
              value: 'fr',
              groupValue: selectedLanguage,
              onChanged: (value) {
                setState(() {
                  selectedLanguage = value!;
                });
              },
              activeColor: Colors.pink,
            ),
            const Divider(),
            RadioListTile<String>(
              title: Text(
                '🇬🇧 English',
                style: TextStyle(
                  fontSize: fontSize,
                ),
              ),
              value: 'en',
              groupValue: selectedLanguage,
              onChanged: (value) {
                setState(() {
                  selectedLanguage = value!;
                });
              },
              activeColor: Colors.pink,
            ),
            const Divider(),
            RadioListTile<String>(
              title: Text(
                '🇳🇱 Nederlands',
                style: TextStyle(
                  fontSize: fontSize,
                ),
              ),
              value: 'nl',
              groupValue: selectedLanguage,
              onChanged: (value) {
                setState(() {
                  selectedLanguage = value!;
                });
              },
              activeColor: Colors.pink,
            ),
            const Divider(),
            RadioListTile<String>(
              title: Text(
                '🇩🇪 Deutsch',
                style: TextStyle(
                  fontSize: fontSize,
                ),
              ),
              value: 'de',
              groupValue: selectedLanguage,
              onChanged: (value) {
                setState(() {
                  selectedLanguage = value!;
                });
              },
              activeColor: Colors.pink,
            ),
            SizedBox(height: 100.0),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  // Update language in Hive
                  final languageBox = Hive.box<LanguageModel>('language');
                  final languageModel = LanguageModel(locale: selectedLanguage);
                  await languageBox.put('locale', languageModel);

                  // Notify the provider with the selected language
                  Provider.of<LanguageProvider>(context, listen: false)
                      .setLocale(Locale(selectedLanguage));

                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const HomeScreen()));
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.pink[200],
                  textStyle: const TextStyle(
                    fontSize: 24,
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 15,
                    horizontal: 30,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Validate selection'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Method to restart the app
  void restartApp() {
    // Delay restart to ensure UI updates are completed
    Timer(Duration(milliseconds: 500), () {
      // Perform a hot restart of the app
      // Note: This will restart the entire app, equivalent to stopping and starting it again
      runApp(
        ChangeNotifierProvider(
          create: (context) => PremiumProvider(),
          child: const MyApp(),
        ),
      );
    });
  }
}
