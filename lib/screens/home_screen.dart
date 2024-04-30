import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:hive/hive.dart';
import 'package:rememberme/models/birthday_model.dart';
import 'package:rememberme/screens/settings.dart';
import 'package:rememberme/widgets/navbar.dart';
import 'package:rememberme/widgets/calendar.dart';
import 'package:rememberme/providers/premium_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pink[200],
        title: Text(
          AppLocalizations.of(context)!.title,
          style: const TextStyle(
            fontSize: 30,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.settings, color: Colors.white, size: 35),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return const SettingsScreen();
            }));
          },
        ),
      ),
      body: Consumer<PremiumProvider>(
        builder: (context, premiumProvider, _) {
          return ListView(
            children: [
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  AppLocalizations.of(context)!.birthdayOfTheWeek,
                  style: const TextStyle(
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
                        final endOfWeek =
                            startOfWeek.add(const Duration(days: 7));
                        final birthdaysThisWeek = birthdays
                            .where((birthday) =>
                                birthday.birthday.month == now.month &&
                                birthday.birthday.day >= startOfWeek.day &&
                                birthday.birthday.day <= endOfWeek.day)
                            .toList();
                        if (birthdaysThisWeek.isEmpty) {
                          return Center(
                            child: Text(
                              AppLocalizations.of(context)!.noBirthdaysThisWeek,
                              style: const TextStyle(fontSize: 20),
                            ),
                          );
                        }
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
                                      '${AppLocalizations.of(context)!.giftIdeas} ${birthday.giftIdeas}',
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
                                      '${AppLocalizations.of(context)!.ageCelebrated} $age',
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
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20),
                child: Text(
                  AppLocalizations.of(context)!.monthView,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: MinimalCalendar(),
              ),
              const SizedBox(height: 20),
            ],
          );
        },
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
