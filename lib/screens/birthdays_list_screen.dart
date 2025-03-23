import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rememberme/models/birthday_model.dart';
import 'package:rememberme/providers/birthday_provider.dart';
import 'details_screen.dart';

class BirthdaysListScreen extends StatefulWidget {
  @override
  _BirthdaysListScreenState createState() => _BirthdaysListScreenState();
}

class _BirthdaysListScreenState extends State<BirthdaysListScreen> {
  String _sortBy =
      'Prochain anniversaire'; // Trier par défaut par ordre d'anniversaire proche

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      Provider.of<BirthdayProvider>(context, listen: false).loadBirthdays();
    });
  }

  /// Fonction pour calculer le nombre de jours restants avant un anniversaire
  int daysUntilNextBirthday(DateTime birthday) {
    DateTime now = DateTime.now();
    DateTime nextBirthday = DateTime(now.year, birthday.month, birthday.day);

    // Si l'anniversaire est déjà passé cette année, prendre celui de l'année prochaine
    if (nextBirthday.isBefore(now)) {
      nextBirthday = DateTime(now.year + 1, birthday.month, birthday.day);
    }

    return nextBirthday.difference(now).inDays;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFE5EC),
      appBar: AppBar(
        title: Text(
          "Liste des Anniversaires",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Color(0xFFFF8FAB),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.sort, color: Colors.white),
            onSelected: (String newValue) {
              setState(() {
                _sortBy = newValue;
              });
            },
            itemBuilder:
                (BuildContext context) => [
                  PopupMenuItem(
                    value: 'Prochain anniversaire',
                    child: Text('Trier par date d\'arrivée'),
                  ),
                  PopupMenuItem(
                    value: 'Alphabetique',
                    child: Text('Trier par nom'),
                  ),
                ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Consumer<BirthdayProvider>(
          builder: (context, birthdayProvider, child) {
            List<Birthday> birthdays = List.from(birthdayProvider.birthdays);

            // Trier en fonction du mode sélectionné
            if (_sortBy == 'Prochain anniversaire') {
              birthdays.sort(
                (a, b) => daysUntilNextBirthday(
                  a.birthdayDate,
                ).compareTo(daysUntilNextBirthday(b.birthdayDate)),
              );
            } else if (_sortBy == 'Alphabetique') {
              birthdays.sort(
                (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
              );
            }

            if (birthdays.isEmpty) {
              return Center(
                child: Text(
                  "Pas encore d'anniversaire ajouté",
                  style: TextStyle(fontSize: 16),
                ),
              );
            }

            return ListView.builder(
              itemCount: birthdays.length,
              itemBuilder: (context, index) {
                final birthday = birthdays[index];
                int daysLeft = daysUntilNextBirthday(birthday.birthdayDate);

                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  margin: EdgeInsets.symmetric(vertical: 8),
                  elevation: 2,
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 12,
                    ),
                    leading: Icon(
                      Icons.cake,
                      color: Colors.pinkAccent,
                      size: 30,
                    ),
                    title: Text(
                      birthday.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    subtitle: Text(
                      'Anniversaire le ${birthday.birthdayDate.day}/${birthday.birthdayDate.month} - Dans $daysLeft jours',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) =>
                                  BirthdayDetailsScreen(birthday: birthday),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
