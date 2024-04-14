import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:rememberme/models/birthday_model.dart';
import 'package:rememberme/widgets/navbar.dart';

class ListScreen extends StatefulWidget {
  const ListScreen({super.key});

  @override
  _ListScreenState createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  Period _selectedPeriod = Period.Month;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pink[200],
        title: const Text(
          'All Birthdays',
          style: TextStyle(
            fontSize: 30,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          SizedBox(
            child: ToggleButtons(
              isSelected: [
                _selectedPeriod == Period.Week,
                _selectedPeriod == Period.Month,
                _selectedPeriod == Period.Year,
              ],
              onPressed: (int index) {
                setState(() {
                  _selectedPeriod = Period.values[index];
                });
              },
              borderRadius: BorderRadius.circular(
                20.0,
              ), // Définir le rayon pour arrondir les bords
              selectedBorderColor: Colors
                  .white, // Couleur de la bordure lorsqu'un bouton est sélectionné
              selectedColor: Colors.white,
              fillColor: Colors.pink[400],
              children: [
                _buildPeriodButton('This Week', Period.Week),
                _buildPeriodButton('This Month', Period.Month),
                _buildPeriodButton('This Year', Period.Year),
              ], // Couleur de remplissage lorsqu'un bouton est désélectionné
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: FutureBuilder(
              future: Hive.openBox<Birthday>('birthdays'),
              builder: (BuildContext context,
                  AsyncSnapshot<Box<Birthday>> snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasError) {
                    return const Center(
                      child: Text('Error'),
                    );
                  } else {
                    final Box<Birthday> box = snapshot.data!;
                    final List<Birthday> birthdays = box.values.toList();
                    List<Birthday> filteredBirthdays = [];
                    final now = DateTime.now();
                    switch (_selectedPeriod) {
                      case Period.Week:
                        final startOfWeek =
                            now.subtract(Duration(days: now.weekday - 1));
                        final endOfWeek =
                            startOfWeek.add(const Duration(days: 7));
                        filteredBirthdays = birthdays
                            .where((birthday) =>
                                birthday.birthday.month == now.month &&
                                birthday.birthday.day >= startOfWeek.day &&
                                birthday.birthday.day <= endOfWeek.day)
                            .toList();
                        break;
                      case Period.Month:
                        filteredBirthdays = birthdays
                            .where((birthday) =>
                                birthday.birthday.month == now.month)
                            .toList();
                        break;
                      case Period.Year:
                        filteredBirthdays = birthdays;
                        break;
                    }
                    return ListView.builder(
                      itemCount: filteredBirthdays.length,
                      itemBuilder: (BuildContext context, int index) {
                        final Birthday birthday = filteredBirthdays[index];
                        final age = _calculateAge(birthday.birthday);
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 30.0, vertical: 20.0),
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                birthday.name,
                                style: const TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                'Gift Ideas: ${birthday.giftIdeas}',
                                style: const TextStyle(
                                  fontSize: 16.0,
                                ),
                              ),
                            ],
                          ),
                          trailing: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${birthday.birthday.day}/${birthday.birthday.month}/${birthday.birthday.year}',
                                style: const TextStyle(
                                  fontSize: 18.0,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                'Age celebrated: $age',
                                style: const TextStyle(
                                  fontSize: 16.0,
                                ),
                              ),
                            ],
                          ),
                          onTap: () {
                            _showDeleteConfirmationDialog(birthday, box);
                          },
                        );
                      },
                    );
                  }
                } else {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavBar(),
    );
  }

  Widget _buildPeriodButton(String text, Period period) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Text(text),
    );
  }

  int _calculateAge(DateTime birthday) {
    final now = DateTime.now();
    int age = now.year - birthday.year;
    if (now.month < birthday.month ||
        (now.month == birthday.month && now.day < birthday.day)) {
      age--;
    }
    return age + 1;
  }

  // Méthode pour supprimer l'anniversaire
  void _deleteBirthday(Birthday birthday, Box<Birthday> box) {
    box.delete(birthday.key);
    Navigator.of(context).pop(); // Ferme la boîte de dialogue
    setState(() {}); // Met à jour l'interface utilisateur
  }

  // Méthode pour afficher la boîte de dialogue de confirmation de suppression
  void _showDeleteConfirmationDialog(Birthday birthday, Box<Birthday> box) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Birthday?'),
          content: const Text('Are you sure you want to delete this birthday?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Ferme la boîte de dialogue
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.black),
              ),
            ),
            TextButton(
              onPressed: () {
                _deleteBirthday(birthday, box); // Supprime l'anniversaire
              },
              child: const Text(
                'Delete',
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

enum Period { Week, Month, Year }
