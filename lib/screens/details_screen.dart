import 'package:flutter/material.dart';
import 'package:rememberme/models/birthday_model.dart';
import 'package:provider/provider.dart';
import 'package:rememberme/providers/birthday_provider.dart';

class BirthdayDetailsScreen extends StatelessWidget {
  final Birthday birthday;
  final int birthdayIndex;

  BirthdayDetailsScreen({required this.birthday, required this.birthdayIndex});

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
        nextBirthday.difference(DateTime.now()).inDays;

    final String formattedBirthday = formatFrenchDate(birthday.birthdayDate);

    return Scaffold(
      backgroundColor: Color(0xFFFFE5EC),
      appBar: AppBar(
        title: Text(
          "Détails de l'Anniversaire",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 26,
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
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 40),
            Center(
              child: Text(
                birthday.name,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            SizedBox(height: 10),
            Center(
              child: Text(
                formattedBirthday,
                style: TextStyle(fontSize: 20, color: Colors.black87),
              ),
            ),
            SizedBox(height: 10),
            Center(
              child: Text(
                "$age ans dans $daysUntilNextBirthday jours",
                style: TextStyle(fontSize: 18, color: Colors.black87),
              ),
            ),
            SizedBox(height: 40),
            Text(
              "Idées cadeaux :",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 10),
            if (birthday.giftIdeas != null && birthday.giftIdeas!.isNotEmpty)
              ...birthday.giftIdeas!.map(
                (idea) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.circle_outlined,
                        color: Colors.black87,
                        size: 16,
                      ),
                      SizedBox(width: 12),
                      Text(
                        idea,
                        style: TextStyle(fontSize: 18, color: Colors.black87),
                      ),
                    ],
                  ),
                ),
              )
            else
              Text(
                "Pas d'idées cadeaux.",
                style: TextStyle(fontSize: 18, color: Colors.black87),
              ),
            Spacer(),
            Center(
              child: FractionallySizedBox(
                widthFactor: 0.8,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFFF8FAB),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () async {
                    await Provider.of<BirthdayProvider>(
                      context,
                      listen: false,
                    ).deleteBirthday(birthdayIndex);

                    Navigator.pop(context);
                  },
                  child: Text(
                    "Supprimer",
                    style: TextStyle(
                      color: Colors.white,
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
