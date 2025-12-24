import 'package:flutter/material.dart';

class AboutusPage extends StatelessWidget {
  const AboutusPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.white, title: Text("About Us")),
      backgroundColor: Colors.white,
      body: Center(
        child: Text(
          'Contact us via gmail at emmanuelozmac@gmail.com to help you build your dream app.',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
