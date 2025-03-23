import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rememberme/models/birthday_model.dart';
import 'package:rememberme/providers/birthday_provider.dart';
import 'package:uuid/uuid.dart';

class AddBirthdayScreen extends StatefulWidget {
  @override
  _AddBirthdayScreenState createState() => _AddBirthdayScreenState();
}

class _AddBirthdayScreenState extends State<AddBirthdayScreen> {
  TextEditingController _nameController = TextEditingController();
  DateTime _selectedDate = DateTime(2000, 1, 1);
  List<TextEditingController> _giftIdeaControllers = [];

  // Instancier le générateur UUID
  final uuid = Uuid();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFE5EC),
      appBar: AppBar(
        backgroundColor: Color(0xFFFF8FAB),
        elevation: 0,
        title: Text(
          'Ajouter un anniversaire',
          style: TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 32),
                // Champ pour le nom
                TextField(
                  controller: _nameController,
                  cursorColor: Color(0xFFFB6F92),
                  decoration: InputDecoration(
                    hintText: 'Nom',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: Color(0xFFFF8FAB),
                        width: 1,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: Color(0xFFFF8FAB),
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: Color(0xFFFB6F92),
                        width: 2,
                      ),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
                SizedBox(height: 16),
                // Sélecteur de date d'anniversaire
                Text(
                  'Date d\'anniversaire',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Color(0xFFFF8FAB),
                  ),
                ),
                SizedBox(
                  height: 200,
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.date,
                    initialDateTime: _selectedDate,
                    onDateTimeChanged: (DateTime newDate) {
                      setState(() {
                        _selectedDate = newDate;
                      });
                    },
                  ),
                ),
                SizedBox(height: 16),
                // Champ Idées cadeaux
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Idées cadeaux',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Color(0xFFFF8FAB),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.add_circle_outline,
                        color: Color(0xFFFB6F92),
                      ),
                      onPressed: () {
                        setState(() {
                          _giftIdeaControllers.add(TextEditingController());
                        });
                      },
                    ),
                  ],
                ),
                Column(
                  children:
                      _giftIdeaControllers.map((controller) {
                        int index = _giftIdeaControllers.indexOf(controller);
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  cursorColor: Color(0xFFFB6F92),
                                  controller: controller,
                                  decoration: InputDecoration(
                                    hintText: 'Idée cadeau',
                                    filled: true,
                                    fillColor: Color(0xFFFFC2D1),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                        color: Color(0xFFFF8FAB),
                                        width: 1,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                        color: Color(0xFFFF8FAB),
                                        width: 1,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                        color: Color(0xFFFB6F92),
                                        width: 2,
                                      ),
                                    ),
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.remove_circle,
                                  color: Color(0xFFFF8FAB),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _giftIdeaControllers.removeAt(index);
                                  });
                                },
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                ),
                SizedBox(height: 16),
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
                        // Créer un objet Birthday avec un ID unique
                        Birthday newBirthday = Birthday(
                          id: uuid.v4(), // Générer un ID unique
                          name: _nameController.text,
                          birthdayDate: _selectedDate,
                          giftIdeas:
                              _giftIdeaControllers
                                  .map((controller) => controller.text)
                                  .toList(),
                        );

                        // Ajouter l'anniversaire dans le provider
                        await Provider.of<BirthdayProvider>(
                          context,
                          listen: false,
                        ).addBirthday(newBirthday);

                        // Afficher un message de confirmation ou rediriger
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Anniversaire enregistré !',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                              ),
                            ),
                            backgroundColor: Color(0xFFFF8FAB),
                          ),
                        );

                        // Retourner à l'écran précédent
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        'Enregistrer',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
