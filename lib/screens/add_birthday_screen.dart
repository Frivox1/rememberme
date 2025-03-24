import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:path_provider/path_provider.dart';
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
  String? _imagePath; // Stocke le chemin de l'image sélectionnée

  final uuid = Uuid();
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
        compressQuality: 90,
        maxWidth: 800,
        maxHeight: 800,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: "Recadrer l'image",
            toolbarColor: Colors.blue,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
          ),
          IOSUiSettings(title: "Recadrer l'image"),
        ],
      );

      if (croppedFile != null) {
        final directory = await getApplicationDocumentsDirectory();
        final newImagePath = '${directory.path}/${pickedFile.name}';

        final File newImage = await File(croppedFile.path).copy(newImagePath);

        setState(() {
          _imagePath = newImage.path;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 60),
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child:
                      _imagePath == null
                          ? Container(
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
                          )
                          : ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(
                              File(_imagePath!),
                              width: 150,
                              height: 150,
                              fit: BoxFit.cover,
                            ),
                          ),
                ),
              ),
              SizedBox(height: 40),

              // Champ Nom
              TextField(
                controller: _nameController,
                cursorColor: theme.colorScheme.primary,
                decoration: InputDecoration(
                  hintText: 'Nom',
                  filled: true,
                  fillColor: theme.colorScheme.surface,
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
              SizedBox(height: 32),

              // Sélecteur de date
              Text(
                'Date d\'anniversaire',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: theme.colorScheme.primary,
                ),
              ),
              SizedBox(height: 8),
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
              SizedBox(height: 32),

              // Champ Idées cadeaux
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Idées cadeaux',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.add_circle_outline,
                      color: theme.colorScheme.secondary,
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
                                cursorColor: theme.colorScheme.primary,
                                controller: controller,
                                decoration: InputDecoration(
                                  hintText: 'Idée cadeau',
                                  filled: true,
                                  fillColor: theme.colorScheme.surfaceVariant,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: theme.colorScheme.primary,
                                      width: 1,
                                    ),
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
              SizedBox(height: 70),

              // Bouton Enregistrer
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
                      Birthday newBirthday = Birthday(
                        id: uuid.v4(),
                        name: _nameController.text,
                        birthdayDate: _selectedDate,
                        giftIdeas:
                            _giftIdeaControllers
                                .map((controller) => controller.text)
                                .toList(),
                        imagePath: _imagePath,
                      );

                      await Provider.of<BirthdayProvider>(
                        context,
                        listen: false,
                      ).addBirthday(newBirthday);

                      Navigator.of(context).pop();
                    },
                    child: Text(
                      'Enregistrer',
                      style: TextStyle(
                        color: theme.colorScheme.onPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 70),
            ],
          ),
        ),
      ),
    );
  }
}
