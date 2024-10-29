import 'package:app/pages/home_page.dart';
import 'package:app/routes/routes.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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
