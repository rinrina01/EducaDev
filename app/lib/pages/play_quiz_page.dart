import 'package:app/main_layout.dart';
import 'package:app/routes/routes.dart';
import 'package:app/services/quiz_service.dart';
import 'package:flutter/material.dart';

class PlayQuizPage extends StatefulWidget {
  final String quizId; // id of the quiz that the user previously clicked on

  const PlayQuizPage({
    Key? key,
    required this.quizId,
  }) : super(key: key);

  @override
  _PlayQuizPageState createState() => _PlayQuizPageState();
}

class _PlayQuizPageState extends State<PlayQuizPage> {
  late Future<Map<String, dynamic>> _quizzesFuture;
  int currentQuestionIndex = 0;  // states will be used to track the current question
  Map<int, dynamic> userAnswers = {}; // Map of the answers the user selected

  @override
  void initState() {
    super.initState();
    _getQuizById(widget.quizId); // get quiz info
  }

  void _getQuizById(String quizId) {
    _quizzesFuture = QuizService().getQuizById(quizId);
  }

  void goHome() {
    FluroRouterSetup.router.navigateTo(context, "/");
  }

  void nextQuestion(int totalQuestions) {
    if (currentQuestionIndex < totalQuestions - 1) {
      setState(() {
        currentQuestionIndex++;
      });
    } else {
      // Handle end of quiz (e.g., navigate to a results page)
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _quizzesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) { // while fetching
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()), // loading animation
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) { // if not data in quiz
          goHome(); // redirect to home
          return const Scaffold(
            body: Center(
              child: Text('No quiz data found'),
            ),
          );
        } else if (snapshot.hasError) { // connexion error
          goHome(); // redirect to home
          return Scaffold(
            body: Center(
              child: Text('Error: ${snapshot.error}'),
            ),
          );
        } else { // if everything working
          final List<dynamic> questions = snapshot.data!['questions']; // get questions/answers
          final totalQuestions = questions.length; // total number of questions in the quiz
          final currentQuestion = questions[currentQuestionIndex]; // get question based on the current question index

          return MainLayout(
            title: "Quiz",
            child: Scaffold(
              appBar: AppBar(title: Text("Question ${currentQuestionIndex + 1}")), // avoid writing "question 0" on user-destined quiz
              body: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(currentQuestion['question'], style: TextStyle(fontSize: 18)), // get String question for user
                    const SizedBox(height: 20),


                    ...List<Widget>.generate(currentQuestion['answers'].length, (index) { // loop to print all answer options
                      final answer = currentQuestion['answers'][index]; // get answers one by one
                      if (currentQuestion['correct'].length == 1) {
                        return RadioListTile(
                          title: Text(answer),
                          // display user answer
                          value: answer,
                          // store value to send to db
                          groupValue: userAnswers[currentQuestionIndex],
                          // stock the answer that the user chose at the index of the current question in userAnswers MAP
                          onChanged: (value) {
                            setState(() {
                              userAnswers[currentQuestionIndex] = value;
                            });
                          },
                        );
                      } else {
                        // UPDATE LINE
                      }
                    }),

                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => nextQuestion(totalQuestions),
                      child: Text(currentQuestionIndex < totalQuestions - 1 ? 'Next' : 'Submit'),
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
