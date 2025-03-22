import 'package:hive_ce/hive.dart';

part 'birthday_model.g.dart';

@HiveType(typeId: 0)
class Birthday {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final DateTime birthdayDate;

  @HiveField(2)
  final List<String>? giftIdeas;

  Birthday({required this.name, required this.birthdayDate, this.giftIdeas});

  // Ajoute la méthode toString() pour un affichage lisible
  @override
  String toString() {
    return 'Birthday{name: $name, birthdayDate: $birthdayDate, giftIdeas: $giftIdeas}';
  }
}
