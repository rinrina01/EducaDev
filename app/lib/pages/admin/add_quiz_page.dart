import 'package:app/main_layout.dart';
import 'package:app/services/quiz_service.dart';
import 'package:flutter/material.dart';

class AddQuizPage extends StatefulWidget {
  const AddQuizPage({super.key});

  @override
  _AddQuizPageState createState() => _AddQuizPageState();
}

class _AddQuizPageState extends State<AddQuizPage> {
  final TextEditingController _categoryController = TextEditingController();
  final List<Map<String, dynamic>> _cards = [];
  void _addCard() {
    setState(() {
      _cards.add({
        'question': TextEditingController(),
        'answers': [TextEditingController()],
        'correct': <int>{},
        'time': TextEditingController(),
      });
    });
  }

  void _saveQuiz() async {
    if (_formKey.currentState!.validate()) {
      final category = _categoryController.text.trim();

      if (_cards.isNotEmpty) {
        try {
          final List<Map<String, dynamic>> questions = [];

          for (var card in _cards) {
            final questionText = card['question'].text.trim();

            final answers = (card['answers'] as List<TextEditingController>)
                .map((controller) => controller.text.trim())
                .where((answer) => answer.isNotEmpty)
                .toList();

            if (answers.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                      'Error: Each question must have at least one answer.'),
                ),
              );
              return;
            }

            final correctAnswers = (card['correct'] as Set<int>).toList();
            print(correctAnswers);
            if (correctAnswers.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                      'Error: Please select valid correct answers for each question.'),
                ),
              );
              return;
            }

            final timeLimit = int.tryParse(card['time'].text.trim());

            questions.add({
              'question': questionText,
              'answers': answers,
              'correct': correctAnswers,
              'time': timeLimit,
            });
          }

          await QuizService().addQuiz(category, questions);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Quiz added successfully!')),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error adding quiz: ${e.toString()}')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Error: Add at least one question to the quiz.')),
        );
      }
    }
  }

  void _removeCard(int index) {
    setState(() {
      _cards[index]['question'].dispose();
      _cards[index]['correct'].dispose();
      _cards[index]['time'].dispose();
      for (var answerController in _cards[index]['answers']) {
        answerController.dispose();
      }
      _cards.removeAt(index);
    });
  }

  @override
  void dispose() {
    _categoryController.dispose();
    for (var card in _cards) {
      card['question'].dispose();
      card['correct'].dispose();
      card['time'].dispose();
      for (var answerController in card['answers']) {
        answerController.dispose();
      }
    }
    super.dispose();
  }

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'Add Quiz',
      child: Scaffold(
        body: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextFormField(
                    controller: _categoryController,
                    decoration: const InputDecoration(
                      labelText: 'Quiz Category',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a quiz category';
                      }
                      return null;
                    },
                  ),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _cards.length,
                  itemBuilder: (context, index) {
                    return CardItem(
                      questionController: _cards[index]['question'],
                      answerControllers: _cards[index]['answers'],
                      timeController: _cards[index]['time'],
                      onAddAnswer: () {
                        setState(() {
                          _cards[index]['answers'].add(TextEditingController());
                        });
                      },
                      onRemoveAnswer: (answerIndex) {
                        setState(() {
                          _cards[index]['answers'][answerIndex].dispose();
                          _cards[index]['answers'].removeAt(answerIndex);
                        });
                      },
                      onRemoveCard: () => _removeCard(index),
                      onCorrectAnswersSelected: (selectedIndices) {
                        setState(() {
                          _cards[index]['correct'] = selectedIndices;
                        });
                      },
                    );
                  },
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _addCard,
                        icon: const Icon(Icons.add),
                        label: const Text('Add Question'),
                      ),
                      ElevatedButton.icon(
                        onPressed: _saveQuiz,
                        icon: const Icon(Icons.save),
                        label: const Text('Save Quiz'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CardItem extends StatefulWidget {
  final TextEditingController questionController;
  final List<TextEditingController> answerControllers;
  final TextEditingController timeController;
  final VoidCallback onAddAnswer;
  final Function(int) onRemoveAnswer;
  final VoidCallback onRemoveCard;
  final ValueChanged<Set<int>> onCorrectAnswersSelected;

  const CardItem({
    super.key,
    required this.questionController,
    required this.answerControllers,
    required this.timeController,
    required this.onAddAnswer,
    required this.onRemoveAnswer,
    required this.onRemoveCard,
    required this.onCorrectAnswersSelected,
  });

  @override
  _CardItemState createState() => _CardItemState();
}

class _CardItemState extends State<CardItem> {
  Set<int> selectedAnswerIndices = {};

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(10),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Question',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: widget.onRemoveCard,
                ),
              ],
            ),
            TextFormField(
              controller: widget.questionController,
              decoration: const InputDecoration(
                labelText: 'Question',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the question text';
                }
                return null;
              },
            ),
            const SizedBox(height: 10),
            Column(
              children: widget.answerControllers.asMap().entries.map((entry) {
                int index = entry.key;
                return CheckboxListTile(
                  title: Text('Answer ${index + 1}'),
                  value: selectedAnswerIndices.contains(index),
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        selectedAnswerIndices.add(index);
                      } else {
                        selectedAnswerIndices.remove(index);
                      }
                      widget.onCorrectAnswersSelected(selectedAnswerIndices);
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: widget.timeController,
              decoration: const InputDecoration(
                labelText: 'Time Limit (seconds)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a time limit';
                }
                final time = int.tryParse(value);
                if (time == null || time <= 0) {
                  return 'Please enter a valid positive number';
                }
                return null;
              },
            ),
            const SizedBox(height: 10),
            Column(
              children: List.generate(widget.answerControllers.length, (index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: widget.answerControllers[index],
                          decoration: InputDecoration(
                            labelText: 'Answer ${index + 1}',
                            border: const OutlineInputBorder(),
                          ),
                          maxLines: 1,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter an answer';
                            }
                            return null;
                          },
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.remove_circle),
                        onPressed: () => widget.onRemoveAnswer(index),
                      ),
                    ],
                  ),
                );
              }),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: widget.onAddAnswer,
                icon: const Icon(Icons.add),
                label: const Text('Add Answer'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
