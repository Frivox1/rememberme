import 'package:hive_ce/hive.dart';
import 'package:rememberme/models/birthday_model.dart';

class HiveService {
  // Ouvre la boîte (base de données locale) pour stocker les anniversaires
  static Future<Box<Birthday>> openBirthdayBox() async {
    return await Hive.openBox<Birthday>('birthdays');
  }

  // Ajouter un anniversaire
  static Future<void> addBirthday(Birthday birthday) async {
    var box = await openBirthdayBox();
    await box.add(birthday);
  }

  // Lire tous les anniversaires
  static Future<List<Birthday>> getAllBirthdays() async {
    var box = await openBirthdayBox();
    return box.values.toList();
  }

  // Supprimer un anniversaire par son ID
  static Future<void> deleteBirthdayById(String id) async {
    var box = await openBirthdayBox();
    // Recherche de l'anniversaire à supprimer en utilisant son ID
    final birthdayIndex = box.values.toList().indexWhere((b) => b.id == id);
    if (birthdayIndex != -1) {
      await box.deleteAt(birthdayIndex); // Suppression de l'élément
    }
  }

  // Mettre à jour un anniversaire
  static Future<void> updateBirthday(
    int index,
    Birthday updatedBirthday,
  ) async {
    var box = await openBirthdayBox();
    await box.putAt(index, updatedBirthday);
  }

  // Vérifier si la boîte est ouverte (facultatif, utile pour le debug)
  static Future<bool> isBirthdayBoxOpen() async {
    var box = await openBirthdayBox();
    return box.isOpen;
  }
}
