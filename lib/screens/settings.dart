import 'package:flutter/material.dart';
import 'language_screen.dart'; // Importez votre fichier LanguageScreen.dart

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pink[200],
        title: const Text(
          'Settings',
          style: TextStyle(
            fontSize: 30,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: <Widget>[
          const SizedBox(height: 20.0),
          ListTile(
            leading: const Icon(Icons.arrow_upward),
            title: const Row(
              children: [
                Text(
                  'Upgrade to ',
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
                Text(
                  'Premium',
                  style: TextStyle(
                    color: Colors.pink,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            onTap: () {
              setState(() {
                // Votre logique pour activer/désactiver le Premium
              });
            },
          ),
          const Divider(), // Ajouter un diviseur
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Notifications'),
            trailing: Switch(
              value: _notificationsEnabled,
              onChanged: (value) {
                setState(() {
                  _notificationsEnabled = value;
                });
              },
              activeColor: Colors.pink, // Définir la couleur du bouton
            ),
          ),
          const Divider(), // Ajouter un diviseur
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Language'),
            onTap: () {
              // Naviguer vers la nouvelle page LanguageScreen
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LanguageScreen()),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.star),
            title: const Text('Rate the app'),
            onTap: () {
              // Votre logique pour changer le thème
            },
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: SettingsScreen(),
  ));
}
