import 'dart:convert';

import 'package:app/pages/home_page.dart';
import 'package:app/provider/route_provider.dart';
import 'package:app/routes/routes.dart';
import 'package:app/services/quiz_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FluroRouterSetup.setupRouter();
  // await loadJsonData();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<RouteProvider>(create: (_) => RouteProvider()),
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

Future<void> loadJsonData() async {
  try {
    final String response = await rootBundle.loadString('assets/data.json');
    final data = json.decode(response);

    // Traite chaque quiz dans la liste `quizzes`
    for (var quiz in data['quizzes']) {
      final String category = quiz['category'];

      // Conversion de `questions` en `List<Map<String, dynamic>>`
      final List<Map<String, dynamic>> questions =
          (quiz['questions'] as List<dynamic>)
              .map((question) => Map<String, dynamic>.from(question))
              .toList();

      await QuizService().addQuiz(category, questions);
    }

    print("All quizzes successfully added to Firestore.");
  } catch (e) {
    print("Error loading JSON or adding quizzes: $e");
  }
}
