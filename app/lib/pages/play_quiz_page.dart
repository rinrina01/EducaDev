import 'package:app/main_layout.dart';
import 'package:app/routes/routes.dart';
import 'package:app/services/quiz_service.dart';
import 'package:app/services/score_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:async';

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
  late String category;

  int currentQuestionIndex =
      0; // states will be used to track the current question
  Map<int, dynamic> userAnswers = {}; // Map of the answers the user selected
  int timeLeft = 5;

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

  //timer method
  void _startCountDown() {
    Timer.periodic(Duration(seconds: 1), (timer) {
      // if (timeLeft > 0) {
      setState(() {
        timeLeft--;
      });
      print("time left decrement");
      // } else {
      //   timer.cancel();
      // }
    });
  }

  void nextQuestion(int totalQuestions, List<dynamic> questions) {
    if (currentQuestionIndex < totalQuestions - 1) {
      // ensure all questions are displayed to the user successively
      setState(() {
        currentQuestionIndex++;
      });
      _startCountDown;
    } else {
      // Handle end of quiz
      calculateScoreAndNavigate(totalQuestions, questions);
    }
  }

  void calculateScoreAndNavigate(int totalQuestions, List<dynamic> questions) {
    int correctAnswersCount = 0;

    for (int i = 0; i < totalQuestions; i++) {
      // for every question
      final currentQuestion = questions[i];
      final userAnswer = userAnswers[i];

      if (!(userAnswer == null)) {
        // if userAnswer is not null
        if (currentQuestion['correct'].length == 1) {
          // check if the userAnswer is correct
          // single correct answer case (RADIOHEAD)
          if (userAnswer ==
              currentQuestion['answers'][currentQuestion['correct'][0]]) {
            // check if the userAnswer is the answer to the current question selected with index of the ONLY possible correct answer
            correctAnswersCount++;
          }
        } else {
          // multiple correct answers (CHECKBOX)
          final List<dynamic> correctIndexes = currentQuestion[
              'correct']; // get list of all correct answers indexes for this question
          final List<dynamic> correctAnswers = correctIndexes
              .map((index) => currentQuestion['answers'][index])
              .toList();
          // adds to new list only the right answers by selecting them with the indexes of the correct answers

          // check if userAnswer contains all correct answers
          if (List.from(correctAnswers).every(
              (answer) => (userAnswer as List<dynamic>).contains(answer))) {
            correctAnswersCount++; // increment only if the user has ALL answers right
          }
        }
      }
    }

    ScoreService().addScore(FirebaseAuth.instance.currentUser!.uid,
        correctAnswersCount, totalQuestions, category);
    // calculate percentage score
    print(totalQuestions);
    print(correctAnswersCount);
    print(((correctAnswersCount / totalQuestions) * 100).toInt().toString() +
        "%");

    // Navigate to results page (create your results page)
    FluroRouterSetup.router.navigateTo(context, "/");
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _quizzesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // while fetching
          return const Scaffold(
            body:
                Center(child: CircularProgressIndicator()), // loading animation
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          // if not data in quiz
          goHome(); // redirect to home
          return const Scaffold(
            body: Center(
              child: Text('No quiz data found'),
            ),
          );
        } else if (snapshot.hasError) {
          // connexion error
          goHome(); // redirect to home
          return Scaffold(
            body: Center(
              child: Text('Error: ${snapshot.error}'),
            ),
          );
        } else {
          // if everything working
          final List<dynamic> questions =
              snapshot.data!['questions']; // get questions/answers
          final totalQuestions =
              questions.length; // total number of questions in the quiz
          final currentQuestion = questions[
              currentQuestionIndex]; // get question based on the current question index
          category = snapshot.data!['category'];

          return Scaffold(
            appBar: AppBar(
                automaticallyImplyLeading: false,
                title: Text(
                    "Question ${currentQuestionIndex + 1}/$totalQuestions")), // avoid writing "question 0" on user-destined quiz
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Time left: ${timeLeft.toString()}", // display timer
                      style: TextStyle(fontSize: 18, color: Colors.red)),
                  const SizedBox(height: 20),
                  Text(currentQuestion['question'],
                      style: TextStyle(
                          fontSize: 18)), // get String question for user
                  const SizedBox(height: 20),

                  ...List<Widget>.generate(currentQuestion['answers'].length,
                      (index) {
                    // loop to display all answer options
                    final answer = currentQuestion['answers']
                        [index]; // get answers one by one
                    if (currentQuestion['correct'].length == 1) {
                      // RadioListTile -> only one correct answer
                      return RadioListTile(
                        title: Text(answer),
                        value: answer,
                        groupValue: userAnswers[currentQuestionIndex],
                        onChanged: (value) {
                          setState(() {
                            userAnswers[currentQuestionIndex] = value;
                          });
                        },
                      );
                    } else {
                      // CheckboxListTile -> multiple correct answers
                      return CheckboxListTile(
                        title: Text(answer),
                        value: (userAnswers[currentQuestionIndex] ?? [])
                            .contains(answer),
                        onChanged: (bool? checked) {
                          setState(() {
                            if (checked == true) {
                              // Add answer to selected list if checked
                              userAnswers[currentQuestionIndex] = [
                                ...(userAnswers[currentQuestionIndex] ?? []),
                                answer
                              ];
                            } else {
                              // Remove answer from selected list if unchecked
                              userAnswers[currentQuestionIndex] = [
                                ...(userAnswers[currentQuestionIndex] ?? [])
                              ]..remove(answer);
                            }
                          });
                        },
                      );
                    }
                  }),

                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => nextQuestion(totalQuestions, questions),
                    child: Text(currentQuestionIndex < totalQuestions - 1
                        ? 'Next'
                        : 'Submit'),
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}
