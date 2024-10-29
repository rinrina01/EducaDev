import 'package:app/pages/home_page.dart';
import 'package:app/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  FluroRouterSetup.setupRouter();
  runApp(
    MultiProvider(
      providers: [
        Provider<int>.value(value: 0),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Educa Dev',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.amberAccent),
        useMaterial3: true,
      ),
      home: const HomePage(),
      onGenerateRoute: FluroRouterSetup.router.generator,
      initialRoute: '/',
    );
  }
}
