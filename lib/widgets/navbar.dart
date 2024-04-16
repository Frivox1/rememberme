import 'package:flutter/material.dart';

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
              Navigator.pushNamedAndRemoveUntil(
                  context, '/home', (route) => false);
            },
            color: Theme.of(context).bottomNavigationBarTheme.selectedItemColor,
          ),
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            iconSize: 35,
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                  context, '/add', (route) => false);
            },
            color: Theme.of(context).bottomNavigationBarTheme.selectedItemColor,
          ),
          IconButton(
            icon: const Icon(Icons.list, color: Colors.white),
            iconSize: 35,
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                  context, '/list', (route) => false);
            },
            color: Theme.of(context).bottomNavigationBarTheme.selectedItemColor,
          ),
        ],
      ),
    );
  }
}
