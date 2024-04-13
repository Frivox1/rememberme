import 'package:hive/hive.dart';

part 'birthday_model.g.dart';

@HiveType(typeId: 0)
class Birthday extends HiveObject {
  @HiveField(0)
  late String name;

  @HiveField(1)
  late DateTime birthday;

  @HiveField(2)
  late String giftIdeas;

  Birthday({
    required this.name,
    required this.birthday,
    required this.giftIdeas,
  });
}
