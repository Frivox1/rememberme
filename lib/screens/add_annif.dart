import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rememberme/models/birthday_model.dart';
import 'package:rememberme/widgets/navbar.dart';
import 'package:hive/hive.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:rememberme/providers/premium_provider.dart';

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
              primary: Colors.pink,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != DateTime.now()) {
      final formattedDate = DateFormat('dd/MM/yyyy').format(picked);
      setState(() {
        _birthdayController.text = formattedDate;
      });
    }
  }

  Future<void> _saveBirthday(BuildContext context) async {
    final name = _nameController.text;
    final birthdayText = _birthdayController.text;
    final giftIdeas = _giftIdeasController.text;

    final RegExp dateRegex = RegExp(r'^\d{2}/\d{2}/\d{4}$');
    if (!dateRegex.hasMatch(birthdayText)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.invalidDateFormat,
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.pink[200],
        ),
      );
      return;
    }

    final List<String> dateParts = birthdayText.split('/');
    final formattedDate = DateTime(int.parse(dateParts[2]),
        int.parse(dateParts[1]), int.parse(dateParts[0]));

    final birthdayObject = Birthday(
      name: name,
      birthday: formattedDate,
      giftIdeas: giftIdeas,
    );

    final Box<Birthday> box = await Hive.openBox<Birthday>('birthdays');

    final premiumProvider =
        Provider.of<PremiumProvider>(context, listen: false);
    if (premiumProvider.isPremium || box.length < 15) {
      await box.add(birthdayObject);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.birthdayAddedSuccessfully,
            style: const TextStyle(color: Colors.white, fontSize: 20),
          ),
          backgroundColor: Colors.pink[200],
        ),
      );

      _nameController.clear();
      _birthdayController.clear();
      _giftIdeasController.clear();

      Navigator.pushReplacementNamed(context, '/list');
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(AppLocalizations.of(context)!.upgradeToPremium),
            content: Text(
              AppLocalizations.of(context)!.annif_max,
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  AppLocalizations.of(context)!.cancel,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/settings');
                },
                child: Text(
                  'OK',
                ),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pink[200],
        title: Text(
          AppLocalizations.of(context)!.addBirthday,
          style: const TextStyle(
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
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.name,
                labelStyle: const TextStyle(color: Colors.black),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.pink),
                ),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 35),
            TextFormField(
              controller: _birthdayController,
              onTap: () {
                _selectDate(context);
              },
              readOnly: true,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.birthday,
                labelStyle: const TextStyle(color: Colors.black),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.pink),
                ),
                prefixIcon: Icon(Icons.calendar_today),
              ),
            ),
            const SizedBox(height: 35),
            TextFormField(
              controller: _giftIdeasController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.giftIdeas,
                labelStyle: const TextStyle(color: Colors.black),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.pink),
                ),
                prefixIcon: Icon(Icons.card_giftcard),
              ),
              maxLines: null,
            ),
            const SizedBox(height: 50),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _saveBirthday(context),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.pink[200],
                  textStyle: const TextStyle(
                    fontSize: 24,
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 15,
                    horizontal: 30,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(AppLocalizations.of(context)!.addBirthday),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(),
    );
  }
}
