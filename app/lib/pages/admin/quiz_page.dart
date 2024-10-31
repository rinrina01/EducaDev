import 'package:app/main_layout.dart';
import 'package:app/routes/routes.dart';
import 'package:app/services/quiz_service.dart';
import 'package:flutter/material.dart';

class QuizAdminPage extends StatefulWidget {
  const QuizAdminPage({super.key});

  @override
  _QuizAdminPageState createState() => _QuizAdminPageState();
}

class _QuizAdminPageState extends State<QuizAdminPage> {
  late Future<List<Map<String, dynamic>>> _quizzesFuture;

  @override
  void initState() {
    super.initState();
    _loadQuizzes();
  }

  void _loadQuizzes() {
    _quizzesFuture = QuizService().getQuizzes();
  }

  Future<void> _deleteQuiz(String quizId) async {
    await QuizService().deleteQuiz(quizId);
    setState(() => _loadQuizzes());
  }

  void _updateQuiz(String quizId) {
    FluroRouterSetup.router.navigateTo(
      context,
      "admin/quiz/update/$quizId",
    );
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
        title: 'Quiz Admin',
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
                    final category = quiz['category'];
                    final questionCount = (quiz['questions'] as List).length;

                    return QuizCardAdmin(
                      category: category,
                      questionCount: questionCount,
                      onDelete: () => _deleteQuiz(quizId),
                      onUpdate: () => _updateQuiz(quizId),
                    );
                  },
                );
              }
            },
          ),
          floatingActionButton: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FloatingActionButton(
                heroTag: 'quizStateButton',
                onPressed: () {
                  FluroRouterSetup.router.navigateTo(
                    context,
                    "admin/view-score",
                  );
                },
                tooltip: 'Quiz state',
                child: const Icon(Icons.stacked_bar_chart),
              ),
              const SizedBox(width: 16),
              FloatingActionButton(
                heroTag: 'addQuizButton',
                onPressed: () {
                  FluroRouterSetup.router.navigateTo(
                    context,
                    "admin/quiz/add",
                  );
                },
                tooltip: 'Add Quiz',
                child: const Icon(Icons.add),
              ),
            ],
          ),
        ));
  }
}

class QuizCardAdmin extends StatelessWidget {
  final String category;
  final int questionCount;
  final VoidCallback onDelete;
  final VoidCallback onUpdate;

  const QuizCardAdmin({
    super.key,
    required this.category,
    required this.questionCount,
    required this.onDelete,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(10),
      child: ListTile(
        title: Text(category),
        subtitle: Text('$questionCount questions'),
        trailing: SizedBox(
          width: 96,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: onDelete,
                tooltip: 'Delete Quiz',
              ),
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: onUpdate,
                tooltip: 'Update Quiz',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
