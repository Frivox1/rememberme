import 'package:flutter/material.dart';
import 'package:rememberme/models/birthday_model.dart';
import 'package:provider/provider.dart';
import 'package:rememberme/providers/birthday_provider.dart';

class BirthdayDetailsScreen extends StatefulWidget {
  final Birthday birthday;

  const BirthdayDetailsScreen({Key? key, required this.birthday})
    : super(key: key);

  @override
  _BirthdayDetailsScreenState createState() => _BirthdayDetailsScreenState();
}

class _BirthdayDetailsScreenState extends State<BirthdayDetailsScreen> {
  final TextEditingController _giftController = TextEditingController();

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
    final int age = DateTime.now().year - widget.birthday.birthdayDate.year;

    final DateTime nextBirthday =
        DateTime(
              DateTime.now().year,
              widget.birthday.birthdayDate.month,
              widget.birthday.birthdayDate.day,
            ).isBefore(DateTime.now())
            ? DateTime(
              DateTime.now().year + 1,
              widget.birthday.birthdayDate.month,
              widget.birthday.birthdayDate.day,
            )
            : DateTime(
              DateTime.now().year,
              widget.birthday.birthdayDate.month,
              widget.birthday.birthdayDate.day,
            );
    final int daysUntilNextBirthday =
        nextBirthday.difference(DateTime.now()).inDays + 1;

    final String formattedBirthday = formatFrenchDate(
      widget.birthday.birthdayDate,
    );

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),

            Center(
              child: CircleAvatar(
                radius: 80,
                backgroundColor: theme.colorScheme.secondary.withOpacity(0.2),
                backgroundImage:
                    (widget.birthday.imagePath != null &&
                            widget.birthday.imagePath!.isNotEmpty)
                        ? Image.asset(widget.birthday.imagePath!).image
                        : null,
                child:
                    (widget.birthday.imagePath == null ||
                            widget.birthday.imagePath!.isEmpty)
                        ? Icon(
                          Icons.person,
                          size: 60,
                          color: theme.colorScheme.secondary,
                        )
                        : null,
              ),
            ),

            SizedBox(height: 20),
            Center(
              child: Text(
                widget.birthday.name,
                style: theme.textTheme.headlineMedium,
              ),
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
            if (widget.birthday.giftIdeas != null &&
                widget.birthday.giftIdeas!.isNotEmpty)
              ...widget.birthday.giftIdeas!.map((giftIdea) {
                final index = widget.birthday.giftIdeas!.indexOf(giftIdea);
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.circle_outlined,
                        color: theme.colorScheme.primary,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(giftIdea, style: theme.textTheme.bodyLarge),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.remove_circle,
                          color: theme.colorScheme.primary,
                        ),
                        onPressed: () {
                          setState(() {
                            widget.birthday.giftIdeas!.removeAt(index);
                          });
                          final provider = Provider.of<BirthdayProvider>(
                            context,
                            listen: false,
                          );
                          provider.updateGiftIdeas(
                            widget.birthday.id,
                            widget.birthday.giftIdeas!,
                          );
                        },
                      ),
                    ],
                  ),
                );
              }).toList()
            else
              Text("Pas d'idées cadeaux.", style: theme.textTheme.bodyLarge),

            SizedBox(height: 20),

            // Ajouter une nouvelle idée cadeau avec "+" à côté
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _giftController,
                    decoration: InputDecoration(
                      labelText: 'Nouvelle idée cadeau',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add, color: theme.colorScheme.primary),
                  onPressed: () {
                    final newGiftIdea = _giftController.text;
                    if (newGiftIdea.isNotEmpty) {
                      setState(() {
                        widget.birthday.giftIdeas!.add(newGiftIdea);
                      });
                      final provider = Provider.of<BirthdayProvider>(
                        context,
                        listen: false,
                      );
                      provider.updateGiftIdeas(
                        widget.birthday.id,
                        widget.birthday.giftIdeas!,
                      );
                      _giftController.clear();
                    }
                  },
                ),
              ],
            ),

            SizedBox(height: 40),

            // Bouton Supprimer
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

                    await provider.deleteBirthday(widget.birthday.id);

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
