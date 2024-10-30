import 'package:app/main_layout.dart';
import 'package:app/routes/routes.dart';
import 'package:app/services/quiz_service.dart';
import 'package:flutter/material.dart';

class QuizListPage extends StatefulWidget {
  const QuizListPage({super.key});

  @override
  _QuizListPageState createState() => _QuizListPageState();
}

class _QuizListPageState extends State<QuizListPage> {
  late Future<List<Map<String, dynamic>>> _quizzesFuture;
 @override
  void initState() {
    super.initState();
    _loadQuizzes();
  }

  void _loadQuizzes() {
    _quizzesFuture = QuizService().getQuizzes();
  }

  void toRedirected() {   // CHANGER LE TYPE DE LA VARIABLE
    FluroRouterSetup.router.navigateTo(
      context,
      "admin/quiz-list/1234", // access specific quizz page
    );
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
        title: 'Quizzes',
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
          floatingActionButton: FloatingActionButton(
            onPressed: toRedirected,
            child: const Icon(Icons.add),
            tooltip: 'Access Quiz',
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
        "admin/quiz-list/$quizId", // access specific quizz page
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
