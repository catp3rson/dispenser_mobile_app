import 'package:dispenser_mobile_app/home.dart';
import 'package:dispenser_mobile_app/theme.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dispenser Mobile App',
      theme: themeApp,
      home: const MyHomePage(),
    );
  }
}
