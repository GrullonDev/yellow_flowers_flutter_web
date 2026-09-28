import 'package:flutter/material.dart';

import 'package:yellow_flowers_web/features/home.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flores Amarillas (Web)',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      home: const MyHomePage(title: 'Flores Amarillas'),
    );
  }
}
