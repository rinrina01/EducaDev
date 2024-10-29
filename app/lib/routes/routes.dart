import 'package:app/pages/login_page.dart';
import 'package:app/pages/home_page.dart';
import 'package:app/pages/my_account_page.dart';
import 'package:app/pages/register_page.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';

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

  static final Handler _registrePageHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
      return const RegisterPage();
    },
  );

  static final Handler _myAccountHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
      return const MyAccountPage();
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
      "registre",
      handler: _registrePageHandler,
    );

    router.define(
      "my-account",
      handler: _myAccountHandler,
    );
  }
}
