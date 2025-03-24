import 'package:flutter/material.dart';
import 'package:rememberme/models/birthday_model.dart';
import 'package:rememberme/screens/add_birthday_screen.dart';
import 'package:rememberme/screens/birthdays_list_screen.dart';
import 'package:rememberme/providers/birthday_provider.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'details_screen.dart';
import 'package:url_launcher/url_launcher.dart';

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

  Future<void> _loadUpcomingBirthdays() async {
    await Provider.of<BirthdayProvider>(context, listen: false).loadBirthdays();
    final upcomingBirthdays =
        Provider.of<BirthdayProvider>(context, listen: false).birthdays;

    birthdaysByDate = {};
    for (var birthday in upcomingBirthdays) {
      DateTime normalizedDay = DateTime(
        0,
        birthday.birthdayDate.month,
        birthday.birthdayDate.day,
      );
      birthdaysByDate.putIfAbsent(normalizedDay, () => []).add(birthday);
    }

    upcomingBirthdays.sort((a, b) {
      int diffA = daysUntilNextBirthday(a.birthdayDate);
      int diffB = daysUntilNextBirthday(b.birthdayDate);
      return diffA.compareTo(diffB);
    });
  }

  int daysUntilNextBirthday(DateTime birthday) {
    DateTime now = DateTime.now();
    DateTime nextBirthday = DateTime(now.year, birthday.month, birthday.day);
    if (nextBirthday.isBefore(now)) {
      nextBirthday = DateTime(now.year + 1, birthday.month, birthday.day);
    }
    return nextBirthday.difference(now).inDays;
  }

  int calculateAge(DateTime birthday) {
    DateTime now = DateTime.now();
    int age = now.year - birthday.year;
    if (now.isBefore(DateTime(now.year, birthday.month, birthday.day))) {
      age--;
    }
    return age;
  }

  Future<void> _openSMSApp() async {
    // Ouvrir l'application de messagerie
    final url = 'sms:';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Impossible d\'ouvrir l\'application de messagerie';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final upcomingBirthdays = List.from(
      Provider.of<BirthdayProvider>(context).birthdays,
    );
    upcomingBirthdays.sort(
      (a, b) => daysUntilNextBirthday(
        a.birthdayDate,
      ).compareTo(daysUntilNextBirthday(b.birthdayDate)),
    );
    final limitedUpcomingBirthdays = upcomingBirthdays.take(3).toList();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('RememberMe', style: theme.textTheme.headlineMedium),
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: Icon(
                Icons.menu,
                color: theme.appBarTheme.foregroundColor,
                size: 34,
              ),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.add_circle_outline,
              color: theme.appBarTheme.foregroundColor,
              size: 34,
            ),
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
              child: Text(
                'Menu',
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.list_outlined, color: theme.iconTheme.color),
              title: Text(
                'Liste des anniversaires',
                style: theme.textTheme.bodyLarge,
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BirthdaysListScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 22),

            // Si c'est l'anniversaire de plusieurs personnes aujourd'hui
            if (birthdaysByDate.containsKey(DateTime(0, now.month, now.day)))
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children:
                      birthdaysByDate[DateTime(0, now.month, now.day)]!.map((
                        birthday,
                      ) {
                        return Padding(
                          padding: const EdgeInsets.only(
                            bottom: 16.0,
                          ), // Ajoute de l'espace entre les cartes
                          child: Container(
                            decoration: BoxDecoration(
                              color: theme.cardColor,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  spreadRadius: 2,
                                  blurRadius: 2,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Titre de l'anniversaire avec le nom coloré
                                  Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                          text: "C'est l'anniversaire de ",
                                          style: theme.textTheme.titleLarge
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                                color:
                                                    theme
                                                        .textTheme
                                                        .titleLarge
                                                        ?.color, // Couleur existante
                                              ),
                                        ),
                                        TextSpan(
                                          text: "${birthday.name} ",
                                          style: theme.textTheme.titleLarge
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                                color:
                                                    theme
                                                        .colorScheme
                                                        .secondary, // Couleur secondaire pour le nom
                                              ),
                                        ),
                                        TextSpan(
                                          text:
                                              "aujourd'hui ! N'oublie pas de lui souhaiter ! 🎂",
                                          style: theme.textTheme.titleLarge
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                                color:
                                                    theme
                                                        .textTheme
                                                        .titleLarge
                                                        ?.color, // Couleur existante pour le reste
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 26),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          onPressed: () {
                                            // Naviguer vers l'écran des détails
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder:
                                                    (context) =>
                                                        BirthdayDetailsScreen(
                                                          birthday: birthday,
                                                        ),
                                              ),
                                            );
                                          },
                                          icon: Icon(Icons.info_outline),
                                          label: Text("Details"),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                theme.colorScheme.onPrimary,
                                            foregroundColor:
                                                theme.colorScheme.primary,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 12,
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 12),
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          onPressed: () {
                                            // ouvrir l'application message
                                            _openSMSApp();
                                          },
                                          icon: Icon(
                                            Icons.message_outlined,
                                            color: Colors.white,
                                          ),
                                          label: Text(
                                            "Message",
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                theme.colorScheme.secondary,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 12,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Prochains anniversaires",
                  style: theme.textTheme.titleLarge,
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
                          style: theme.textTheme.bodyLarge,
                        ),
                      )
                      : PageView.builder(
                        controller: _pageController,
                        itemCount: limitedUpcomingBirthdays.length,
                        itemBuilder: (context, index) {
                          Birthday birthday = limitedUpcomingBirthdays[index];
                          int age = calculateAge(birthday.birthdayDate) + 1;
                          int daysRemaining =
                              daysUntilNextBirthday(birthday.birthdayDate) + 1;

                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => BirthdayDetailsScreen(
                                        birthday: birthday,
                                      ),
                                ),
                              );
                            },
                            child: Container(
                              margin: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: theme.cardColor,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    spreadRadius: 2,
                                    blurRadius: 2,
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
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          birthday.name,
                                          style: theme.textTheme.headlineMedium,
                                        ),
                                        SizedBox(height: 6),
                                        Text(
                                          daysRemaining == 1
                                              ? '$age ans demain'
                                              : '$age ans dans $daysRemaining jours',
                                          style: theme.textTheme.titleMedium,
                                        ),
                                      ],
                                    ),
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      color: theme.iconTheme.color,
                                    ),
                                  ],
                                ),
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
                              ? theme.colorScheme.secondary
                              : theme.colorScheme.secondary.withOpacity(0.4),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 24),
            Padding(
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

                  // Vérifier s'il y a des anniversaires pour cette journée
                  DateTime normalizedDay = DateTime(
                    0,
                    selectedDay.month,
                    selectedDay.day,
                  );
                  List<Birthday>? birthdaysOnSelectedDay =
                      birthdaysByDate[normalizedDay];

                  // Afficher le dialog avec condition
                  _showBirthdayDialog(birthdaysOnSelectedDay);
                },
                startingDayOfWeek: StartingDayOfWeek.monday,
                eventLoader: (day) {
                  DateTime normalizedDay = DateTime(0, day.month, day.day);
                  return birthdaysByDate[normalizedDay] ?? [];
                },
                calendarStyle: CalendarStyle(
                  defaultTextStyle: TextStyle(
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                  todayDecoration: BoxDecoration(
                    color: theme.colorScheme.secondary,
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  selectedTextStyle: TextStyle(
                    color: theme.colorScheme.onPrimary,
                  ),
                  todayTextStyle: TextStyle(color: Colors.white),
                  weekendTextStyle: TextStyle(
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                  markersMaxCount: 0,
                ),
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: TextStyle(
                    color: theme.textTheme.headlineMedium?.color,
                    fontSize: 20,
                  ),
                  leftChevronIcon: Icon(
                    Icons.chevron_left,
                    color: theme.iconTheme.color,
                  ),
                  rightChevronIcon: Icon(
                    Icons.chevron_right,
                    color: theme.iconTheme.color,
                  ),
                ),
                daysOfWeekStyle: DaysOfWeekStyle(
                  weekdayStyle: TextStyle(
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                  weekendStyle: TextStyle(
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                ),
                calendarBuilders: CalendarBuilders(
                  defaultBuilder: (context, day, focusedDay) {
                    DateTime normalizedDay = DateTime(0, day.month, day.day);
                    if (birthdaysByDate.containsKey(normalizedDay)) {
                      return Center(
                        child: Icon(
                          Icons.cake,
                          color: theme.colorScheme.secondary,
                          size: 26,
                        ),
                      );
                    }
                    return null;
                  },
                ),
              ),
            ),
            SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  void _openAddBirthdayScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddBirthdayScreen()),
    ).then((_) => _loadUpcomingBirthdays());
  }

  void _showBirthdayDialog(List<Birthday>? birthdaysOnSelectedDay) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            birthdaysOnSelectedDay != null && birthdaysOnSelectedDay.isNotEmpty
                ? 'Anniversaires du jour'
                : 'Pas d\'anniversaire aujourd\'hui',
            style: theme.textTheme.titleLarge,
          ),
          content:
              birthdaysOnSelectedDay != null &&
                      birthdaysOnSelectedDay.isNotEmpty
                  ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children:
                        birthdaysOnSelectedDay.map((birthday) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Text(
                              birthday.name,
                              style: theme.textTheme.bodyLarge,
                            ),
                          );
                        }).toList(),
                  )
                  : Text(
                    'Pas encore d\'anniversaire pour ce jour-là.',
                    style: theme.textTheme.bodyMedium,
                  ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Fermer'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _openAddBirthdayScreen();
              },
              child: Text('Ajouter un anniversaire'),
            ),
          ],
        );
      },
    );
  }
}
