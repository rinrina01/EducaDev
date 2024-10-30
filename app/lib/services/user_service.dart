import 'package:cloud_firestore/cloud_firestore.dart';


class UserService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;



  Future<Map<String, dynamic>?> getUserData(String userId) async {
  try {
    DocumentSnapshot doc = await _db.collection('user').doc(userId).get();

    if (doc.exists) {
      return doc.data() as Map<String, dynamic>;
    } else {
      print('No user found with this ID');
      return null;
    }
  } catch (e) {
    print("Error fetching user data: $e");
    throw Exception("Failed to get user data");
  }
}

}

