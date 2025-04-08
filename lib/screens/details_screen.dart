import 'package:flutter/material.dart';
import 'package:rememberme/models/birthday_model.dart';
import 'package:provider/provider.dart';
import 'package:rememberme/providers/birthday_provider.dart';
import 'package:rememberme/services/app_localizations.dart';

class BirthdayDetailsScreen extends StatefulWidget {
  final Birthday birthday;

  const BirthdayDetailsScreen({Key? key, required this.birthday})
    : super(key: key);

  @override
  _BirthdayDetailsScreenState createState() => _BirthdayDetailsScreenState();
}

class _BirthdayDetailsScreenState extends State<BirthdayDetailsScreen> {
  final TextEditingController _giftController = TextEditingController();
  late Birthday _birthday;

  @override
  void initState() {
    super.initState();
    _birthday = widget.birthday.copyWith(); // Copie locale
  }

  String formatDateLocalized(BuildContext context, DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    return t(context, 'formatted date')
        .replaceAll('{day}', date.day.toString())
        .replaceAll('{month}', month)
        .replaceAll('{year}', date.year.toString());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final int age = DateTime.now().year - _birthday.birthdayDate.year;

    final DateTime now = DateTime.now();
    final DateTime nextBirthday = DateTime(
      now.month > _birthday.birthdayDate.month ||
              (now.month == _birthday.birthdayDate.month &&
                  now.day > _birthday.birthdayDate.day)
          ? now.year + 1
          : now.year,
      _birthday.birthdayDate.month,
      _birthday.birthdayDate.day,
    );

    final int daysUntilNextBirthday = nextBirthday.difference(now).inDays + 1;

    final String formattedBirthday = formatDateLocalized(
      context,
      _birthday.birthdayDate,
    );

    String birthdayStatus;
    if (daysUntilNextBirthday == 365 || daysUntilNextBirthday == 366) {
      birthdayStatus = t(
        context,
        'age today',
      ).replaceAll('{age}', age.toString());
    } else if (daysUntilNextBirthday == 1) {
      birthdayStatus = t(
        context,
        'age tomorrow',
      ).replaceAll('{age}', age.toString());
    } else {
      birthdayStatus = t(context, 'age in days')
          .replaceAll('{age}', age.toString())
          .replaceAll('{days}', daysUntilNextBirthday.toString());
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          t(context, "birthday details"),
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
                    (_birthday.imagePath != null &&
                            _birthday.imagePath!.isNotEmpty)
                        ? Image.asset(_birthday.imagePath!).image
                        : null,
                child:
                    (_birthday.imagePath == null ||
                            _birthday.imagePath!.isEmpty)
                        ? Icon(
                          Icons.person,
                          size: 60,
                          color: theme.colorScheme.secondary,
                        )
                        : null,
              ),
            ),
            SizedBox(height: 50),
            Center(
              child: Text(
                _birthday.name,
                style: theme.textTheme.headlineMedium,
              ),
            ),
            SizedBox(height: 25),
            Center(
              child: Text(formattedBirthday, style: theme.textTheme.titleLarge),
            ),
            SizedBox(height: 15),
            Center(
              child: Text(birthdayStatus, style: theme.textTheme.bodyLarge),
            ),
            SizedBox(height: 40),
            Text(t(context, "gift ideas :"), style: theme.textTheme.titleLarge),
            SizedBox(height: 10),
            if (_birthday.giftIdeas != null && _birthday.giftIdeas!.isNotEmpty)
              ..._birthday.giftIdeas!.asMap().entries.map((entry) {
                final index = entry.key;
                final giftIdea = entry.value;
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
                            _birthday.giftIdeas!.removeAt(index);
                          });
                          Provider.of<BirthdayProvider>(
                            context,
                            listen: false,
                          ).updateGiftIdeas(_birthday.id, _birthday.giftIdeas!);
                        },
                      ),
                    ],
                  ),
                );
              }).toList()
            else
              Text(
                t(context, "no gift ideas"),
                style: theme.textTheme.bodyLarge,
              ),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _giftController,
                    decoration: InputDecoration(
                      labelText: t(context, "new gift idea"),
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
                        _birthday.giftIdeas ??= [];
                        _birthday.giftIdeas!.add(newGiftIdea);
                      });
                      Provider.of<BirthdayProvider>(
                        context,
                        listen: false,
                      ).updateGiftIdeas(_birthday.id, _birthday.giftIdeas!);
                      _giftController.clear();
                    }
                  },
                ),
              ],
            ),
            SizedBox(height: 100),
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
                    await provider.deleteBirthday(_birthday.id);
                    Navigator.pop(context);
                  },
                  child: Text(
                    t(context, "delete"),
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
