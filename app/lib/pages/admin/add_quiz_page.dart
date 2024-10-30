import 'package:app/main_layout.dart';
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
        'questionController': TextEditingController(),
        'answers': [TextEditingController()],
        'correctController': TextEditingController(),
        'timeController': TextEditingController(),
      });
    });
  }

  void _saveQuiz() {
    if (_formKey.currentState!.validate()) {
      String category = _categoryController.text.trim();
      print("Category: $category");

      for (var i = 0; i < _cards.length; i++) {
        String question = _cards[i]['questionController']?.text.trim() ?? '';
        List<String> answers =
            (_cards[i]['answers'] as List<TextEditingController>)
                .map((controller) => controller.text.trim())
                .where((answer) => answer.isNotEmpty)
                .toList();
        String correctAnswer =
            _cards[i]['correctController']?.text.trim() ?? '';
        String timeLimit = _cards[i]['timeController']?.text.trim() ?? '';

        print("Question ${i + 1}: $question");
        print("Correct Answer: $correctAnswer");
        print("Time Limit: $timeLimit");
        for (var j = 0; j < answers.length; j++) {
          print("  Answer ${j + 1}: ${answers[j]}");
        }
      }
    }
  }

  void _removeCard(int index) {
    setState(() {
      _cards[index]['questionController'].dispose();
      _cards[index]['correctController'].dispose();
      _cards[index]['timeController'].dispose();
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
      card['questionController'].dispose();
      card['correctController'].dispose();
      card['timeController'].dispose();
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
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton.icon(
                    onPressed: _saveQuiz,
                    icon: const Icon(Icons.save),
                    label: const Text('Save Quiz'),
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

class CardItem extends StatelessWidget {
  final TextEditingController questionController;
  final List<TextEditingController> answerControllers;
  final TextEditingController correctController;
  final TextEditingController timeController;

  final VoidCallback onAddAnswer;
  final Function(int) onRemoveAnswer;
  final VoidCallback onRemoveCard;

  const CardItem({
    super.key,
    required this.questionController,
    required this.answerControllers,
    required this.correctController,
    required this.timeController,
    required this.onAddAnswer,
    required this.onRemoveAnswer,
    required this.onRemoveCard,
  });

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
                  onPressed: onRemoveCard,
                ),
              ],
            ),
            TextFormField(
              controller: questionController,
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
            TextField(
              controller: correctController,
              decoration: const InputDecoration(
                labelText: 'Correct Answer',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: timeController,
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
              children: List.generate(answerControllers.length, (index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: Row(
                    children: [
                      Expanded(
                          child: TextFormField(
                        controller: answerControllers[index],
                        decoration: InputDecoration(
                          labelText: 'Answer ${index + 1}',
                          border: const OutlineInputBorder(),
                        ),
                        maxLines: 1,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter an answer';
                          }
                          if (!RegExp(r'^[a-zA-Z0-9 ]+$').hasMatch(value)) {
                            return 'Only letters and numbers are allowed';
                          }
                          return null;
                        },
                      )),
                      IconButton(
                        icon: const Icon(Icons.remove_circle),
                        onPressed: () => onRemoveAnswer(index),
                      ),
                    ],
                  ),
                );
              }),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: onAddAnswer,
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
