import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rememberme/providers/premium_provider.dart';
import 'package:rememberme/screens/language_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

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
      body: Consumer<PremiumProvider>(
        builder: (context, premiumProvider, _) {
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: <Widget>[
              const SizedBox(height: 20.0),
              ListTile(
                leading: const Icon(Icons.arrow_upward),
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
                        color: premiumProvider.isPremium
                            ? Colors.green
                            : Colors.pink,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                onTap: () {
                  premiumProvider.setPremium(!premiumProvider.isPremium);
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.notifications),
                title: const Text('Notifications'),
                trailing: Switch(
                  value: premiumProvider.isPremium,
                  onChanged: (value) {
                    if (!premiumProvider.isPremium) {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Upgrade to Premium'),
                          content: const Text(
                              'Upgrade to premium to enable notifications'),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      );
                    } else {
                      // Implementer la logique pour activer les notifications
                    }
                  },
                  activeColor: Colors.pink,
                ),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.language),
                title: const Text('Language'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LanguageScreen(),
                    ),
                  );
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.share),
                title: const Text('Share the app'),
                onTap: () {},
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
          );
        },
      ),
    );
  }
}
