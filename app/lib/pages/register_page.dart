import 'package:app/routes/routes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _firstNameController.dispose();
    _ageController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Form submitted successfully!')),
      );

      try {
        final credential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );

        if (credential.user != null) {
          FirebaseFirestore db = FirebaseFirestore.instance;
          final user = <String, String>{
            "name": _nameController.text,
            "firstName": _firstNameController.text,
            "age": _ageController.text,
            "email": _emailController.text,
            "userId": credential.user!.uid,
          };
          await db.collection("user").doc(credential.user!.uid).set(user);
          FluroRouterSetup.router.navigateTo(
            context,
            "/my-account",  /// A MODIFIER !!!!
          );
        }
      } on FirebaseAuthException catch (e) {
        if (e.code == 'email-already-in-use') {
          print('The email address is already in use by another account.');
        } else if (e.code == 'invalid-email') {
          print('The email address is not valid.');
        } else if (e.code == 'weak-password') {
          print('The password provided is too weak.');
        } else {
          print('Failed with error code: ${e.code}');
          print(e.message);
        }
      } catch (e) {
        print('An unknown error occurred. $e');
      }
    }
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _firstNameController,
            decoration: const InputDecoration(labelText: 'First Name'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your first name';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Last Name'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your last name';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _ageController,
            decoration: const InputDecoration(labelText: 'Age'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your age';
              }
              if (int.tryParse(value) == null || int.parse(value) <= 0) {
                return 'Please enter a valid age';
              }
              return null;
            },
            keyboardType: TextInputType.number,
          ),
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(labelText: 'Email'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                return 'Please enter a valid email address';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _passwordController,
            decoration: const InputDecoration(labelText: 'Password'),
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your password';
              }
              if (value.length < 6) {
                return 'Password must be at least 6 characters long';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          Center(
            child: ElevatedButton(
              onPressed: _submitForm,
              child: const Text('Register'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: _buildForm(),
      ),
    );
  }
}
