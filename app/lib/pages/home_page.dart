import 'package:app/main_layout.dart';
import 'package:app/routes/routes.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  void toRedirected() {
    FluroRouterSetup.router.navigateTo(
      context,
      "register",
    );
  }

  void toRedirected1() {
    FluroRouterSetup.router.navigateTo(
      context,
      "admin/quiz/1234",
    );
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
        title: "Home",
        child: Scaffold(
          body: ElevatedButton(
              onPressed: toRedirected1, child: const Text("test")),
        ));
  }
}
