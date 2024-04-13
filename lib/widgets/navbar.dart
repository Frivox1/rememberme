import 'package:flutter/material.dart';
import 'package:rememberme/screens/add_annif.dart';
import 'package:rememberme/screens/home_screen.dart';
import 'package:rememberme/screens/list_screen.dart';

class CustomBottomNavBar extends StatelessWidget {
  const CustomBottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: Colors.pink[200],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon: const Icon(Icons.home, color: Colors.white),
            iconSize: 35,
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) {
                    return const HomeScreen();
                  },
                ),
              );
            },
            color: Theme.of(context).bottomNavigationBarTheme.selectedItemColor,
          ),
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            iconSize: 35,
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) {
                    return const AddAnnifScreen();
                  },
                ),
              );
            },
            color: Theme.of(context).bottomNavigationBarTheme.selectedItemColor,
          ),
          IconButton(
            icon: const Icon(Icons.list, color: Colors.white),
            iconSize: 35,
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) {
                    return const ListScreen();
                  },
                ),
              );
            },
            color: Theme.of(context).bottomNavigationBarTheme.selectedItemColor,
          ),
        ],
      ),
    );
  }
}
