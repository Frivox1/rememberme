import 'package:flutter/material.dart';

class BirthdaysListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Liste des Anniversaires"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Center(
        child: Text(
          "Page pour afficher tous les anniversaires",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
