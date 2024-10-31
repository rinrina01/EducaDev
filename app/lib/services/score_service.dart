import 'package:cloud_firestore/cloud_firestore.dart';

class ScoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Ajouter un nouveau score de quiz
  Future<void> addScore(
    String userId, // ID de l'utilisateur
    int score, // Score total du quiz
    int quizLength, // Longueur du quiz (nombre de questions)
    String category, // Nom du quiz
  ) async {
    try {
      await _db.collection('score').add({
        'user': userId,
        'score': score, // Score total du quiz
        'quizLength': quizLength, // Longueur du quiz
        'category': category, // Nom du quiz
        'createdAt': FieldValue.serverTimestamp(), // Date de création
      });
    } catch (e) {
      print("Error adding quiz: $e");
      throw Exception("Failed to add quiz");
    }
  }

  // Récupérer les scores d'un utilisateur spécifique
  Future<List<Map<String, dynamic>>> getUserScore(String userId) async {
    try {
      QuerySnapshot querySnapshot =
          await _db.collection('score').where('user', isEqualTo: userId).get();

      List<Map<String, dynamic>> scores = querySnapshot.docs.map((doc) {
        return {
          'id': doc.id, // ID du document
          'score': doc['score'],
          'quizLength': doc['quizLength'],
          'category': doc['category'],
          'createdAt': doc['createdAt']?.toDate(), // Conversion en DateTime
        };
      }).toList();

      return scores; // Retourner la liste des scores
    } catch (e) {
      print("Error getting scores: $e");
      throw Exception("Failed to get scores");
    }
  }

  // Récupérer tous les scores d'utilisateurs
  Future<List<Map<String, dynamic>>> getAllUserScore() async {
    try {
      QuerySnapshot querySnapshot = await _db.collection('score').get();

      return querySnapshot.docs.map((doc) {
        return {
          'user': doc['user'],
          'category': doc['category'],
          'score': doc['score'],
          'quizLength': doc['quizLength'],
          'createdAt': (doc['createdAt'] as Timestamp?)
              ?.toDate(), // Conversion de Timestamp en DateTime
        };
      }).toList();
    } catch (e) {
      print("Error fetching all scores: $e");
      throw Exception("Failed to fetch all scores");
    }
  }

  // Récupérer les scores par catégorie
  Future<List<Map<String, dynamic>>> getScoreByCategory(String category) async {
    try {
      QuerySnapshot querySnapshot = await _db
          .collection('score')
          .where('category', isEqualTo: category)
          .get();

      return querySnapshot.docs.map((doc) {
        return {
          'user': doc['user'],
          'category': doc['category'],
          'score': doc['score'],
          'quizLength': doc['quizLength'],
          'createdAt': (doc['createdAt'] as Timestamp?)
              ?.toDate(), // Conversion de Timestamp en DateTime
        };
      }).toList();
    } catch (e) {
      print("Error fetching scores by category: $e");
      throw Exception("Failed to fetch scores by category");
    }
  }

  // Récupérer toutes les catégories
  Future<List<String>> getAllCategories() async {
    try {
      QuerySnapshot querySnapshot = await _db.collection('score').get();

      // Utiliser un ensemble pour éviter les doublons
      Set<String> categories = {};

      for (var doc in querySnapshot.docs) {
        String? category = doc['category'];
        if (category != null) {
          categories.add(category);
        }
      }

      return categories.toList(); // Retourner la liste des catégories
    } catch (e) {
      print("Error fetching categories: $e");
      throw Exception("Failed to get categories");
    }
  }
}
