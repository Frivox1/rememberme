import 'package:hive_ce/hive.dart';
import 'package:rememberme/models/birthday_model.dart';
import 'package:rememberme/models/reminder_model.dart';

class HiveService {
  static const String birthdayBoxName = 'birthdays';
  static const String reminderBoxName = 'reminders';

  static Box<Birthday> get birthdaysBox => Hive.box<Birthday>(birthdayBoxName);
  static Box<Reminder> get remindersBox => Hive.box<Reminder>(reminderBoxName);

  // Ajouter un anniversaire
  static Future<void> addBirthday(Birthday birthday) async {
    await birthdaysBox.add(birthday);
  }

  // Lire tous les anniversaires
  static List<Birthday> getAllBirthdays() {
    return birthdaysBox.values.toList();
  }

  // Supprimer un anniversaire par son ID
  static Future<void> deleteBirthdayById(String id) async {
    final keyToDelete = birthdaysBox.keys.firstWhere(
      (key) => birthdaysBox.get(key)!.id == id,
      orElse: () => null,
    );

    if (keyToDelete != null) {
      await birthdaysBox.delete(keyToDelete);
    }
  }

  // Mettre à jour un anniversaire
  static Future<void> updateBirthday(
    int index,
    Birthday updatedBirthday,
  ) async {
    await birthdaysBox.putAt(index, updatedBirthday);
  }

  // Mettre à jour les idées cadeaux d'un anniversaire
  static Future<void> updateGiftIdeas(
    String id,
    List<String> updatedGiftIdeas,
  ) async {
    final index = birthdaysBox.values.toList().indexWhere((b) => b.id == id);
    if (index != -1) {
      var birthday = birthdaysBox.getAt(index) as Birthday;
      birthday.giftIdeas = updatedGiftIdeas;
      await birthdaysBox.putAt(index, birthday);
    }
  }

  // Ajouter un rappel
  static Future<void> addReminder(Reminder reminder) async {
    await remindersBox.add(reminder);
  }

  // Supprimer un rappel
  static Future<void> deleteReminder(int index) async {
    await remindersBox.deleteAt(index);
  }

  // Obtenir tous les rappels
  static List<Reminder> getReminders() {
    return remindersBox.values.toList();
  }
}
