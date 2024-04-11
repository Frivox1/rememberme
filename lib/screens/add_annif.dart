import 'package:flutter/material.dart';
import 'package:rememberme/widgets/navbar.dart';

class AddAnnifScreen extends StatefulWidget {
  const AddAnnifScreen({
    Key? key,
  }) : super(key: key);

  @override
  _AddAnnifScreenState createState() => _AddAnnifScreenState();
}

class _AddAnnifScreenState extends State<AddAnnifScreen> {
  late TextEditingController _nameController;
  late TextEditingController _birthdayController;
  late TextEditingController _giftIdeasController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _birthdayController = TextEditingController();
    _giftIdeasController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _birthdayController.dispose();
    _giftIdeasController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Birthday'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: [
            SizedBox(height: 20),
            // Bouton pour choisir la photo de profil
            InkWell(
              onTap: () {
                // Logique pour choisir la photo de profil
              },
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.camera_alt,
                  size: 50,
                  color: Colors.grey[600],
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Champ de saisie pour le nom
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
              ),
            ),
            const SizedBox(height: 20),
            // Champ de saisie pour la date d'anniversaire
            TextFormField(
              controller: _birthdayController,
              decoration: const InputDecoration(
                labelText: 'Birthday',
              ),
            ),
            const SizedBox(height: 20),
            // Champ de saisie pour les idées cadeaux
            TextFormField(
              controller: _giftIdeasController,
              decoration: const InputDecoration(
                labelText: 'Gift Ideas',
              ),
              maxLines: null, // Permet plusieurs lignes de texte
            ),
            const SizedBox(height: 50),
            // Bouton pour ajouter l'anniversaire
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Logique pour ajouter l'anniversaire
                  String name = _nameController.text;
                  String birthday = _birthdayController.text;
                  String giftIdeas = _giftIdeasController.text;

                  // Utiliser les données saisies
                  print(
                      'Name: $name, Birthday: $birthday, Gift Ideas: $giftIdeas');
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.pink, // Text color
                  textStyle: const TextStyle(
                    fontSize: 24,
                  ), // Button color
                  padding: const EdgeInsets.symmetric(
                    vertical: 15,
                    horizontal: 30,
                  ), // Padding
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10), // Rounded corners
                  ),
                ),
                child: const Text('Add Birthday'),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(),
    );
  }
}
