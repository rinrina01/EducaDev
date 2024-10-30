import 'package:cloud_firestore/cloud_firestore.dart';

class GraphService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<int>> getScoreDistribution() async {
    List<int> scoreCounts = List.filled(20, 0); // Initialiser un tableau avec 20 zéros

    try {
      QuerySnapshot querySnapshot = await _db.collection('score').get();
      for (var doc in querySnapshot.docs) {
        int score = doc['score']; // Assurez-vous que le score est un entier
        if (score >= 0 && score < 20) {
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
