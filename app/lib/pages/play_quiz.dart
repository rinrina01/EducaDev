import 'package:app/main_layout.dart';
import 'package:app/routes/routes.dart';
import 'package:app/services/quiz_service.dart';
import 'package:flutter/material.dart';

class PlayQuizPage extends StatefulWidget {
  final String quizId;
  
  const PlayQuizPage({
      super.key,
      required this.quizId
    });

  @override
  _PlayQuizPageState createState() => _PlayQuizPageState();
}

class _PlayQuizPageState extends State<PlayQuizPage> {
  late Future<List<Map<String, dynamic>>> _quizzesFuture;
  @override
  void initState() {
    super.initState();
    _loadQuizzes();
  }

  void _loadQuizzes() {
    _quizzesFuture = QuizService().getQuizzes();
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
        title: "Quiz",
        child: Scaffold(
        ));
  }
}