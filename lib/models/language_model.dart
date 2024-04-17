import 'package:hive/hive.dart';

part 'language_model.g.dart';

@HiveType(typeId: 2)
class LanguageModel {
  @HiveField(0)
  late String locale;

  LanguageModel({required this.locale});
}
