import 'package:flutter/material.dart';

class PremiumProvider extends ChangeNotifier {
  bool _isPremium = false;

  bool get isPremium => _isPremium;

  void setPremium(bool value) {
    _isPremium = value;
    notifyListeners();
  }
}
