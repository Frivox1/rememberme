import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:rememberme/models/language_model.dart';
import 'package:rememberme/providers/langue_provider.dart';
import 'package:rememberme/welcome/how_did_you_find_app_page.dart';

class SelectLang extends StatefulWidget {
  const SelectLang({Key? key}) : super(key: key);

  @override
  _SelectLangState createState() => _SelectLangState();
}

class _SelectLangState extends State<SelectLang> {
  late String selectedLanguage = '';

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
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ListView(
          children: <Widget>[
            const SizedBox(height: 20.0),
            RadioListTile<String>(
              title: Text(
                '🇫🇷 Français',
                style: TextStyle(
                  fontSize: 24,
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
                  fontSize: 24,
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
                  fontSize: 24,
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
                  fontSize: 24,
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
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: ElevatedButton(
          onPressed: () {
            if (selectedLanguage.isNotEmpty) {
              // Enregistrer la langue sélectionnée dans la boîte de données 'language'
              final languageBox = Hive.box<LanguageModel>('language');
              languageBox.put(
                  'locale', LanguageModel(locale: selectedLanguage));

              Provider.of<LanguageProvider>(context, listen: false)
                  .setLocale(Locale(selectedLanguage));

              // Passer à la page suivante
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const HowDidYouFindAppPage(),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please select a language'),
                ),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.pink[300],
          ),
          child: const Text(
            'Next',
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        ),
      ),
    );
  }
}
