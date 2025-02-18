import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:gover_driver_app/auth/signup_page.dart';
import 'package:gover_driver_app/pages/dashboard.dart';

import '../global.dart';
import '../pages/home_page.dart';


class SigninPage extends StatefulWidget {
  const SigninPage({super.key});

  @override
  State<SigninPage> createState() => _SigninPageState();
}

class _SigninPageState extends State<SigninPage> {
  final TextEditingController emailTextEditingController = TextEditingController();
  final TextEditingController passwordTextEditingController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  void validateSignInForm() {
    if (!emailTextEditingController.text.contains("@")) {
      associateMethods.showSnackBarMsg("Email non valide", context);
    } else if (passwordTextEditingController.text.trim().length < 5) {
      associateMethods.showSnackBarMsg("Le mot de passe doit contenir au moins 5 caractères", context);
    } else {
      signInUserNow();
    }
  }

  Future<void> signInUserNow() async {
    if (!mounted) return;

    setState(() => _isLoading = true);

    try {
      final User? firebaseUser = (await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailTextEditingController.text.trim(),
        password: passwordTextEditingController.text.trim(),
      )).user;

      if (firebaseUser != null) {
        final ref = FirebaseDatabase.instance.ref().child("drivers").child(firebaseUser.uid);
        final dataSnapshot = await ref.once();

        if (dataSnapshot.snapshot.value != null) {
          Map userData = dataSnapshot.snapshot.value as Map;

          if (userData["blockstatus"] == "no") {
            driverName = userData["name"];
            driverPhone = userData["phone"];

            if (mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (c) => const Dashboard()),
              );
              associateMethods.showSnackBarMsg("Re bienvenue !", context);
            }
          } else {
            FirebaseAuth.instance.signOut();
            if (mounted) {
              associateMethods.showSnackBarMsg(
                  "Votre compte a été banni, veuillez contacter le support.",
                  context
              );
            }
          }
        } else {
          FirebaseAuth.instance.signOut();
          if (mounted) {
            associateMethods.showSnackBarMsg("Ce compte n'existe pas !", context);
          }
        }
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        FirebaseAuth.instance.signOut();
        associateMethods.showSnackBarMsg(e.message ?? "Erreur inconnue", context);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                Image.asset(
                  "assets/goverlogo.png",
                  height: 200,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 32),
                const Text(
                  "Bienvenue",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Connectez-vous pour continuer en tant que conducteur",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 48),
                TextFormField(
                  controller: emailTextEditingController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: "Email",
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: passwordTextEditingController,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    labelText: "Mot de passe",
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading ? null : validateSignInForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                      : const Text(
                    "Se connecter",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Vous n'avez pas de compte ?",
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (c) => const SignupPage()),
                        );
                      },
                      child: const Text(
                        "S'inscrire",
                        style: TextStyle(
                          color: Colors.deepPurple,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}