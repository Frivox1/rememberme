import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rememberme/providers/langue_provider.dart';

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
              value: 'Français',
              groupValue: selectedLanguage,
              onChanged: (value) {
                setState(() {
                  selectedLanguage = value!;
                });
              },
              activeColor: Colors.pink,
            ),
            const Divider(), // Ajouter un diviseur
            RadioListTile<String>(
              title: Text(
                '🇬🇧 English',
                style: TextStyle(
                  fontSize: fontSize,
                ),
              ),
              value: 'English',
              groupValue: selectedLanguage,
              onChanged: (value) {
                setState(() {
                  selectedLanguage = value!;
                });
              },
              activeColor: Colors.pink,
            ),
            const Divider(), // Ajouter un diviseur
            RadioListTile<String>(
              title: Text(
                '🇳🇱 Nederlands',
                style: TextStyle(
                  fontSize: fontSize,
                ),
              ),
              value: 'Nederlands',
              groupValue: selectedLanguage,
              onChanged: (value) {
                setState(() {
                  selectedLanguage = value!;
                });
              },
              activeColor: Colors.pink,
            ),
            const Divider(), // Ajouter un diviseur
            RadioListTile<String>(
              title: Text(
                '🇩🇪 Deutsch',
                style: TextStyle(
                  fontSize: fontSize,
                ),
              ),
              value: 'Deutsch',
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
                onPressed: () {
                  final selectedLanguageCode = selectedLanguage == 'Français'
                      ? 'fr'
                      : selectedLanguage == 'English'
                          ? 'en'
                          : selectedLanguage == 'Nederlands'
                              ? 'nl'
                              : 'de';
                  Provider.of<LanguageProvider>(context, listen: false)
                      .setLocale(selectedLanguageCode);
                  Navigator.pushNamed(context, '/home');
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
}
