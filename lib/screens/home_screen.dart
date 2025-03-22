import 'package:flutter/material.dart';
import 'package:rememberme/models/birthday_model.dart';
import 'package:rememberme/screens/add_birthday_screen.dart';
import 'package:rememberme/services/hive_service.dart';
import 'package:table_calendar/table_calendar.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Birthday> upcomingBirthdays = [];
  PageController _pageController = PageController();
  DateTime now = DateTime.now();

  late DateTime selectedDay;
  late DateTime focusedDay;
  late Map<DateTime, List<Birthday>> birthdaysByDate;

  @override
  void initState() {
    super.initState();
    selectedDay = now;
    focusedDay = now;
    birthdaysByDate = {};
    _loadUpcomingBirthdays();
  }

  Future<void> _loadUpcomingBirthdays() async {
    List<Birthday> allBirthdays = await HiveService.getAllBirthdays();

    birthdaysByDate = {};
    List<Birthday> nextBirthdays = [];

    allBirthdays.sort((a, b) {
      DateTime aDate = DateTime(
        now.year,
        a.birthdayDate.month,
        a.birthdayDate.day,
      );
      DateTime bDate = DateTime(
        now.year,
        b.birthdayDate.month,
        b.birthdayDate.day,
      );
      return aDate.compareTo(bDate);
    });

    for (var birthday in allBirthdays) {
      DateTime birthdayDate = DateTime(
        now.year,
        birthday.birthdayDate.month,
        birthday.birthdayDate.day,
      );
      if (birthdayDate.isBefore(now)) {
        birthdayDate = DateTime(
          now.year + 1,
          birthday.birthdayDate.month,
          birthday.birthdayDate.day,
        );
      }

      // Ajouter à la liste des prochains anniversaires
      if (nextBirthdays.length < 3) {
        nextBirthdays.add(birthday);
      }

      // Ajouter au calendrier sans tenir compte de l'année
      DateTime normalizedBirthdayDate = DateTime(
        0, // Année arbitraire, elle ne sera pas utilisée
        birthday.birthdayDate.month,
        birthday.birthdayDate.day,
      );
      if (!birthdaysByDate.containsKey(normalizedBirthdayDate)) {
        birthdaysByDate[normalizedBirthdayDate] = [];
      }
      birthdaysByDate[normalizedBirthdayDate]!.add(birthday);
    }

    setState(() {
      upcomingBirthdays = nextBirthdays;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFE5EC),
      appBar: AppBar(
        backgroundColor: Color(0xFFFB6F92),
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
                Scaffold.of(
                  context,
                ).openDrawer(); // Ouvrir le tiroir avec le context du Builder
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
              decoration: BoxDecoration(color: Colors.pinkAccent),
              child: Text(
                'Menu',
                style: TextStyle(fontSize: 24, color: Colors.white),
              ),
            ),
            ListTile(
              title: Text('Option 1'),
              onTap: () {
                // Gérer la navigation vers l'option 1
              },
            ),
            ListTile(
              title: Text('Option 2'),
              onTap: () {
                // Gérer la navigation vers l'option 2
              },
            ),
          ],
        ),
      ),
      body: Container(
        child: Column(
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
                        upcomingBirthdays.isEmpty
                            ? Center(child: CircularProgressIndicator())
                            : PageView.builder(
                              controller: _pageController,
                              itemCount: upcomingBirthdays.length,
                              itemBuilder: (context, index) {
                                Birthday birthday = upcomingBirthdays[index];
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
                                int age = now.year - birthday.birthdayDate.year;
                                if (now.isBefore(birthdayThisYear)) {
                                  age--;
                                }
                                Duration daysUntilBirthday = birthdayThisYear
                                    .difference(now);
                                String daysRemaining =
                                    '${daysUntilBirthday.inDays} jours';

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
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                      color:
                          Colors
                              .pinkAccent, // Couleur rose pour le chevron gauche
                    ),
                    rightChevronIcon: Icon(
                      Icons.chevron_right,
                      color:
                          Colors
                              .pinkAccent, // Couleur rose pour le chevron droit
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
                            Icons.cake, // Icône gâteau 🎂
                            color: Colors.pinkAccent,
                            size: 24, // Taille ajustable
                          ),
                        );
                      }

                      // Si ce n'est pas un anniversaire, afficher normalement la date
                      return null;
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
