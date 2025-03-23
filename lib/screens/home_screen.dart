import 'package:flutter/material.dart';
import 'package:rememberme/models/birthday_model.dart';
import 'package:rememberme/screens/add_birthday_screen.dart';
import 'package:rememberme/screens/birthdays_list_screen.dart';
import 'package:rememberme/providers/birthday_provider.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  PageController _pageController = PageController();
  DateTime now = DateTime.now();

  late DateTime selectedDay;
  late DateTime focusedDay;
  late Map<DateTime, List<Birthday>> birthdaysByDate;
  int _currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    selectedDay = now;
    focusedDay = now;
    birthdaysByDate = {};
    _loadUpcomingBirthdays();
    _pageController.addListener(_onPageChanged);
  }

  void _onPageChanged() {
    int nextPage = _pageController.page!.round();
    if (nextPage != _currentPageIndex) {
      setState(() {
        _currentPageIndex = nextPage;
      });
    }
  }

  // Charger les anniversaires
  Future<void> _loadUpcomingBirthdays() async {
    // Utiliser le provider pour récupérer les anniversaires
    await Provider.of<BirthdayProvider>(context, listen: false).loadBirthdays();

    // Trier les anniversaires par le nombre de jours avant l'anniversaire
    final upcomingBirthdays =
        Provider.of<BirthdayProvider>(context, listen: false).birthdays;

    // Initialiser le Map
    birthdaysByDate = {};

    // Remplir le dictionnaire birthdaysByDate avec les anniversaires
    for (var birthday in upcomingBirthdays) {
      DateTime normalizedDay = DateTime(
        0,
        birthday.birthdayDate.month,
        birthday.birthdayDate.day,
      );

      // Ajouter l'anniversaire au map
      if (!birthdaysByDate.containsKey(normalizedDay)) {
        birthdaysByDate[normalizedDay] = [];
      }
      birthdaysByDate[normalizedDay]!.add(birthday);
    }

    // Calculer la différence de jours pour chaque anniversaire
    upcomingBirthdays.sort((a, b) {
      DateTime birthdayA = DateTime(
        now.year,
        a.birthdayDate.month,
        a.birthdayDate.day,
      );
      if (birthdayA.isBefore(now)) {
        birthdayA = DateTime(
          now.year + 1,
          a.birthdayDate.month,
          a.birthdayDate.day,
        );
      }
      Duration diffA = birthdayA.difference(now);

      DateTime birthdayB = DateTime(
        now.year,
        b.birthdayDate.month,
        b.birthdayDate.day,
      );
      if (birthdayB.isBefore(now)) {
        birthdayB = DateTime(
          now.year + 1,
          b.birthdayDate.month,
          b.birthdayDate.day,
        );
      }
      Duration diffB = birthdayB.difference(now);

      return diffA.inDays.compareTo(diffB.inDays);
    });
  }

  /// Fonction pour calculer les jours restants avant un anniversaire
  int daysUntilNextBirthday(DateTime birthday) {
    DateTime now = DateTime.now();
    DateTime nextBirthday = DateTime(now.year, birthday.month, birthday.day);

    // Si l'anniversaire est déjà passé cette année, on prend celui de l'année prochaine
    if (nextBirthday.isBefore(now)) {
      nextBirthday = DateTime(now.year + 1, birthday.month, birthday.day);
    }

    return nextBirthday.difference(now).inDays;
  }

  int calculateAge(DateTime birthday) {
    DateTime now = DateTime.now();
    int age = now.year - birthday.year;

    // Vérifier si l'anniversaire est déjà passé cette année
    DateTime birthdayThisYear = DateTime(
      now.year,
      birthday.month,
      birthday.day,
    );
    age++;
    if (now.isBefore(birthdayThisYear)) {
      age--; // Retirer 1 an si l'anniversaire n'est pas encore passé
    }

    return age;
  }

  @override
  Widget build(BuildContext context) {
    // Accéder à la liste des anniversaires depuis le provider
    final upcomingBirthdays = List.from(
      Provider.of<BirthdayProvider>(context).birthdays,
    );

    // Trier en fonction du nombre de jours restants
    upcomingBirthdays.sort(
      (a, b) => daysUntilNextBirthday(
        a.birthdayDate,
      ).compareTo(daysUntilNextBirthday(b.birthdayDate)),
    );

    final limitedUpcomingBirthdays = upcomingBirthdays.take(3).toList();

    return Scaffold(
      backgroundColor: Color(0xFFFFE5EC),
      appBar: AppBar(
        backgroundColor: Color(0xFFFF8FAB),
        title: Text(
          'RememberMe',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: Icon(Icons.menu, color: Colors.white, size: 34),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add_circle_outline, color: Colors.white, size: 34),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddBirthdayScreen()),
              ).then((_) => _loadUpcomingBirthdays());
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFFFF8FAB)),
              child: Text(
                'Menu',
                style: TextStyle(color: Colors.white, fontSize: 28),
              ),
            ),
            ListTile(
              leading: Icon(Icons.list_outlined),
              title: Text('Liste des anniversaires'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BirthdaysListScreen(),
                  ),
                );
              },
            ),
            ListTile(title: Text('Option 2'), onTap: () {}),
          ],
        ),
      ),
      body: Column(
        children: [
          Container(
            child: Column(
              children: [
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    "Prochains anniversaires",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFB6F92),
                    ),
                  ),
                ),
                SizedBox(
                  height: 150,
                  child:
                      limitedUpcomingBirthdays.isEmpty
                          ? Center(
                            child: Text(
                              "Aucun anniversaire à venir",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[900],
                              ),
                            ),
                          )
                          : PageView.builder(
                            controller: _pageController,
                            itemCount: limitedUpcomingBirthdays.length,
                            itemBuilder: (context, index) {
                              Birthday birthday =
                                  limitedUpcomingBirthdays[index];
                              DateTime birthdayThisYear = DateTime(
                                now.year,
                                birthday.birthdayDate.month,
                                birthday.birthdayDate.day,
                              );
                              if (birthdayThisYear.isBefore(now)) {
                                birthdayThisYear = DateTime(
                                  now.year + 1,
                                  birthday.birthdayDate.month,
                                  birthday.birthdayDate.day,
                                );
                              }
                              int age = calculateAge(birthday.birthdayDate);
                              Duration daysUntilBirthday = birthdayThisYear
                                  .difference(now);
                              String daysRemaining =
                                  '${daysUntilBirthday.inDays + 1} jours';

                              return Container(
                                margin: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.2),
                                      spreadRadius: 1,
                                      blurRadius: 3,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                height: 100,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8.0,
                                    horizontal: 16.0,
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        birthday.name,
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFFFB6F92),
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        '$age ans dans $daysRemaining',
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: Color(0xFFFF8FAB),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      limitedUpcomingBirthdays.length,
                      (index) => Container(
                        margin: EdgeInsets.symmetric(horizontal: 4),
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color:
                              _currentPageIndex == index
                                  ? Color(0xFFFB6F92)
                                  : Colors.grey.shade400,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: TableCalendar(
                firstDay: DateTime.utc(now.year - 1, 1, 1),
                lastDay: DateTime.utc(now.year + 1, 12, 31),
                focusedDay: focusedDay,
                selectedDayPredicate: (day) => isSameDay(selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    this.selectedDay = selectedDay;
                    this.focusedDay = focusedDay;
                  });
                },
                eventLoader: (day) {
                  DateTime normalizedDay = DateTime(0, day.month, day.day);
                  return birthdaysByDate[normalizedDay] ?? [];
                },
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: Colors.pinkAccent,
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: Colors.pinkAccent,
                    shape: BoxShape.circle,
                  ),
                  markersMaxCount: 0,
                ),
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  leftChevronIcon: Icon(
                    Icons.chevron_left,
                    color: Colors.pinkAccent,
                  ),
                  rightChevronIcon: Icon(
                    Icons.chevron_right,
                    color: Colors.pinkAccent,
                  ),
                ),
                daysOfWeekStyle: DaysOfWeekStyle(
                  weekdayStyle: TextStyle(color: Colors.black),
                  weekendStyle: TextStyle(color: Colors.black),
                ),
                calendarBuilders: CalendarBuilders(
                  defaultBuilder: (context, day, focusedDay) {
                    DateTime normalizedDay = DateTime(0, day.month, day.day);
                    bool isBirthday = birthdaysByDate.containsKey(
                      normalizedDay,
                    );

                    if (isBirthday) {
                      return Center(
                        child: Icon(
                          Icons.cake,
                          color: Colors.pinkAccent,
                          size: 26,
                        ),
                      );
                    }

                    return null;
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
