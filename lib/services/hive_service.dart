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
  static Future<List<Birthday>> getBirthdays() async {
    var box = await openBirthdayBox();
    return box.values.toList();
  }

  // Supprimer un anniversaire
  static Future<void> deleteBirthday(int index) async {
    var box = await openBirthdayBox();
    await box.deleteAt(index);
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
