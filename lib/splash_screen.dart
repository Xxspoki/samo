import 'package:flutter/material.dart';

Container splashScreen() {
  return Container(
    color: Colors.white,
    alignment: Alignment.center,
    child: SizedBox(
      width: 600,
      height: 800,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30.0),
              child: Image.asset('assets/logo.png'),
            ),
          ),
        ],
      ),
    ),
  );
}
