import 'package:flutter/material.dart';
import 'package:vet_chat/pusher.dart';
import 'package:vet_chat/users.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(

      home: UserChat(),
    );
  }
}