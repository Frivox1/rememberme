import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Importation de la classe DateFormat
import 'package:rememberme/widgets/navbar.dart';

class AddAnnifScreen extends StatefulWidget {
  const AddAnnifScreen({
    super.key,
  });

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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.pink, // Change the primary color
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != DateTime.now()) {
      // Formatage de la date sélectionnée
      final formattedDate = DateFormat('dd/MM/yyyy').format(picked);
      setState(() {
        _birthdayController.text = formattedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pink[200],
        title: const Text(
          'Add Birthday',
          style: TextStyle(
            fontSize: 30,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: ListView(
          children: [
            const SizedBox(height: 35),
            // Champ de saisie pour le nom
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                labelStyle: TextStyle(color: Colors.pink),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.pink),
                ),
              ),
            ),
            const SizedBox(height: 35),
            // Champ de saisie pour la date d'anniversaire
            TextFormField(
              controller: _birthdayController,
              onTap: () {
                _selectDate(context);
              },
              readOnly: true, // Le champ de saisie est désactivé
              decoration: const InputDecoration(
                labelText: 'Birthday',
                labelStyle: TextStyle(
                    color: Colors.pink), // Couleur du texte du libellé
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.pink),
                ),
              ),
            ),
            const SizedBox(height: 35),
            // Champ de saisie pour les idées cadeaux
            TextFormField(
              controller: _giftIdeasController,
              decoration: const InputDecoration(
                labelText: 'Gift Ideas',
                labelStyle: TextStyle(
                    color: Colors.pink), // Couleur du texte du libellé
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.pink),
                ),
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
      bottomNavigationBar: const CustomBottomNavBar(),
    );
  }
}
