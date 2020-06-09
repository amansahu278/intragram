import 'package:flutter/material.dart';
import 'package:intragram/pages/home.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Intragram',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        accentColor: Colors.teal,
      ),
      debugShowCheckedModeBanner: false,
      home: Home(),
    );
  }
}
