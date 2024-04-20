import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:rememberme/models/birthday_model.dart';
import 'package:rememberme/models/app_settings.dart';
import 'package:rememberme/models/language_model.dart';
import 'package:rememberme/models/premium_model.dart';
import 'package:rememberme/providers/langue_provider.dart';
import 'package:rememberme/providers/premium_provider.dart';
import 'package:rememberme/screens/add_annif.dart';
import 'package:rememberme/screens/home_screen.dart';
import 'package:rememberme/screens/list_screen.dart';
import 'package:rememberme/screens/settings.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rememberme/welcome/select_lang.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import 'package:workmanager/workmanager.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:rememberme/l10n/l10n.dart';

// Déclaration globale de periodicTaskDelayInMinutes
int periodicTaskDelayInMinutes = 0;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialise Hive
  await Hive.initFlutter();

  Hive.registerAdapter(BirthdayAdapter());
  Hive.registerAdapter(AppSettingsAdapter());
  Hive.registerAdapter(LanguageModelAdapter());
  Hive.registerAdapter(PremiumAdapter());

  await Hive.openBox<Birthday>('birthdays');
  await Hive.openBox<AppSettings>('app_settings');
  await Hive.openBox<LanguageModel>('language');
  await Hive.openBox<Premium>('premium');

  tzdata.initializeTimeZones();

  // Initialise les notifications locales
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

  // Initialise l'observateur du cycle de vie de l'application
  WidgetsBinding.instance.addObserver(MyAppLifecycleObserver());

  // Initialise WorkManager pour les tâches périodiques
  periodicTaskDelayInMinutes =
      24 * 60 - DateTime.now().hour * 60 - DateTime.now().minute + 7 * 60 + 30;

  try {
    Workmanager().initialize(callbackDispatcher);
    Workmanager().registerPeriodicTask(
      'birthdayNotificationTask',
      'birthdayNotificationTask',
      frequency: const Duration(days: 1),
      initialDelay: Duration(minutes: periodicTaskDelayInMinutes),
    );
  } catch (e) {
    print('WorkManager not supported on this platform: $e');
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => PremiumProvider()),
        ChangeNotifierProvider(create: (context) => LanguageProvider()),
      ],
      child: const MyApp(),
    ),
  );
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
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Locale>(
      future: getStoredLocale(),
      builder: (context, AsyncSnapshot<Locale> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          final locale = snapshot.data ?? const Locale('en');
          return Directionality(
            textDirection: TextDirection.ltr,
            child: ChangeNotifierProvider<LanguageProvider>(
              create: (_) => LanguageProvider()..setLocale(locale),
              child: ChangeNotifierProvider<PremiumProvider>(
                create: (_) => PremiumProvider(),
                builder: (context, _) {
                  return Consumer<LanguageProvider>(
                    builder: (context, languageProvider, _) {
                      // Récupérer la langue à partir du Provider
                      final providerLocale = languageProvider.locale;

                      // Mettre à jour la locale avec la langue du Provider
                      return MaterialApp(
                        debugShowCheckedModeBanner: false,
                        title: 'RememberMe',
                        theme: ThemeData(
                          primarySwatch: Colors.pink,
                          visualDensity: VisualDensity.adaptivePlatformDensity,
                        ),
                        supportedLocales: L10n.all,
                        locale: providerLocale,
                        localizationsDelegates: const [
                          AppLocalizations.delegate,
                          GlobalMaterialLocalizations.delegate,
                          GlobalWidgetsLocalizations.delegate,
                          GlobalCupertinoLocalizations.delegate,
                        ],
                        home: FutureBuilder(
                          future: Hive.openBox<AppSettings>('app_settings'),
                          builder: (context,
                              AsyncSnapshot<Box<AppSettings>> snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.done) {
                              final box = snapshot.data!;
                              final appSettings = box.get('settings',
                                  defaultValue: AppSettings(isFirstTime: true));
                              if (appSettings!.isFirstTime) {
                                return SelectLang();
                              } else {
                                return HomeScreen();
                              }
                            } else {
                              return Scaffold(
                                body: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }
                          },
                        ),
                        routes: {
                          '/home': (context) => const HomeScreen(),
                          '/list': (context) => const ListScreen(),
                          '/add': (context) => const AddAnnifScreen(),
                          '/settings': (context) => const SettingsScreen(),
                        },
                      );
                    },
                  );
                },
              ),
            ),
          );
        } else {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }

  // Fonction pour récupérer la locale stockée dans la boîte de données 'language'
  Future<Locale> getStoredLocale() async {
    final languageBox = Hive.box<LanguageModel>('language');
    final languageModel =
        languageBox.get('locale', defaultValue: LanguageModel(locale: 'en'));
    return Locale(languageModel!.locale);
  }
}
