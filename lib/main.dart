import 'package:flutter/material.dart';

void main() {
  runApp(const YoyotimeApp());
}

class YoyotimeApp extends StatelessWidget {
  const YoyotimeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Yoyotime',
      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Yoyotime')),
      body: const Center(
        child: Text('Hello Yoyotime!'),
      ),
    );
  }
}
