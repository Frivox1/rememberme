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
  Hive.registerAdapter(BirthdayAdapter());

  // Vérification et ouverture de la boîte Hive
  bool isBoxOpen = await HiveService.isBirthdayBoxOpen();
  if (!isBoxOpen) {
    await HiveService.openBirthdayBox();
  }

  // Vérification si c'est la première fois que l'utilisateur ouvre l'app
  bool isFirstTime = await checkFirstTime();

  runApp(MyApp(isFirstTime: isFirstTime));
}

// Fonction qui vérifie si l'application est lancée pour la première fois
Future<bool> checkFirstTime() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isFirstTime = prefs.getBool('isFirstTime') ?? true;

  if (isFirstTime) {
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
      child: Builder(
        builder: (context) {
          // Détecte le thème du téléphone (clair ou sombre)
          final Brightness systemBrightness =
              MediaQuery.of(context).platformBrightness;

          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'RememberMe',
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode:
                systemBrightness == Brightness.dark
                    ? ThemeMode.dark
                    : ThemeMode.light,
            home: isFirstTime ? WelcomeScreen() : HomeScreen(),
          );
        },
      ),
    );
  }
}

// Thème Clair
final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: Colors.black,
  scaffoldBackgroundColor: Colors.white,
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.white,
    foregroundColor: Colors.black,
    elevation: 0,
  ),
  textTheme: TextTheme(
    bodyLarge: TextStyle(color: Colors.black),
    bodyMedium: TextStyle(color: Colors.black87),
  ),
  cardColor: Colors.grey[200],
  buttonTheme: ButtonThemeData(
    buttonColor: Colors.black,
    textTheme: ButtonTextTheme.primary,
  ),
  colorScheme: ColorScheme.light(
    primary: Colors.black,
    secondary: Colors.blueAccent,
  ),
);

// Thème Sombre
final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: Colors.white,
  scaffoldBackgroundColor: Colors.black,
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.black,
    foregroundColor: Colors.white,
    elevation: 0,
  ),
  textTheme: TextTheme(
    bodyLarge: TextStyle(color: Colors.white),
    bodyMedium: TextStyle(color: Colors.white70),
  ),
  cardColor: Colors.grey[900],
  buttonTheme: ButtonThemeData(
    buttonColor: Colors.white,
    textTheme: ButtonTextTheme.primary,
  ),
  colorScheme: ColorScheme.dark(
    primary: Colors.white,
    secondary: Colors.redAccent,
  ),
);
