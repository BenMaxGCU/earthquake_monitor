import 'package:flutter/material.dart';
import 'home.dart';

class EarthquakeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(),
      home: EarthquakeHome(),
    );
  }
}
