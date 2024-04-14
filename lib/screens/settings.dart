import 'package:flutter/material.dart';
import 'language_screen.dart'; // Importez votre fichier LanguageScreen.dart

class SettingsScreen extends StatefulWidget {
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
        padding: EdgeInsets.all(16.0),
        children: <Widget>[
          SizedBox(height: 20.0),
          ListTile(
            leading: Icon(Icons.star),
            title: Row(
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
          Divider(), // Ajouter un diviseur
          ListTile(
            leading: Icon(Icons.notifications),
            title: Text('Notifications'),
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
          Divider(), // Ajouter un diviseur
          ListTile(
            leading: Icon(Icons.language),
            title: Text('Language'),
            onTap: () {
              // Naviguer vers la nouvelle page LanguageScreen
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LanguageScreen()),
              );
            },
          ),
          Divider(), // Ajouter un diviseur
        ],
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: SettingsScreen(),
  ));
}
