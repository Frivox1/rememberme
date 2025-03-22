import 'package:flutter/material.dart';
import 'package:rememberme/models/birthday_model.dart';
import 'package:provider/provider.dart';
import 'package:rememberme/providers/birthday_provider.dart';
import 'details_screen.dart';

class BirthdaysListScreen extends StatefulWidget {
  @override
  _BirthdaysListScreenState createState() => _BirthdaysListScreenState();
}

class _BirthdaysListScreenState extends State<BirthdaysListScreen> {
  @override
  void initState() {
    super.initState();
    // Charger les anniversaires à partir du provider
    Future.delayed(Duration.zero, () {
      Provider.of<BirthdayProvider>(context, listen: false).loadBirthdays();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFE5EC),
      appBar: AppBar(
        title: Text(
          "Liste des Anniversaires",
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
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Consumer<BirthdayProvider>(
          builder: (context, birthdayProvider, child) {
            // Récupère la liste des anniversaires depuis le provider
            List<Birthday> birthdays = birthdayProvider.birthdays;

            if (birthdays.isEmpty) {
              return Center(
                child: Text(
                  "Pas encore d'anniversaire ajouté",
                  style: TextStyle(fontSize: 16),
                ),
              );
            }

            return ListView.builder(
              itemCount: birthdays.length,
              itemBuilder: (context, index) {
                final birthday = birthdays[index];

                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  margin: EdgeInsets.symmetric(vertical: 8),
                  elevation: 2,
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 12,
                    ),
                    leading: Icon(
                      Icons.cake,
                      color: Colors.pinkAccent,
                      size: 30,
                    ),
                    title: Text(
                      birthday.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    subtitle: Text(
                      'Anniversaire le : ${birthday.birthdayDate.day}/${birthday.birthdayDate.month}',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => BirthdayDetailsScreen(
                                birthday: birthday,
                                birthdayIndex: index,
                              ),
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
