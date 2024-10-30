import 'package:app/routes/routes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RouteProvider extends ChangeNotifier {
  // Création d'instances pour FirebaseAuth et Firestore
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  User? _user;

  RouteProvider() {
    // Écoute les changements d'état d'authentification
    _auth.authStateChanges().listen((user) {
      _user = user; // Met à jour l'utilisateur connecté
      notifyListeners(); // Notifie les widgets qui écoutent les changements
    });
  }

  // Vérifie si l'utilisateur est connecté
  bool get isAuthenticated => _user != null;

  // Redirige vers la page de connexion si l'utilisateur n'est pas authentifié
  void redirectIfNotAuthenticated(BuildContext context) {
    if (!isAuthenticated) {
      FluroRouterSetup.router.navigateTo(context, "login");
    }
  }

  // Redirige vers une page "login" si l'utilisateur n'est pas admin
  Future<void> redirectIfNotAdmin(BuildContext context) async {
    redirectIfNotAuthenticated(context);

    // Récupère les données de l'utilisateur depuis Firestore
    DocumentSnapshot userDoc =
        await _db.collection('user').doc(_user?.uid).get();

    // Vérifie si le document utilisateur existe
    if (userDoc.exists) {
      // Convertit les données du document en Map pour l'accès aux champs
      final userData = userDoc.data() as Map<String, dynamic>?;

      // Récupère le rôle de l'utilisateur, avec un rôle par défaut de 'user'
      final String role = userData?['role'] ?? 'user';

      if (role != 'admin') {
        // Si l'utilisateur n'est pas admin, redirige vers la page de connexion
        FluroRouterSetup.router.navigateTo(context, "login");
      }
    } else {
      // Si le document utilisateur n'existe pas, redirige vers la page de connexion
      FluroRouterSetup.router.navigateTo(context, "login");
    }
  }
}
