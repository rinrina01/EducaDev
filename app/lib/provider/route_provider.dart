import 'package:app/routes/routes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RouteProvider extends ChangeNotifier {
  // Création d'instances pour FirebaseAuth et Firestore
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  User? _user;
  bool? _isAdmin;

  RouteProvider() {
    _auth.authStateChanges().listen((user) {
      _user = user;
      checkAdminStatus();

      notifyListeners();
    });
  }

  Future<void> checkAdminStatus() async {
    if (_user != null) {
      DocumentSnapshot userDoc =
          await _db.collection('user').doc(_user?.uid).get();

      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>?;
        final String role = userData?['role'] ?? 'user';

        _isAdmin = role == 'admin';
        notifyListeners();
      }
    }
  }

  // Vérifie si l'utilisateur est connecté
  bool get isAuthenticated => _user != null;
  bool get isAdmin => _isAdmin ?? false;

  // Redirige vers la page de connexion si l'utilisateur n'est pas authentifié
  void redirectIfNotAuthenticated(BuildContext context) {
    if (!isAuthenticated) {
      FluroRouterSetup.router.navigateTo(context, "login");
    }
  }

  // Redirige vers une page "login" si l'utilisateur n'est pas admin
  Future<void> redirectIfNotAdmin(BuildContext context) async {
    redirectIfNotAuthenticated(context);

    if (_isAdmin == false) {
      FluroRouterSetup.router.navigateTo(context, "/");
    }
  }
}
