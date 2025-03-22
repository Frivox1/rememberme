import 'package:flutter/material.dart';
import 'package:rememberme/models/birthday_model.dart';
import 'package:rememberme/services/hive_service.dart';
import 'add_birthday_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Birthday> birthdays = [];

  @override
  void initState() {
    super.initState();
    _loadBirthdays();
  }

  // Fonction pour charger les anniversaires depuis Hive
  Future<void> _loadBirthdays() async {
    List<Birthday> loadedBirthdays = await HiveService.getBirthdays();
    setState(() {
      birthdays = loadedBirthdays;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('RememberMe'),
        actions: [
          IconButton(
            icon: Icon(Icons.add_circle_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddBirthdayScreen()),
              ).then((_) {
                // Recharger les anniversaires après ajout
                _loadBirthdays();
              });
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
                style: TextStyle(fontSize: 24, color: Colors.white),
              ),
              decoration: BoxDecoration(color: Colors.pinkAccent),
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
            // Ajoute d'autres éléments de menu ici si nécessaire
          ],
        ),
      ),
      body:
          birthdays.isEmpty
              ? Center(
                child: Text(
                  'Aucun anniversaire enregistré.',
                  style: TextStyle(fontSize: 24),
                ),
              )
              : ListView.builder(
                itemCount: birthdays.length,
                itemBuilder: (context, index) {
                  final birthday = birthdays[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: ListTile(
                      contentPadding: EdgeInsets.all(16),
                      title: Text(
                        birthday.name,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Anniversaire: ${birthday.birthdayDate.toLocal().toString().split(' ')[0]}',
                            style: TextStyle(fontSize: 16),
                          ),
                          SizedBox(height: 8),
                          if (birthday.giftIdeas != null &&
                              (birthday.giftIdeas?.isNotEmpty ?? false))
                            Text(
                              'Idées cadeaux: ${birthday.giftIdeas?.join(", ")}',
                              style: TextStyle(fontSize: 16),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
