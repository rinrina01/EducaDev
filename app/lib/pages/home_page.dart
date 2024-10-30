import 'package:app/main_layout.dart';
import 'package:app/routes/routes.dart';
import 'package:flutter/material.dart';

import 'package:app/services/quiz_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Map<String, dynamic>>> _quizzesFuture;
  @override
  void initState() {
    super.initState();
    _loadQuizzes();
  }

  void _loadQuizzes() {
    _quizzesFuture = QuizService().getQuizzes();
  }

  void toRedirected() {
    FluroRouterSetup.router.navigateTo(
      context,
      "register",
    );
  }

  void toRedirected1() {
    FluroRouterSetup.router.navigateTo(
      context,
      "my-account",
    );
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
        title: 'Home',
        child: Scaffold(
          body: FutureBuilder<List<Map<String, dynamic>>>(
            future: _quizzesFuture,
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No quizzes available.'));
              } else {
                final quizzes = snapshot.data!;

                return ListView.builder(
                  itemCount: quizzes.length,
                  itemBuilder: (context, index) {
                    final quiz = quizzes[index];
                    final quizId = quiz['id'] as String;
                    final category = quiz['category'] ?? 'No category';
                    final questionCount = (quiz['questions'] as List).length;

                    return QuizCard(
                      category: category,
                      questionCount: questionCount,
                      quizId: quizId,
                    );
                  },
                );
              }
            },
          ),
        ));
  }
}

class QuizCard extends StatelessWidget {
  final String category;
  final int questionCount;
  final String quizId;

  const QuizCard({
    super.key,
    required this.category,
    required this.questionCount,
    required this.quizId,
  });

  @override
  Widget build(BuildContext context) {
    void toRedirected() {   // CHANGER LE TYPE DE LA VARIABLE
      FluroRouterSetup.router.navigateTo(
        context,
        "admin/quiz-list/", // access specific quizz page
      );
    }

    return Card(
      margin: const EdgeInsets.all(10),
      child: ListTile(
        title: Text(category),
        subtitle: Text('$questionCount questions'),
        onTap: toRedirected,
      ),
    );
  }
}
