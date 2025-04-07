import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:rememberme/providers/language_provider.dart';

String t(BuildContext context, String key) {
  return Provider.of<LanguageProvider>(context, listen: false).translate(key);
}
