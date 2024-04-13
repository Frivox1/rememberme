import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:rememberme/models/birthday_model.dart';
import 'package:rememberme/widgets/navbar.dart';
import 'package:rememberme/widgets/calendar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pink[200],
        title: const Text(
          'RememberMe',
          style: TextStyle(
            fontSize: 30,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.settings, color: Colors.white, size: 35),
          onPressed: () {
            // Ajoutez ici la logique pour ouvrir l'écran des réglages
          },
        ),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 20),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Birthday of the Week',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
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
                    final now = DateTime.now();
                    final startOfWeek =
                        now.subtract(Duration(days: now.weekday - 1));
                    final endOfWeek = startOfWeek.add(Duration(days: 7));
                    final birthdaysThisWeek = birthdays
                        .where((birthday) =>
                            birthday.birthday.month == now.month &&
                            birthday.birthday.day >= startOfWeek.day &&
                            birthday.birthday.day <= endOfWeek.day)
                        .toList();
                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: birthdaysThisWeek.length,
                      itemBuilder: (context, index) {
                        final birthday = birthdaysThisWeek[index];
                        final age = _calculateAge(birthday.birthday);
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.pink[50],
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: ListTile(
                            title: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  birthday.name,
                                  style: const TextStyle(
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.bold),
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
                                    fontWeight: FontWeight.bold,
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
                          ),
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
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 20),
            child: Text(
              'Month View',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(15.0),
            child: MinimalCalendar(
                events: {}), // Remplacez les données factices par les vraies données
          ),
          const SizedBox(height: 20),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavBar(),
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
}
