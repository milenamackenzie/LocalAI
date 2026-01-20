import 'package:flutter/material.dart';

void main() {
  runApp(const LocalAIApp());
}

class LocalAIApp extends StatelessWidget {
  const LocalAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LocalAI',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: Center(
          child: Text('Welcome to LocalAI'),
        ),
      ),
    );
  }
}
