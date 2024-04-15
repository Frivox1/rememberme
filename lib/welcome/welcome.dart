import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:rememberme/models/app_settings.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome to RememberMe'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Never Forget Birthdays',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'RememberMe helps you never forget birthdays!',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                // Change la valeur de isFirstTime à false
                final appSettingsBox = Hive.box<AppSettings>('app_settings');
                final appSettings = appSettingsBox.get('settings',
                    defaultValue: AppSettings(isFirstTime: true));
                appSettings?.isFirstTime = false;
                appSettings?.save();
                // Naviguer vers la page d'accueil
                Navigator.pushReplacementNamed(context, '/home');
              },
              child: Text('Discover the App'),
            ),
          ],
        ),
      ),
    );
  }
}
