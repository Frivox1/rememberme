import 'package:flutter/material.dart';
import 'package:rememberme/models/birthday_model.dart';
import 'package:rememberme/services/hive_service.dart';

class BirthdayProvider with ChangeNotifier {
  List<Birthday> _birthdays = [];

  List<Birthday> get birthdays => _birthdays;

  // Charger les anniversaires depuis Hive
  Future<void> loadBirthdays() async {
    _birthdays = await HiveService.getAllBirthdays();
    notifyListeners(); // Notifier les widgets qui écoutent ce provider
  }

  // Ajouter un anniversaire
  Future<void> addBirthday(Birthday birthday) async {
    await HiveService.addBirthday(birthday);
    await loadBirthdays(); // Recharger les anniversaires après ajout
  }

  // Supprimer un anniversaire
  Future<void> deleteBirthday(int index) async {
    await HiveService.deleteBirthday(index);
    await loadBirthdays(); // Recharger les anniversaires après suppression
  }

  // Mettre à jour un anniversaire
  Future<void> updateBirthday(int index, Birthday updatedBirthday) async {
    await HiveService.updateBirthday(index, updatedBirthday);
    await loadBirthdays(); // Recharger les anniversaires après mise à jour
  }
}
