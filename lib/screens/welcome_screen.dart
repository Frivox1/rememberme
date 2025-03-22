import 'package:flutter/material.dart';
import 'home_screen.dart';

class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      appBar: AppBar(title: Text('Welcome')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(Icons.star, size: 100, color: Colors.white),
            SizedBox(height: 20),
            Text(
              'Welcome to RememberMe!',
              style: TextStyle(fontSize: 24, color: Colors.white),
            ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                // Lorsque l'utilisateur appuie sur le bouton, on va à l'écran principal
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => HomeScreen()),
                );
              },
              child: Text('Start Using App'),
            ),
          ],
        ),
      ),
    );
  }
}
