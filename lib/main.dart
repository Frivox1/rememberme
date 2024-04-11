import 'package:flutter/material.dart';
import 'package:rememberme/screens/add_annif.dart';
import 'package:rememberme/screens/home_screen.dart';
import 'package:rememberme/screens/list_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RememberMe',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.pink,
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          selectedItemColor: Colors.white,
        ),
      ),
      initialRoute: '/home',
      routes: {
        '/home': (context) => HomeScreen(),
        '/list': (context) => ListScreen(),
        '/add': (context) => AddAnnifScreen(),
      },
    );
  }
}
