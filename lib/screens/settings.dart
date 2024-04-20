import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rememberme/main.dart';
import 'package:rememberme/providers/premium_provider.dart';
import 'package:rememberme/screens/language_screen.dart';
import 'package:share/share.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pink[200],
        title: Text(
          AppLocalizations.of(context)!.settings,
          style: const TextStyle(
            fontSize: 30,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
      body: Consumer<PremiumProvider>(
        builder: (context, premiumProvider, _) {
          bool notificationsEnabled = premiumProvider.isPremium;
          TimeOfDay selectedTime = TimeOfDay
              .now(); // Ajout de la variable pour stocker l'heure sélectionnée
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: <Widget>[
              const SizedBox(height: 20.0),
              ListTile(
                leading: const Icon(Icons.arrow_upward),
                title: Row(
                  children: [
                    Text(
                      '${AppLocalizations.of(context)!.upgradeTo} ',
                      style: const TextStyle(
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      AppLocalizations.of(context)!.premium,
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
                title: Text(AppLocalizations.of(context)!.notifications),
                trailing: Switch(
                  value: notificationsEnabled,
                  onChanged: (value) {
                    if (!premiumProvider.isPremium) {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text(
                            AppLocalizations.of(context)!.upgradeToPremium,
                          ),
                          content: Text(
                            AppLocalizations.of(context)!.messageToPremium,
                          ),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text(
                                AppLocalizations.of(context)!.cancel,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text(
                                'OK',
                              ),
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
                leading: Icon(
                  Icons.alarm,
                  color: notificationsEnabled ? Colors.black : Colors.grey,
                ),
                title: Text(
                  AppLocalizations.of(context)!.changeHour,
                  style: TextStyle(
                    color: notificationsEnabled ? Colors.black : Colors.grey,
                  ),
                ),
                onTap: notificationsEnabled
                    ? () async {
                        final selectedTimeOfDay = await showTimePicker(
                          context: context,
                          initialTime: selectedTime,
                        );
                        if (selectedTimeOfDay != null) {
                          // Calcule le délai en minutes à partir de l'heure sélectionnée
                          int selectedDelayInMinutes =
                              selectedTimeOfDay.hour * 60 +
                                  selectedTimeOfDay.minute;
                          // Met à jour la variable globale periodicTaskDelayInMinutes
                          periodicTaskDelayInMinutes = selectedDelayInMinutes;
                          // Affiche une confirmation ou effectue d'autres actions si nécessaire
                          print(periodicTaskDelayInMinutes);
                        }
                      }
                    : null,
                // Si les notifications ne sont pas activées, onTap est nul
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.language),
                title: Text(AppLocalizations.of(context)!.language),
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
                title: Text(AppLocalizations.of(context)!.shareTheApp),
                onTap: () {
                  Share.share('Check out this awesome app!');
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.star),
                title: Text(AppLocalizations.of(context)!.rateTheApp),
                onTap: () {},
              ),
            ],
          );
        },
      ),
    );
  }
}
