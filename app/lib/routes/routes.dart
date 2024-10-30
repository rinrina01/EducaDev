import 'package:app/pages/admin/add_quiz_page.dart';
import 'package:app/pages/admin/quiz_page.dart';
import 'package:app/pages/login_page.dart';
import 'package:app/pages/home_page.dart';
import 'package:app/pages/my_account_page.dart';
import 'package:app/pages/register_page.dart';
import 'package:app/provider/route_provider.dart';
import 'package:app/pages/play_quiz.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FluroRouterSetup {
  static final FluroRouter router = FluroRouter();

  static final Handler _homePageHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
      return const HomePage();
    },
  );

  static final Handler _loginPageHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
      return const LoginPage();
    },
  );

  static final Handler _registerPageHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
      return const RegisterPage();
    },
  );

  static final Handler _myAccountHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
      final authProvider = Provider.of<RouteProvider>(context!, listen: false);

      // Utilise addPostFrameCallback pour la redirection après la construction initiale
      WidgetsBinding.instance.addPostFrameCallback((_) {
        authProvider.redirectIfNotAuthenticated(context);
      });
      return const MyAccountPage();
    },
  );

 static final Handler _playQuizHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
      final authProvider = Provider.of<RouteProvider>(context!, listen: false);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        authProvider.redirectIfNotAuthenticated(context);
      });
      final quizId = params['id']?.first;
      if (quizId != null) {
        return PlayQuizPage(quizId: quizId);
      } else {
        return const HomePage();
        // return const Scaffold(
        //   body: Center(child: Text("Quiz ID not found")),
        // );
      }
    },
  );

  static final Handler _quizAdminHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
      final authProvider = Provider.of<RouteProvider>(context!, listen: false);

      // Utilise addPostFrameCallback pour la redirection après la construction initiale
      WidgetsBinding.instance.addPostFrameCallback((_) {
        authProvider.redirectIfNotAdmin(context);
      });
      return const QuizAdminPage();
    },
  );

  static final Handler _addQuizAdminHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
      final authProvider = Provider.of<RouteProvider>(context!, listen: false);

      // Utilise addPostFrameCallback pour la redirection après la construction initiale
      WidgetsBinding.instance.addPostFrameCallback((_) {
        authProvider.redirectIfNotAdmin(context);
      });
      return const AddQuizPage();
    },
  );

  static void setupRouter() {
    router.define(
      "/",
      handler: _homePageHandler,
    );

    router.define(
      "login",
      handler: _loginPageHandler,
    );

    router.define(
      "register",
      handler: _registerPageHandler,
    );

    router.define(
      "my-account",
      handler: _myAccountHandler,
    );

  router.define(
      "quiz/:id",
      handler: _playQuizHandler,
  );

    router.define(
      "admin/quiz",
      handler: _quizAdminHandler,
    );

    router.define(
      "admin/quiz/add",
      handler: _addQuizAdminHandler,
    );
  }
}
