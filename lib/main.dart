import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'home_page.dart';
import 'idarc_action.dart';

void main() {
  runApp(const FanDrac());
}

class FanDrac extends StatelessWidget {
  const FanDrac({Key? key}) : super(key: key);

  static const String _title = 'iDrac Fan Control';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
      theme: ThemeData(
        primarySwatch: Colors.grey,
      ),
      home: const HomePage(title: 'iDrac Fan Control'),
    );
  }
}
