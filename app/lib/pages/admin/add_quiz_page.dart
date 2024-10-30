import 'package:app/main_layout.dart';
import 'package:app/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:app/services/quiz_service.dart';

class AddQuizPage extends StatefulWidget {
  const AddQuizPage({super.key});

  @override
  _AddQuizPageState createState() => _AddQuizPageState();
}

class _AddQuizPageState extends State<AddQuizPage> {
  final _categoryController = TextEditingController();
  final List<Map<String, dynamic>> _questions = [];

  // Form key for validation
  final _formKey = GlobalKey<FormState>();

  // Adds a new question with default values to the list
  void _addQuestion() {
    setState(() {
      _questions.add({
        'question': '',
        'correct': 0,
        'rep': ['', '', '', ''],
        'time': 30,
      });
    });
  }

  // Save the quiz to Firestore
  Future<void> _saveQuiz() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        await QuizService().addQuiz(_categoryController.text, _questions);
        FluroRouterSetup.router.navigateTo(
          context,
          "admin/quiz",
        );
      } catch (e) {
        print("Error saving quiz: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'Add Quiz',
      child: Scaffold(
          body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Category Input
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(labelText: 'Category'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a category';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // List of Questions
              ..._questions.asMap().entries.map((entry) {
                int index = entry.key;
                Map<String, dynamic> question = entry.value;
                return _buildQuestionField(index);
              }).toList(),

              // Add Question Button
              TextButton.icon(
                onPressed: _addQuestion,
                icon: const Icon(Icons.add),
                label: const Text('Add Question'),
              ),
              const SizedBox(height: 20),

              // Save Quiz Button
              ElevatedButton(
                onPressed: _saveQuiz,
                child: const Text('Save Quiz'),
              ),
            ],
          ),
        ),
      )),
    );
  }

  // Builds a form for each question
  Widget _buildQuestionField(int index) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Question Text
            TextFormField(
              initialValue: _questions[index]['question'],
              decoration: const InputDecoration(labelText: 'Question Text'),
              onChanged: (value) => _questions[index]['question'] = value,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a question';
                }
                return null;
              },
            ),
            const SizedBox(height: 10),

            // Answer Options
            const Text('Answer Options:'),
            ...List.generate(4, (optionIndex) {
              return TextFormField(
                initialValue: _questions[index]['rep'][optionIndex],
                decoration:
                    InputDecoration(labelText: 'Option ${optionIndex + 1}'),
                onChanged: (value) =>
                    _questions[index]['rep'][optionIndex] = value,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an option';
                  }
                  return null;
                },
              );
            }),

            const SizedBox(height: 10),

            // Correct Answer
            DropdownButtonFormField<int>(
              value: _questions[index]['correct'],
              decoration: const InputDecoration(labelText: 'Correct Answer'),
              items: List.generate(
                  4,
                  (i) => DropdownMenuItem(
                      value: i, child: Text('Option ${i + 1}'))),
              onChanged: (value) => _questions[index]['correct'] = value!,
            ),
            const SizedBox(height: 10),

            // Time to Answer
            TextFormField(
              initialValue: _questions[index]['time'].toString(),
              decoration: const InputDecoration(labelText: 'Time (seconds)'),
              keyboardType: TextInputType.number,
              onChanged: (value) =>
                  _questions[index]['time'] = int.tryParse(value) ?? 30,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _categoryController.dispose();
    super.dispose();
  }
}
