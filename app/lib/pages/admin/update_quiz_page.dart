import 'package:app/main_layout.dart';
import 'package:flutter/material.dart';

class UpdateQuizPage extends StatefulWidget {
  final String quizId;

  const UpdateQuizPage({Key? key, required this.quizId}) : super(key: key);

  @override
  _UpdateQuizPageState createState() => _UpdateQuizPageState();
}

class _UpdateQuizPageState extends State<UpdateQuizPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const MainLayout(
      title: 'Update Quiz',
      child: Scaffold(body: Text("Update")),
    );
  }
}
