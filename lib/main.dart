import 'package:dispenser_mobile_app/my_order.dart';
import 'package:dispenser_mobile_app/new_order.dart';
import 'package:dispenser_mobile_app/home.dart';
import 'package:dispenser_mobile_app/profile.dart';
import 'package:dispenser_mobile_app/signin.dart';
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
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/': (context) => const Home(),
        '/order': (context) => const MyOrder(),
        '/new_order': (context) => const NewOrder(),
        '/profile': (context) => const ProfilePage(),
      },
    );
  }
}
