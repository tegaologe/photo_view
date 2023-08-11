import 'package:flutter/material.dart';
import 'package:photo_view_example/screens/home_screen.dart';

void main() => runApp(const MyApp());

ThemeData theme = ThemeData(
  primaryColor: Colors.black,
  fontFamily: 'PTSans',
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Photo View Example App',
      theme: theme,
      home: const Scaffold(
        body: HomeScreen(),
      ),
    );
  }
}
