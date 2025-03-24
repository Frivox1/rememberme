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

  // Supprimer un anniversaire en utilisant l'ID
  Future<void> deleteBirthday(String id) async {
    await HiveService.deleteBirthdayById(id); // Supprimer via l'ID
    await loadBirthdays(); // Recharger les anniversaires après suppression
  }

  // Mettre à jour un anniversaire
  Future<void> updateBirthday(int index, Birthday updatedBirthday) async {
    await HiveService.updateBirthday(index, updatedBirthday);
    await loadBirthdays(); // Recharger les anniversaires après mise à jour
  }

  // Mettre à jour les idées cadeaux d'un anniversaire
  Future<void> updateGiftIdeas(String id, List<String> updatedGiftIdeas) async {
    // On crée une nouvelle instance de Birthday avec les idées cadeaux mises à jour
    final birthdayIndex = _birthdays.indexWhere((b) => b.id == id);
    if (birthdayIndex != -1) {
      var birthday = _birthdays[birthdayIndex];
      var updatedBirthday = Birthday(
        id: birthday.id,
        name: birthday.name,
        birthdayDate: birthday.birthdayDate,
        giftIdeas: updatedGiftIdeas,
        imagePath: birthday.imagePath,
      );

      // Mettez à jour la liste des anniversaires dans Hive
      await HiveService.updateBirthday(birthdayIndex, updatedBirthday);
      await loadBirthdays(); // Recharger les anniversaires après mise à jour des idées cadeaux
    }
  }
}
