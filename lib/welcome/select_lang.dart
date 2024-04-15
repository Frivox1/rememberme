import 'package:flutter/material.dart';
import 'package:rememberme/welcome/how_did_you_find_app_page.dart';

class SelectLang extends StatefulWidget {
  const SelectLang({Key? key}) : super(key: key);

  @override
  _SelectLangState createState() => _SelectLangState();
}

class _SelectLangState extends State<SelectLang> {
  late String selectedLanguage = "";

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
            const Divider(),
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
            const Divider(),
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
            const Divider(),
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
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: ElevatedButton(
          onPressed: () {
            // Logique pour passer à la prochaine page ici
            if (selectedLanguage.isNotEmpty) {
              // Naviguer vers la prochaine page
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return const HowDidYouFindAppPage();
              }));
            } else {
              // Afficher un message d'erreur si aucune langue n'est sélectionnée
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Please select a language'),
                ),
              );
            }
          },
          child: Text('Next'),
        ),
      ),
    );
  }
}
