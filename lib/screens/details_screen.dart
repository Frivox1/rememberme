import 'package:flutter/material.dart';
import 'package:rememberme/models/birthday_model.dart';
import 'package:provider/provider.dart';
import 'package:rememberme/providers/birthday_provider.dart';

class BirthdayDetailsScreen extends StatelessWidget {
  final Birthday birthday;

  BirthdayDetailsScreen({required this.birthday});

  String formatFrenchDate(DateTime date) {
    const List<String> months = [
      "janvier",
      "février",
      "mars",
      "avril",
      "mai",
      "juin",
      "juillet",
      "août",
      "septembre",
      "octobre",
      "novembre",
      "décembre",
    ];

    return "${date.day} ${months[date.month - 1]} ${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final int age = DateTime.now().year - birthday.birthdayDate.year;

    final DateTime nextBirthday =
        DateTime(
              DateTime.now().year,
              birthday.birthdayDate.month,
              birthday.birthdayDate.day,
            ).isBefore(DateTime.now())
            ? DateTime(
              DateTime.now().year + 1,
              birthday.birthdayDate.month,
              birthday.birthdayDate.day,
            )
            : DateTime(
              DateTime.now().year,
              birthday.birthdayDate.month,
              birthday.birthdayDate.day,
            );
    final int daysUntilNextBirthday =
        nextBirthday.difference(DateTime.now()).inDays + 1;

    final String formattedBirthday = formatFrenchDate(birthday.birthdayDate);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "Détails de l'Anniversaire",
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
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 40),
            Center(
              child: Text(birthday.name, style: theme.textTheme.headlineMedium),
            ),
            SizedBox(height: 10),
            Center(
              child: Text(formattedBirthday, style: theme.textTheme.titleLarge),
            ),
            SizedBox(height: 10),
            Center(
              child: Text(
                daysUntilNextBirthday == 365
                    ? "$age ans aujourd'hui !"
                    : daysUntilNextBirthday == 1
                    ? '$age ans demain'
                    : '$age ans dans $daysUntilNextBirthday jours',
                style: theme.textTheme.bodyLarge,
              ),
            ),
            SizedBox(height: 40),
            Text("Idées cadeaux :", style: theme.textTheme.titleLarge),
            SizedBox(height: 10),
            if (birthday.giftIdeas != null && birthday.giftIdeas!.isNotEmpty)
              ...birthday.giftIdeas!.map(
                (idea) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.circle_outlined,
                        color: theme.iconTheme.color,
                        size: 16,
                      ),
                      SizedBox(width: 12),
                      Text(idea, style: theme.textTheme.bodyLarge),
                    ],
                  ),
                ),
              )
            else
              Text("Pas d'idées cadeaux.", style: theme.textTheme.bodyLarge),
            Spacer(),
            Center(
              child: FractionallySizedBox(
                widthFactor: 0.8,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () async {
                    final provider = Provider.of<BirthdayProvider>(
                      context,
                      listen: false,
                    );

                    await provider.deleteBirthday(birthday.id);

                    Navigator.pop(context);
                  },
                  child: Text(
                    "Supprimer",
                    style: TextStyle(
                      color: theme.colorScheme.onPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
