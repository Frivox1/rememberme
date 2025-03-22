import 'package:flutter/material.dart';
import 'package:rememberme/models/birthday_model.dart';
import 'package:rememberme/screens/home_screen.dart';
import 'package:rememberme/screens/welcome_screen.dart';
import 'package:rememberme/services/hive_service.dart';
import 'package:rememberme/providers/birthday_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialisation de Hive
  await Hive.initFlutter();
  Hive.registerAdapter(BirthdayAdapter()); // Enregistre l'adaptateur Birthday

  // Vérifie si la boîte est ouverte au démarrage
  bool isBoxOpen = await HiveService.isBirthdayBoxOpen();
  if (!isBoxOpen) {
    await HiveService.openBirthdayBox(); // Assure-toi que la boîte est ouverte
  }

  bool isFirstTime = await checkFirstTime();

  runApp(MyApp(isFirstTime: isFirstTime));
}

// Fonction qui vérifie si c'est la première fois que l'utilisateur lance l'application
Future<bool> checkFirstTime() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isFirstTime = prefs.getBool('isFirstTime') ?? true;

  if (isFirstTime) {
    // Si c'est la première fois, on marque dans les SharedPreferences
    await prefs.setBool('isFirstTime', false);
  }

  return isFirstTime;
}

class MyApp extends StatelessWidget {
  final bool isFirstTime;

  MyApp({required this.isFirstTime});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BirthdayProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'RememberMe',
        home: isFirstTime ? WelcomeScreen() : HomeScreen(),
      ),
    );
  }
}
