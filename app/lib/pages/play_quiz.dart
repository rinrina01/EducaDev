import 'package:app/main_layout.dart';
import 'package:app/routes/routes.dart';
import 'package:app/services/quiz_service.dart';
import 'package:flutter/material.dart';
import 'package:app/services/quiz_display_service.dart';


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

  void goHome() {
    FluroRouterSetup.router.navigateTo(
      context,
      "/",
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _quizzesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          goHome();
          return const Scaffold(
              body: Center(
                child: Text(
                  'No quiz data found',
                ),
            ),
          );
          
        } else if (snapshot.hasError) {
          goHome();
          return Scaffold(
              body: Center(
                child: Text(
                  'Error: ${snapshot.error}', 
                ),
            ),
          );

        } else { // quiz exists  
          // redirect to question page
          
          return MainLayout(
            title: "title",
            child: Scaffold(
              body: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('hjksdhjks'),
                    SizedBox(height: 20),
                    Text('Questions :'),

                    // Using a for loop to display each question if they exist
                    for (var question in snapshot.data!['questions'] ?? [])
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text('- ${question["question"]}', // Assuming each question has a 'text' field
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        }
      },
    );
  }
}