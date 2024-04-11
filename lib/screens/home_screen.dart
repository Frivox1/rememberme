import 'package:flutter/material.dart';
import 'package:rememberme/widgets/navbar.dart';
import 'package:rememberme/widgets/calendar.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pink[200],
        title: const Text(
          'RememberMe',
          style: TextStyle(
            fontSize: 30,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.settings, color: Colors.white, size: 35),
          onPressed: () {
            // Ajoutez ici la logique pour ouvrir l'écran des réglages
          },
        ),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 20),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Birthday of the Week',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: 5,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.pink[50],
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: ListTile(
                    title: Row(
                      children: [
                        Text(
                          'Nom de la personne $index',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    trailing: Text(
                      '0$index/04/2024',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 20),
            child: Text(
              'Month View',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: MinimalCalendar(
                events: {}), // Remplacez les données factices par les vraies données
          ),
          SizedBox(height: 20),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(),
    );
  }
}
