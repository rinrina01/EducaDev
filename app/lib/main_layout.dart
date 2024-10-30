import 'package:app/provider/route_provider.dart';
import 'package:app/routes/routes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MainLayout extends StatelessWidget {
  final Widget child;
  final String title;

  const MainLayout({super.key, required this.child, required this.title});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<RouteProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              FluroRouterSetup.router.navigateTo(
                context,
                "admin/quiz",
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              FluroRouterSetup.router.navigateTo(
                context,
                "admin/view-score",
              );
            },
          ),
          if (authProvider.isAuthenticated)
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                FluroRouterSetup.router.navigateTo(
                  context,
                  "login",
                  clearStack: true,
                );
              },
              tooltip: 'Logout',
            ),
        ],
      ),
      body: child,
    );
  }
}
