import 'package:app/main_layout.dart';
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
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  // Variable pour stocker la sélection unique
  String _selectedMotivation = 'Poursuite d\'études';

  @override
  void dispose() {
    _nameController.dispose();
    _firstNameController.dispose();
    _ageController.dispose();
    _addressController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Attempting to register...')),
      );

      try {
        final credential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        if (credential.user != null) {
          FirebaseFirestore db = FirebaseFirestore.instance;
          final user = <String, dynamic>{
            "name": _nameController.text.trim(),
            "firstName": _firstNameController.text.trim(),
            "age": int.parse(_ageController.text.trim()),
            "address": _addressController.text.trim(),
            "motivation":
                _selectedMotivation, // Enregistre la motivation choisie
            "email": _emailController.text.trim(),
            "userId": credential.user!.uid,
            "role": "user"
          };
          await db.collection("user").doc(credential.user!.uid).set(user);
          FluroRouterSetup.router.navigateTo(context, "/");
        }
      } on FirebaseAuthException catch (e) {
        // Gestion des erreurs d'inscription
        String errorMessage;
        if (e.code == 'email-already-in-use') {
          errorMessage =
              'The email address is already in use by another account.';
        } else if (e.code == 'invalid-email') {
          errorMessage = 'The email address is not valid.';
        } else if (e.code == 'weak-password') {
          errorMessage = 'The password provided is too weak.';
        } else {
          errorMessage = 'Registration failed: ${e.message}';
        }
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(errorMessage)));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('An unknown error occurred.')),
        );
      }
    }
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
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
              keyboardType: TextInputType.text,
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
              keyboardType: TextInputType.text,
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
              controller: _addressController,
              decoration: const InputDecoration(labelText: 'Address'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your address';
                }
                return null;
              },
              keyboardType: TextInputType.text,
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
              keyboardType: TextInputType.emailAddress,
            ),
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                suffixIcon: IconButton(
                  icon: Icon(_obscurePassword
                      ? Icons.visibility
                      : Icons.visibility_off),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
              obscureText: _obscurePassword,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your password';
                }
                if (value.length < 8) {
                  return 'Password must be at least 8 characters long';
                }
                if (!RegExp(r'[A-Z]').hasMatch(value)) {
                  return 'Password must contain at least one uppercase letter';
                }
                if (!RegExp(r'[a-z]').hasMatch(value)) {
                  return 'Password must contain at least one lowercase letter';
                }
                if (!RegExp(r'[0-9]').hasMatch(value)) {
                  return 'Password must contain at least one digit';
                }
                if (!RegExp(r'[!@#\$&*~]').hasMatch(value)) {
                  return 'Password must contain at least one special character (!@#\$&*~)';
                }
                return null;
              },
              keyboardType: TextInputType.visiblePassword,
            ),
            const SizedBox(height: 20),
            Text("Sélectionnez votre motivation :"),
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
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitForm,
              child: const Text('Register'),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                FluroRouterSetup.router.navigateTo(context, "login");
              },
              child: const Text("Already have an account? Login here"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: "Register",
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: _buildForm(),
      ),
    );
  }
}
