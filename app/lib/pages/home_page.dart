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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: toRedirected,
          child: const Text('Go to Add Contacts'),
        ),
      ),
    );
  }
}
