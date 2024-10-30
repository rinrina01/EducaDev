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
  String? userAge;
  String? userMotiv;
  String? userMail;
  String? userAdress;

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
      print('Document data: ${doc.data()}');
      if (doc.exists) {
        setState(() {
          userName = doc['name'];
          userFname = doc['firstName'];
          userAge = doc['age'].toString();
          userMotiv = doc['motivation'];
          userMail = doc['email'];
          userAdress = doc['address'];
        });
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  Future<void> _updateUserAddress(String newAddress) async {
    if (user != null) {
      try {
        await _firestore.collection('user').doc(user!.uid).update({
          'address': newAddress,
        });
        // Met à jour l'état local
        setState(() {
          userAdress = newAddress;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Address updated to $newAddress')),
        );
      } catch (e) {
        print('Failed to update address: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update address: $e')),
        );
      }
    }
  }

  void _showUpdateAddressDialog() {
    final TextEditingController _addressController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Update Address'),
          content: TextField(
            controller: _addressController,
            decoration: const InputDecoration(hintText: 'Enter new address'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (_addressController.text.isNotEmpty) {
                  _updateUserAddress(_addressController.text);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  // Fonction pour afficher le formulaire de motivation en pop-up
  void _showUpdateMotivationDialog() {
    String _selectedMotivation = userMotiv ?? "Poursuite d'études" ;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Choose your motivation and click on change"),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                RadioListTile(
                  title: const Text("Poursuite d'études"),
                  value: "Poursuite d'études",
                  groupValue: _selectedMotivation,
                  onChanged: (value) {
                    setState(() {
                      _selectedMotivation = value.toString();
                    });
                  },
                ),
                RadioListTile(
                  title: const Text("Réorientation"),
                  value: "Réorientation",
                  groupValue: _selectedMotivation,
                  onChanged: (value) {
                    setState(() {
                      _selectedMotivation = value.toString();
                    });
                  },
                ),
                RadioListTile(
                  title: const Text("Reconversion"),
                  value: "Reconversion",
                  groupValue: _selectedMotivation,
                  onChanged: (value) {
                    setState(() {
                      _selectedMotivation = value.toString();
                    });
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                _updateUserMotivation(_selectedMotivation); // Met à jour la motivation sélectionnée
                Navigator.of(context).pop(); // Ferme la boîte de dialogue
              },
              child: const Text("Change"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Ferme la boîte de dialogue sans faire de changement
              },
              child: const Text("Annuler"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateUserMotivation(String newMotivation) async {
    if (user != null) {
      try {
        await _firestore.collection('user').doc(user!.uid).update({
          'motivation': newMotivation,
        });
        // Met à jour l'état local
        setState(() {
          userMotiv = newMotivation;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Motivation updated to $newMotivation')),
        );
      } catch (e) {
        print('Failed to update motivation: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update motivation: $e')),
        );
      }
    }
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
                  Text('Welcome, ${userName ?? "User"} ${userFname ?? ""}!'),
                  Text('Age: $userAge'),
                  Text('Mail: $userMail'),
                  Text('Address: $userAdress'),
                  Text('Motivation: $userMotiv'),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _showUpdateAddressDialog, // Ouvrir le formulaire de mise à jour
                    child: const Text('Change Address'),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _showUpdateMotivationDialog, // Ouvrir le formulaire de mise à jour de motivation
                    child: const Text('Change Motivation'),
                  ),
                ],
              )
            : const Text('Please log in to view your account'),
      ),
    );
  }
}
