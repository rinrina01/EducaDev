import 'package:cloud_firestore/cloud_firestore.dart';

class GraphService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<int>> getScoreDistribution(String category) async {
    try {
      // Récupérer un document pour obtenir le quizLength
      QuerySnapshot quizSnapshot = await _db.collection('score').where('category', isEqualTo: category).limit(1).get();

      if (quizSnapshot.docs.isEmpty) {
        throw Exception("No scores found for the given category");
      }

      // Supposons que nous utilisons le premier document pour obtenir quizLength
      int quizLength = quizSnapshot.docs.first['quizLength'];

      // Initialiser le tableau avec quizLength + 1 (pour inclure le score maximum)
      List<int> scoreCounts = List.filled(quizLength + 1, 0); // Initialiser un tableau avec zeros

      // Récupérer tous les scores de la catégorie
      QuerySnapshot querySnapshot = await _db.collection('score').where('category', isEqualTo: category).get();
      for (var doc in querySnapshot.docs) {
        int score = doc['score']; // Assurez-vous que le score est un entier
        if (score >= 0 && score <= quizLength) {
          scoreCounts[score]++; // Incrémentez le compteur pour le score
        }
      }
      return scoreCounts; // Retourner la liste des comptes de score
    } catch (e) {
      print("Error fetching scores: $e");
      throw Exception("Failed to get score distribution");
    }
  }
}

