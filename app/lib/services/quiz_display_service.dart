import 'package:app/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:app/services/quiz_service.dart';

class Question extends StatefulWidget {
  late Future<Map<String, dynamic>> _quizzesFuture;

  final String text;
  final List<String> options;
  final int correctAnswerIndex;

  Question({
    required this.text,
    required this.options,
    required this.correctAnswerIndex,
  });

  @override
  _QuestionState createState() => _QuestionState();
}

class _QuestionState extends State<Question> {}
