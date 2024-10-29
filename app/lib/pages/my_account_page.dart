import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MyAccountPage extends StatefulWidget {
  const MyAccountPage({super.key});

  @override
  _MyAccountPageState createState() => _MyAccountPageState();
}

class _MyAccountPageState extends State<MyAccountPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? user;
  String? userName;
  String? userFname;

  @override
  void initState() {
    super.initState();
    _checkUser();
  }

  Future<void> _checkUser() async {
    user = _auth.currentUser;
    if (user != null) {
      await _fetchUserData();
    }
    setState(() {}); // Rebuild the UI
  }

  Future<void> _fetchUserData() async {
    try {
      DocumentSnapshot doc = await _firestore.collection('user').doc(user!.uid).get();
      if (doc.exists) {
        setState(() {
          userName = doc['name'];
          userFname = doc['firstName'];
        });
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  Future<void> _updateUserFname(String newFname) async {
    if (user != null) {
      try {
        await _firestore.collection('user').doc(user!.uid).update({
          'firstName': newFname,
        });
        // Met à jour l'état local
        setState(() {
          userFname = newFname;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('First name updated to $newFname')),
        );
      } catch (e) {
        print('Failed to update first name: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update first name: $e')),
        );
      }
    }
  }

  void _showUpdateFnameDialog() {
    final TextEditingController _fnameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Update First Name'),
          content: TextField(
            controller: _fnameController,
            decoration: InputDecoration(hintText: 'Enter new first name'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (_fnameController.text.isNotEmpty) {
                  _updateUserFname(_fnameController.text);
                  Navigator.of(context).pop();
                }
              },
              child: Text('Update'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Account')),
      body: Center(
        child: user != null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Welcome, ${userName ?? "User"} ${userFname ?? ""}!'), // Afficher le nom de l'utilisateur
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _showUpdateFnameDialog, // Ouvrir le formulaire de mise à jour
                    child: Text('Change First Name'),
                  ),
                ],
              )
            : Text('Please log in to view your account'),
      ),
    );
  }
}
