import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:rememberme/models/birthday_model.dart';
import 'package:rememberme/screens/add_annif.dart';
import 'package:rememberme/screens/home_screen.dart';
import 'package:rememberme/screens/list_screen.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import 'package:workmanager/workmanager.dart';

void main() async {
  // Initialisation de Hive
  WidgetsFlutterBinding.ensureInitialized();
  final appDocumentDirectory =
      await path_provider.getApplicationDocumentsDirectory();
  Hive.init(appDocumentDirectory.path);
  Hive.registerAdapter(BirthdayAdapter());

  // Ouvrir la boîte Hive
  await Hive.openBox<Birthday>('birthdays');

  // Initialisation de la bibliothèque timezone
  tzdata.initializeTimeZones();

  // Initialisation du plugin de notifications
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('app_icon');
  final IOSInitializationSettings initializationSettingsIOS =
      IOSInitializationSettings(
          requestSoundPermission: true,
          onDidReceiveLocalNotification:
              (int id, String? title, String? body, String? payload) async {});
  final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  // Demander l'autorisation des notifications au démarrage de l'application
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>()
      ?.requestPermissions(alert: true, badge: true, sound: true);

  // Ajouter un rappel pour fermer les boîtes Hive lorsque l'application se ferme
  WidgetsBinding.instance.addPostFrameCallback((_) => closeHiveBoxes());

  // Initialiser WorkManager
  Workmanager().initialize(callbackDispatcher);

  // Enregistrer la tâche pour exécution quotidienne à 7h30 du matin
  Workmanager().registerPeriodicTask(
    'birthdayNotificationTask',
    'birthdayNotificationTask',
    frequency: const Duration(days: 1),
    initialDelay: Duration(hours: 24 - DateTime.now().hour + 7, minutes: 30),
  );

  runApp(const MyApp());
}

// Fonction pour fermer toutes les boîtes Hive ouvertes
Future<void> closeHiveBoxes() async {
  await Hive.close();
}

// Fonction de rappel pour WorkManager
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) {
    // Vérifier les anniversaires et envoyer des notifications
    _checkForBirthdays();

    return Future.value(true);
  });
}

// Fonction pour vérifier les anniversaires et envoyer des notifications
Future<void> _checkForBirthdays() async {
  // Récupérer la liste des anniversaires dans la boîte Hive
  final Box<Birthday> box = await Hive.openBox<Birthday>('birthdays');
  final List<Birthday> birthdays = box.values.toList();

  // Récupérer la date d'aujourd'hui
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  // Filtrer les anniversaires pour ceux qui ont lieu aujourd'hui
  final List<Birthday> todaysBirthdays = birthdays
      .where((birthday) =>
          birthday.birthday.day == today.day &&
          birthday.birthday.month == today.month)
      .toList();

  // Envoyer des notifications pour les anniversaires d'aujourd'hui
  await _sendNotifications(todaysBirthdays);
}

// Fonction pour envoyer des notifications pour les anniversaires
Future<void> _sendNotifications(List<Birthday> birthdays) async {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  for (final birthday in birthdays) {
    // Configuration de la notification pour Android
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails('your channel id', 'your channel name',
            importance: Importance.max, priority: Priority.high);

    // Configuration de la notification pour iOS
    const IOSNotificationDetails iosPlatformChannelSpecifics =
        IOSNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    // Configuration générale de la notification
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iosPlatformChannelSpecifics);

    // Planification de la notification pour 7h30 du matin
    await flutterLocalNotificationsPlugin.zonedSchedule(
      birthday.hashCode, // Id de la notification
      'Birthday Reminder',
      'It\'s ${birthday.name}\'s birthday today! 🎉', // Corps de la notification
      _nextInstanceOfSevenThirty(), // Date et heure de déclenchement
      platformChannelSpecifics, // Configuration de la notification
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
}

// Fonction pour obtenir la prochaine occurrence de 7h30 du matin
tz.TZDateTime _nextInstanceOfSevenThirty() {
  final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
  tz.TZDateTime scheduledDate =
      tz.TZDateTime(tz.local, now.year, now.month, now.day, 7, 30);

  if (scheduledDate.isBefore(now)) {
    scheduledDate = scheduledDate.add(const Duration(days: 1));
  }

  return scheduledDate;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'RememberMe',
      theme: ThemeData(
        primarySwatch: Colors.pink,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/home',
      routes: {
        '/home': (context) => const HomeScreen(),
        '/list': (context) => const ListScreen(),
        '/add': (context) => const AddAnnifScreen(),
      },
    );
  }
}
