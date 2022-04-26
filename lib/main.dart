import 'package:dispenser_mobile_app/history.dart';
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

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var auth = '';
  Map<String, dynamic> user = {};

  void setAuth(String a) {
    setState(() {
      auth = a;
    });
  }

  void setUser(Map<String, dynamic> u) {
    setState(() {
      user = {...u};
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dispenser Mobile App',
      theme: themeApp,
      initialRoute: '/history',
      routes: {
        '/login': (context) => LoginScreen(
              setAuth: setAuth,
              setUser: setUser,
            ),
        '/': (context) => Home(
              token: auth,
              user: user,
            ),
        '/order': (context) => MyOrder(
              token: auth,
              user: user,
            ),
        '/new_order': (context) => NewOrder(
              token: auth,
              user: user,
            ),
        '/profile': (context) => ProfilePage(
              user: user,
            ),
        '/history': (context) => HistoryPage(
              token: auth,
              user: user,
            ),
      },
    );
  }
}
