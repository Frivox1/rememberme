import 'package:flutter/material.dart';
import 'package:rememberme/models/birthday_model.dart';
import 'package:rememberme/models/reminder_model.dart';
import 'package:rememberme/screens/home_screen.dart';
import 'package:rememberme/screens/welcome_screen.dart';
import 'package:rememberme/providers/birthday_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:rememberme/providers/theme_provider.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialisation de la librairie timezone
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Europe/Paris'));

  // Initialisation de Hive
  await Hive.initFlutter();
  Hive.registerAdapter(BirthdayAdapter());
  Hive.registerAdapter(ReminderAdapter());

  await Hive.openBox<Birthday>('birthdays');
  await Hive.openBox<Reminder>('reminders');

  // Initialisation des notifications locales
  await initNotifications();

  // Vérification si c'est la première fois que l'utilisateur ouvre l'app
  bool isFirstTime = await checkFirstTime();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => BirthdayProvider()),
      ],
      child: MyApp(isFirstTime: isFirstTime),
    ),
  );
}

Future<void> initNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const DarwinInitializationSettings initializationSettingsIOS =
      DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
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
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'RememberMe',
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: themeProvider.themeMode,
          home:
              isFirstTime
                  ? WelcomeScreen(
                    flutterLocalNotificationsPlugin:
                        flutterLocalNotificationsPlugin,
                  )
                  : HomeScreen(
                    flutterLocalNotificationsPlugin:
                        flutterLocalNotificationsPlugin,
                  ),
        );
      },
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
