import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rememberme/models/birthday_model.dart';
import 'package:rememberme/providers/birthday_provider.dart';
import 'package:rememberme/services/app_localizations.dart';
import 'details_screen.dart';

class BirthdaysListScreen extends StatefulWidget {
  @override
  _BirthdaysListScreenState createState() => _BirthdaysListScreenState();
}

class _BirthdaysListScreenState extends State<BirthdaysListScreen> {
  String _sortBy = 'upcoming'; // Use keys instead of display strings

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      Provider.of<BirthdayProvider>(context, listen: false).loadBirthdays();
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          t(context, "birthday list capital"),
          style: theme.appBarTheme.titleTextStyle,
        ),
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: theme.appBarTheme.iconTheme?.color,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(
              Icons.swap_vert,
              color: theme.appBarTheme.iconTheme?.color,
              size: 28,
            ),
            onSelected: (String newValue) {
              setState(() {
                _sortBy = newValue;
              });
            },
            itemBuilder:
                (BuildContext context) => [
                  PopupMenuItem(
                    value: 'upcoming',
                    child: Text(t(context, 'sort by date')),
                  ),
                  PopupMenuItem(
                    value: 'alphabetical',
                    child: Text(t(context, 'sort by name')),
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

            if (_sortBy == 'upcoming') {
              birthdays.sort(
                (a, b) => daysUntilNextBirthday(
                  a.birthdayDate,
                ).compareTo(daysUntilNextBirthday(b.birthdayDate)),
              );
            } else if (_sortBy == 'alphabetical') {
              birthdays.sort(
                (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
              );
            }

            if (birthdays.isEmpty) {
              return Center(
                child: Text(
                  t(context, "no birthday added"),
                  style: textTheme.bodyLarge,
                ),
              );
            }

            return ListView.builder(
              itemCount: birthdays.length,
              itemBuilder: (context, index) {
                final birthday = birthdays[index];
                int daysLeft = daysUntilNextBirthday(birthday.birthdayDate) + 1;

                String dateText = t(context, "birthday on")
                    .replaceAll("{day}", birthday.birthdayDate.day.toString())
                    .replaceAll(
                      "{month}",
                      birthday.birthdayDate.month.toString(),
                    );

                String countdownText =
                    daysLeft == 1
                        ? t(context, "tomorrow capital")
                        : t(
                          context,
                          "in days",
                        ).replaceAll("{days}", daysLeft.toString());

                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  margin: EdgeInsets.symmetric(vertical: 8),
                  elevation: 2,
                  color: theme.cardColor,
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 12,
                    ),
                    leading:
                        birthday.imagePath != null
                            ? ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child: Image.file(
                                File(birthday.imagePath!),
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              ),
                            )
                            : Icon(
                              Icons.cake,
                              color: theme.colorScheme.secondary,
                              size: 30,
                            ),
                    title: Text(birthday.name, style: textTheme.titleLarge),
                    subtitle: Text(
                      "$dateText - $countdownText",
                      style: textTheme.bodyMedium?.copyWith(
                        color: theme.textTheme.bodyMedium?.color?.withOpacity(
                          0.7,
                        ),
                      ),
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: theme.iconTheme.color?.withOpacity(0.7),
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
