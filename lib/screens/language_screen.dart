import 'package:flutter/material.dart';

class LanguageScreen extends StatelessWidget {
  final double fontSize = 24;

  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Choose Language',
          style: TextStyle(
            fontSize: 30,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ListView(
          children: <Widget>[
            const SizedBox(height: 20.0),
            ListTile(
              title: Text(
                '🇫🇷 Français',
                style: TextStyle(
                  fontSize: fontSize,
                ), // Taille de police pour le texte
              ),
              onTap: () {
                // Logique pour changer la langue en français
                Navigator.pop(context, 'Français');
              },
            ),
            const Divider(), // Ajouter un diviseur
            ListTile(
              title: Text(
                '🇬🇧 English',
                style: TextStyle(
                  fontSize: fontSize,
                ), // Taille de police pour le texte
              ),
              onTap: () {
                // Logique pour changer la langue en anglais
                Navigator.pop(context, 'English');
              },
            ),
            const Divider(), // Ajouter un diviseur
            ListTile(
              title: Text(
                '🇳🇱 Nederlands',
                style: TextStyle(
                  fontSize: fontSize,
                ), // Taille de police pour le texte
              ),
              onTap: () {
                // Logique pour changer la langue en néerlandais
                Navigator.pop(context, 'Nederlands');
              },
            ),
            const Divider(), // Ajouter un diviseur
            ListTile(
              title: Text(
                '🇩🇪 Deutsch',
                style: TextStyle(
                  fontSize: fontSize,
                ), // Taille de police pour le texte
              ),
              onTap: () {
                // Logique pour changer la langue en allemand
                Navigator.pop(context, 'Deutsch');
              },
            ),
          ],
        ),
      ),
    );
  }
}
