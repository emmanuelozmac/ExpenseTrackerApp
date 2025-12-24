import 'package:flutter/material.dart';

class MyButton2 extends StatelessWidget {
  final Function()? onTap;
  final String text;

  const MyButton2({super.key, required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(15),
        margin: const EdgeInsets.symmetric(horizontal: 25),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 40, 40, 220),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Center(child: Text(text, style: TextStyle(color: Colors.white))),
      ),
    );
  }
}
