import 'package:cloud_firestore/cloud_firestore.dart';

class ScoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Add a new quiz
  Future<void> addScore(
    String userId, // ID de l'utilisateur
    int score, // Score total du quiz
    int quizLength, // Longueur du quiz (nombre de questions)
    String category // Nom du quiz
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


  Future<List<Map<String, dynamic>>> getUserScore(String userId) async {
  try {
    QuerySnapshot querySnapshot = await _db.collection('score').where('user', isEqualTo: userId).orderBy('createdAt', descending: false).get();

    List<Map<String, dynamic>> scores = querySnapshot.docs.map((doc) {
      return {
        'id': doc.id, // ID du document
        'score': doc['score'],
        'quizLength': doc['quizLength'],
        'category': doc['category'],
        'createdAt': doc['createdAt']?.toDate(), // Convertir en DateTime
      };
    }).toList();

    return scores; // Retourner la liste des scores
  } catch (e) {
    print("Error getting scores: $e");
    throw Exception("Failed to get scores");
  }
}

Future<List<Map<String, dynamic>>> getAllUserScore() async {
  try {
    QuerySnapshot querySnapshot = await _db.collection('score').orderBy('createdAt', descending: false).get();

    return querySnapshot.docs.map((doc) {
      return {
        'user': doc['user'],
        'category': doc['category'], 
        'score': doc['score'],
        'quizLength': doc['quizLength'],
        'createdAt': (doc['createdAt'] as Timestamp?)?.toDate(), // Conversion de Timestamp en DateTime
      };
    }).toList();
  } catch (e) {
    print("Error fetching all scores: $e");
    throw Exception("Failed to fetch all scores");
  }
}
}
