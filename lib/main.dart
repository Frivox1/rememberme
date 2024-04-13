import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:rememberme/models/birthday_model.dart';
import 'package:rememberme/screens/add_annif.dart';
import 'package:rememberme/screens/list_screen.dart';

void main() async {
  // Initialisation de Hive
  WidgetsFlutterBinding.ensureInitialized();
  final appDocumentDirectory =
      await path_provider.getApplicationDocumentsDirectory();
  Hive.init(appDocumentDirectory.path);
  Hive.registerAdapter(BirthdayAdapter());

  // Ouvrir la boîte Hive
  await Hive.openBox<Birthday>('birthdays');

  // Ajouter un rappel pour fermer les boîtes Hive lorsque l'application se ferme
  WidgetsBinding.instance.addPostFrameCallback((_) => closeHiveBoxes());

  runApp(const MyApp());
}

// Fonction pour fermer toutes les boîtes Hive ouvertes
Future<void> closeHiveBoxes() async {
  await Hive.close();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Birthday Reminder',
      theme: ThemeData(
        primarySwatch: Colors.pink,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/list',
      routes: {
        '/list': (context) => const ListScreen(),
        '/add': (context) => const AddAnnifScreen(),
      },
    );
  }
}
