import 'package:app/main_layout.dart';
import 'package:app/services/quiz_service.dart';
import 'package:flutter/material.dart';

class PlayQuizPage extends StatefulWidget {
  final String quizId;
  
  const PlayQuizPage({
    Key? key,
    required this.quizId,
  }) : super(key: key);

  @override
  _PlayQuizPageState createState() => _PlayQuizPageState();
}

class _PlayQuizPageState extends State<PlayQuizPage> {
  late Future<Map<String, dynamic>> _quizzesFuture;

  @override
  void initState() {
    super.initState();
    _getQuizById(widget.quizId);
  }

  void _getQuizById(String quizId) {
    _quizzesFuture = QuizService().getQuizById(quizId);
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: "Quiz",
      child: Scaffold(
        body: Center(
          child: FutureBuilder<Map<String, dynamic>>(
            future: _quizzesFuture,
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Text('No quiz data found');
              } else {
                return Text('Quiz data: ${snapshot.data!}');
              }
            },
          ),
        ),
      ),
    );
  }
}
