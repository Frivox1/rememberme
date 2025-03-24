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
    final theme = Theme.of(context); // Accéder au thème actuel

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "Ajouter un Anniversaire",
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 32),
                TextField(
                  controller: _nameController,
                  cursorColor:
                      theme
                          .colorScheme
                          .primary, // Utiliser la couleur primaire pour le curseur
                  decoration: InputDecoration(
                    hintText: 'Nom',
                    filled: true,
                    fillColor:
                        theme
                            .colorScheme
                            .surface, // Utiliser la couleur de surface pour le fond du champ
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: theme.colorScheme.primary,
                        width: 1,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: theme.colorScheme.primary,
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color:
                            theme
                                .colorScheme
                                .secondary, // Utiliser la couleur secondaire pour la bordure focus
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
                    color:
                        theme
                            .colorScheme
                            .primary, // Couleur primaire pour le texte
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
                        color:
                            theme
                                .colorScheme
                                .primary, // Couleur primaire pour le texte
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.add_circle_outline,
                        color:
                            theme
                                .colorScheme
                                .secondary, // Couleur secondaire pour l'icône
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
                                  cursorColor:
                                      theme
                                          .colorScheme
                                          .primary, // Couleur du curseur
                                  controller: controller,
                                  decoration: InputDecoration(
                                    hintText: 'Idée cadeau',
                                    filled: true,
                                    fillColor:
                                        theme
                                            .colorScheme
                                            .surfaceVariant, // Surface variant pour le fond
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                        color: theme.colorScheme.primary,
                                        width: 1,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                        color: theme.colorScheme.primary,
                                        width: 1,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                        color: theme.colorScheme.secondary,
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
                                  color: theme.colorScheme.primary,
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
                        backgroundColor:
                            theme
                                .colorScheme
                                .primary, // Couleur primaire pour le bouton
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
                                color:
                                    theme
                                        .colorScheme
                                        .onPrimary, // Texte sur couleur primaire
                                fontSize: 20,
                              ),
                            ),
                            backgroundColor:
                                theme
                                    .colorScheme
                                    .primary, // Couleur de fond du snack bar
                          ),
                        );

                        // Retourner à l'écran précédent
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        'Enregistrer',
                        style: TextStyle(
                          color: theme.colorScheme.onPrimary, // Texte du bouton
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
