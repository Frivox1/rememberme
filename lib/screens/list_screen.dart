import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hive/hive.dart';
import 'package:rememberme/models/birthday_model.dart';
import 'package:rememberme/widgets/navbar.dart';

class ListScreen extends StatefulWidget {
  const ListScreen({Key? key}) : super(key: key);

  @override
  _ListScreenState createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  Period _selectedPeriod = Period.Year;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pink[200],
        title: Text(
          AppLocalizations.of(context)!.listBirthdays,
          style: const TextStyle(
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
              ),
              selectedBorderColor: Colors.white,
              selectedColor: Colors.white,
              fillColor: Colors.pink[400],
              children: [
                _buildPeriodButton(
                  AppLocalizations.of(context)!.this_week,
                  Period.Week,
                ),
                _buildPeriodButton(
                  AppLocalizations.of(context)!.this_month,
                  Period.Month,
                ),
                _buildPeriodButton(
                  AppLocalizations.of(context)!.this_year,
                  Period.Year,
                ),
              ],
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
                    if (filteredBirthdays.isEmpty) {
                      return Center(
                        child: Text(
                          AppLocalizations.of(context)!.no_birthdays,
                          style: const TextStyle(fontSize: 20.0),
                          textAlign: TextAlign.center,
                        ),
                      );
                    }
                    return Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            itemCount: filteredBirthdays.length,
                            itemBuilder: (BuildContext context, int index) {
                              final Birthday birthday =
                                  filteredBirthdays[index];
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
                                      '${AppLocalizations.of(context)!.gift_ideas} ${birthday.giftIdeas}',
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
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      '${AppLocalizations.of(context)!.age_celebrated} $age',
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
                          ),
                        ),
                      ],
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

  void _deleteBirthday(Birthday birthday, Box<Birthday> box) {
    box.delete(birthday.key);
    Navigator.of(context).pop();
    setState(() {});
  }

  void _showDeleteConfirmationDialog(Birthday birthday, Box<Birthday> box) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.delete_birthday),
          content: Text(AppLocalizations.of(context)!.confirm_delete),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                AppLocalizations.of(context)!.cancel,
                style: const TextStyle(color: Colors.black),
              ),
            ),
            TextButton(
              onPressed: () {
                _deleteBirthday(birthday, box);
              },
              child: Text(
                AppLocalizations.of(context)!.delete,
                style: const TextStyle(
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
