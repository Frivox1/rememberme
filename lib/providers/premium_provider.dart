import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:rememberme/models/premium_model.dart';

class PremiumProvider extends ChangeNotifier {
  late Box<Premium> _premiumBox;
  bool _isPremium = false;

  PremiumProvider() {
    _init();
  }

  Future<void> _init() async {
    _premiumBox = await Hive.openBox<Premium>('premium');
    _isPremium = _premiumBox
        .get('status', defaultValue: Premium(ispremium: false))!
        .ispremium;
    notifyListeners();
  }

  bool get isPremium => _isPremium;

  void setPremium(bool value) {
    _isPremium = value;
    _premiumBox.put('status', Premium(ispremium: value));
    notifyListeners();
  }
}
