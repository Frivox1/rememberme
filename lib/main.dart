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
  WidgetsFlutterBinding.ensureInitialized();
  final appDocumentDirectory =
      await path_provider.getApplicationDocumentsDirectory();
  Hive.init(appDocumentDirectory.path);
  Hive.registerAdapter(BirthdayAdapter());
  await Hive.openBox<Birthday>('birthdays');
  tzdata.initializeTimeZones();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('app_icon');
  final IOSInitializationSettings initializationSettingsIOS =
      IOSInitializationSettings(
    requestSoundPermission: true,
    onDidReceiveLocalNotification:
        (int id, String? title, String? body, String? payload) async {},
  );
  final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>()
      ?.requestPermissions(alert: true, badge: true, sound: true);

  WidgetsBinding.instance.addObserver(MyAppLifecycleObserver());
  Workmanager().initialize(callbackDispatcher);
  Workmanager().registerPeriodicTask(
    'birthdayNotificationTask',
    'birthdayNotificationTask',
    frequency: const Duration(days: 1),
    initialDelay: Duration(hours: 24 - DateTime.now().hour + 7, minutes: 30),
  );

  runApp(const MyApp());
}

class MyAppLifecycleObserver extends WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      closeHiveBoxes();
    }
  }

  Future<void> closeHiveBoxes() async {
    await Hive.close();
  }
}

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) {
    _checkForBirthdays();
    return Future.value(true);
  });
}

Future<void> _checkForBirthdays() async {
  final Box<Birthday> box = await Hive.openBox<Birthday>('birthdays');
  final List<Birthday> birthdays = box.values.toList();
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final List<Birthday> todaysBirthdays = birthdays
      .where((birthday) =>
          birthday.birthday.day == today.day &&
          birthday.birthday.month == today.month)
      .toList();
  await _sendNotifications(todaysBirthdays);
}

Future<void> _sendNotifications(List<Birthday> birthdays) async {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  for (final birthday in birthdays) {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails('your channel id', 'your channel name',
            importance: Importance.max, priority: Priority.high);
    const IOSNotificationDetails iosPlatformChannelSpecifics =
        IOSNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iosPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.zonedSchedule(
      birthday.hashCode,
      'Birthday Reminder',
      'It\'s ${birthday.name}\'s birthday today! 🎉',
      _nextInstanceOfSevenThirty(),
      platformChannelSpecifics,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
}

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
