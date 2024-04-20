import 'package:hive/hive.dart';

part 'premium_model.g.dart';

@HiveType(typeId: 3)
class Premium extends HiveObject {
  @HiveField(0)
  bool ispremium;

  Premium({this.ispremium = false});
}
