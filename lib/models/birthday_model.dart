import 'package:hive_ce/hive.dart';

part 'birthday_model.g.dart'; // Si vous utilisez Hive généré

@HiveType(typeId: 0)
class Birthday {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final DateTime birthdayDate;

  @HiveField(3)
  final List<String>? giftIdeas;

  Birthday({
    required this.id,
    required this.name,
    required this.birthdayDate,
    this.giftIdeas,
  });
}
