import 'package:apple_leaf/configs/theme.dart';
import 'package:apple_leaf/splash_screen.dart';
import 'package:flutter/material.dart';
// import 'main_screen.dart';
// import 'pages/login/auth_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Apple Leaf',
      theme: ThemeData(
        fontFamily: 'Inter',
        scaffoldBackgroundColor: neutralWhite,
      ),
      home: const SplashScreen(),
    );
  }
}
