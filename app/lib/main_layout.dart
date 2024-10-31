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
    final authProvider = Provider.of<RouteProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        automaticallyImplyLeading: false,
        actions: [
          if (!authProvider.isAuthenticated)
            TextButton(
              onPressed: () {
                FluroRouterSetup.router.navigateTo(
                  context,
                  "login",
                );
              },
              child: const Text("Login"),
            ),
          if (authProvider.isAdmin)
            IconButton(
              icon: const Icon(Icons.account_circle),
              onPressed: () {
                FluroRouterSetup.router.navigateTo(
                  context,
                  "my-account",
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
            ),
        ],
      ),
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        onTap: (index) {
          switch (index) {
            case 0:
              FluroRouterSetup.router
                  .navigateTo(context, '/', clearStack: true);
              break;
            case 1:
              if (authProvider.isAdmin) {
                FluroRouterSetup.router
                    .navigateTo(context, 'admin-quiz', clearStack: true);
              } else {
                FluroRouterSetup.router.navigateTo(
                  context,
                  'my-account',
                );
              }
              break;
          }
        },
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          if (authProvider.isAdmin && authProvider.isAuthenticated)
            const BottomNavigationBarItem(
              icon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
          if (!authProvider.isAdmin)
            const BottomNavigationBarItem(
              icon: Icon(Icons.account_circle),
              label: 'My Account',
            ),
        ],
      ),
    );
  }
}
