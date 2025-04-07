import 'package:hive_ce/hive.dart';

part 'birthday_model.g.dart';

@HiveType(typeId: 0)
class Birthday {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final DateTime birthdayDate;

  @HiveField(3)
  List<String>? giftIdeas;

  @HiveField(4)
  final String? imagePath;

  Birthday({
    required this.id,
    required this.name,
    required this.birthdayDate,
    this.giftIdeas,
    this.imagePath,
  });

  Birthday copyWith({
    String? id,
    String? name,
    DateTime? birthdayDate,
    List<String>? giftIdeas,
    String? imagePath,
  }) {
    return Birthday(
      id: id ?? this.id,
      name: name ?? this.name,
      birthdayDate: birthdayDate ?? this.birthdayDate,
      giftIdeas: giftIdeas ?? List<String>.from(this.giftIdeas ?? []),
      imagePath: imagePath ?? this.imagePath,
    );
  }
}
