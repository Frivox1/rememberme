import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:rememberme/main.dart';
import 'package:rememberme/models/birthday_model.dart';
import 'package:rememberme/providers/premium_provider.dart';
import 'package:rememberme/screens/language_screen.dart';
import 'package:share/share.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TimeOfDay selectedTime = TimeOfDay.now(); // Définition de selectedTime
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
                  // Mise à jour de l'état premium dans la boîte de données
                  final premiumProvider =
                      Provider.of<PremiumProvider>(context, listen: false);
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
                leading: const Icon(Icons.ios_share),
                title: const Text("Export anniversary data"),
                onTap: () async {
                  await _showBirthdaySelectionBottomSheet(context);
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

  Future<void> _showBirthdaySelectionBottomSheet(BuildContext context) async {
    final box = await Hive.openBox<Birthday>('birthdays');
    final List<Birthday> allBirthdays = box.values.toList();

    List<Birthday> selectedBirthdays = [];

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              padding: EdgeInsets.all(16.0),
              height: MediaQuery.of(context).size.height * 0.5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: allBirthdays.map((birthday) {
                          final formattedDate =
                              "${birthday.birthday.day}/${birthday.birthday.month}/${birthday.birthday.year}";
                          return CheckboxListTile(
                            title: Text(
                              '${birthday.name} - $formattedDate - ${birthday.giftIdeas}',
                            ),
                            value: selectedBirthdays.contains(birthday),
                            onChanged: (bool? value) {
                              setState(() {
                                if (value != null && value) {
                                  selectedBirthdays.add(birthday);
                                } else {
                                  selectedBirthdays.remove(birthday);
                                }
                              });
                            },
                            activeColor:
                                Colors.pink, // Couleur de la case cochée
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _exportSelectedBirthdays(selectedBirthdays);
                    },
                    child: Text(
                      'Valider',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink, // Couleur du bouton
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _exportSelectedBirthdays(
      List<Birthday> selectedBirthdays) async {
    final List<String> birthdayLines = selectedBirthdays.map((birthday) {
      final formattedDate =
          "${birthday.birthday.day}/${birthday.birthday.month}/${birthday.birthday.year}";
      return "${birthday.name} - $formattedDate - ${birthday.giftIdeas}";
    }).toList();

    final String content = birthdayLines.join('\n');

    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/selected_birthdays.txt');
    await file.writeAsString(content);

    Share.shareFiles(['${directory.path}/selected_birthdays.txt']);
  }
}
