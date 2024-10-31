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
  late int timeLeft; // 30-second timer for each question
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _getQuizById(widget.quizId); // get quiz info
    _startCountDown(); // start the timer when the page is initialized
  }

  @override
  void dispose() {
    _timer?.cancel(); // cancel timer when widget is disposed
    super.dispose();
  }

  void _getQuizById(String quizId) {
    _quizzesFuture = QuizService().getQuizById(quizId);
  }

  void goHome() {
    FluroRouterSetup.router.navigateTo(context, "/");
  }

  // timer method, with reset for each question
  void _startCountDown() async {
    // reset timer for each question
    final quizData = await _quizzesFuture;
    setState(() {
      timeLeft = quizData['questions'][currentQuestionIndex]['time'];
    });

    _timer?.cancel(); // cancel any existing timer
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timeLeft > 0) {
        setState(() {
          timeLeft--;
        });
      } else {
        timer.cancel();
        nextQuestion(); // go to the next question when time is up
      }
    });
  }

  void nextQuestion() {
    final totalQuestions =
        _quizzesFuture.then((data) => data['questions'].length);

    totalQuestions.then((totalQuestions) {
      if (currentQuestionIndex < totalQuestions - 1) {
        // ensure all questions are displayed to the user successively
        setState(() {
          currentQuestionIndex++;
        });
        _startCountDown(); // restart timer for the next question
      } else {
        // Handle end of quiz
        _timer?.cancel(); // stop timer at end of quiz
        calculateScoreAndNavigate(totalQuestions);
      }
    });
  }

  void calculateScoreAndNavigate(int totalQuestions) async {
    // Calculate the score based on user's answers and navigate to results page
    final questions = await _quizzesFuture.then((data) => data['questions']);
    int correctAnswersCount = 0;

    for (int i = 0; i < totalQuestions; i++) {
      // for every question
      final currentQuestion = questions[i];
      final userAnswer = userAnswers[i];

      if (userAnswer != null) {
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
          final correctIndexes = currentQuestion['correct'];
          final correctAnswers = correctIndexes
              .map((index) => currentQuestion['answers'][index])
              .toList();
          // adds to new list only the right answers by selecting them with the indexes of the correct answers

          // check if userAnswer contains all correct answers
          if (correctAnswers.every(
              (answer) => (userAnswer as List<dynamic>).contains(answer))) {
            correctAnswersCount++; // increment only if the user has ALL answers right
          }
        }
      }
    }

    ScoreService().addScore(
      FirebaseAuth.instance.currentUser!.uid,
      correctAnswersCount,
      totalQuestions,
      category,
    );
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
            body: Center(child: Text('No quiz data found')),
          );
        } else if (snapshot.hasError) {
          // connection error
          goHome(); // redirect to home
          return Scaffold(
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        } else {
          // if everything working
          final List<dynamic> questions =
              snapshot.data!['questions']; // get questions/answers
          final currentQuestion = questions[
              currentQuestionIndex]; // get question based on the current question index
          category = snapshot.data!['category'];

          return Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              title: Text(
                  "Question ${currentQuestionIndex + 1}/${questions.length}"), // avoid writing "question 0" on user-destined quiz
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Time left: $timeLeft", // display timer
                      style: const TextStyle(fontSize: 18, color: Colors.red)),
                  const SizedBox(height: 20),
                  Text(currentQuestion['question'],
                      style: const TextStyle(
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
                    onPressed: () => nextQuestion(),
                    child: Text(currentQuestionIndex < questions.length - 1
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
