import 'dart:io';
import 'package:file_picker/file_picker.dart';
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
                leading: const Icon(Icons.arrow_circle_up),
                title: Text(AppLocalizations.of(context)!.export),
                onTap: () async {
                  await _showBirthdaySelectionBottomSheet(context);
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.arrow_circle_down),
                title: Text(AppLocalizations.of(context)!.import),
                onTap: () async {
                  await _importBirthdayData(context);
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.ios_share),
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

    if (allBirthdays.isEmpty) {
      await showModalBottomSheet<void>(
        context: context,
        builder: (BuildContext context) {
          return Container(
            height: 200,
            child: Center(
              child: Text(
                AppLocalizations.of(context)!.noAnniversaries,
                style: TextStyle(fontSize: 20),
              ),
            ),
          );
        },
      );
      return;
    }

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
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink, // Couleur du bouton
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.validate,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
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

  Future<void> _importBirthdayData(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      // Récupérer le chemin du fichier sélectionné
      String? path = result.files.single.path;

      if (path != null) {
        // Vérifier le format du fichier
        bool isFormatValid = await checkFileFormat(path);
        if (!isFormatValid) {
          // Afficher un message d'erreur si le format n'est pas valide
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context)!.invalidFileFormat,
                style: const TextStyle(color: Colors.white, fontSize: 20),
              ),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        // Le format du fichier est valide, continuer le traitement
        // Lire le contenu du fichier
        File file = File(path);
        String content = await file.readAsString();

        // Traitez le contenu du fichier comme souhaité
        List<String> lines = content.split('\n');
        List<Birthday> birthdays = lines.map((line) {
          final parts = line.split(' - ');
          final name = parts[0];
          final dateParts = parts[1].split('/');
          final birthday = DateTime(
            int.parse(dateParts[2]),
            int.parse(dateParts[1]),
            int.parse(dateParts[0]),
          );
          final giftIdeas = parts[2];
          return Birthday(
            name: name,
            birthday: birthday,
            giftIdeas: giftIdeas,
          );
        }).toList();

        // Ajouter les anniversaires à la boîte Hive
        final box = await Hive.openBox<Birthday>('birthdays');
        if (!Provider.of<PremiumProvider>(context, listen: false).isPremium) {
          // Vérifier si le nombre total d'anniversaires dépasse 15 pour les utilisateurs non premium
          if (box.length + birthdays.length > 15) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  AppLocalizations.of(context)!.annif_max,
                  style: const TextStyle(color: Colors.white, fontSize: 20),
                ),
                backgroundColor: Colors.red,
              ),
            );
            return;
          }
        }
        await box.addAll(birthdays);

        // Afficher une notification de réussite
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.importSuccess,
              style: const TextStyle(color: Colors.white, fontSize: 20),
            ),
            backgroundColor: Colors.pink[200],
          ),
        );
      }
    }
  }

  Future<bool> checkFileFormat(String filePath) async {
    try {
      File file = File(filePath);
      String content = await file.readAsString();

      // Vérifier si le contenu du fichier est conforme
      List<String> lines = content.split('\n');
      for (String line in lines) {
        List<String> parts = line.split(' - ');
        if (parts.length != 3) {
          return false;
        }
      }
      // Le fichier respecte le format attendu
      return true;
    } catch (e) {
      // Une erreur s'est produite lors de la lecture du fichier
      return false;
    }
  }
}
