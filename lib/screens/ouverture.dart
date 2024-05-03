import 'package:flutter/material.dart';

class OuvertureScreen extends StatelessWidget {
  const OuvertureScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color.fromRGBO(244, 143, 177, 1),
      body: Center(
        child: Text(
          'RememberMe',
          style: TextStyle(
            color: Colors.white,
            fontSize: 36,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
