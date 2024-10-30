import 'package:cloud_firestore/cloud_firestore.dart';

class QuizService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Add a new quiz
  Future<void> addQuiz(
      String category, List<Map<String, dynamic>> questions) async {
    try {
      await _db.collection('quizzes').add({
        'category': category,
        'questions': questions,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Error adding quiz: $e");
      throw Exception("Failed to add quiz");
    }
  }

  // Retrieve all quizzes with their document IDs
  Future<List<Map<String, dynamic>>> getQuizzes() async {
    try {
      final querySnapshot = await _db.collection('quizzes').get();
      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id; // Include document ID
        return data;
      }).toList();
    } catch (e) {
      print("Error retrieving quizzes: $e");
      throw Exception("Failed to retrieve quizzes");
    }
  }

  // Update a quiz
  Future<void> updateQuiz(String quizId, String category,
      List<Map<String, dynamic>> questions) async {
    try {
      await _db.collection('quizzes').doc(quizId).update({
        'category': category,
        'questions': questions,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Error updating quiz: $e");
      throw Exception("Failed to update quiz");
    }
  }

  // Delete a quiz
  Future<void> deleteQuiz(String quizId) async {
    try {
      await _db.collection('quizzes').doc(quizId).delete();
    } catch (e) {
      print("Error deleting quiz: $e");
      throw Exception("Failed to delete quiz");
    }
  }
}
