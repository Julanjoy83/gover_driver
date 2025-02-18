import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:gover_driver_app/auth/signin_page.dart';


import '../global.dart';
import '../pages/home_page.dart';
import '../widgets/loading_dialog.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  TextEditingController userNameTextEditingController = TextEditingController();
  TextEditingController userPhoneTextEditingController = TextEditingController();
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();
  TextEditingController vehicleColorTextEditingController = TextEditingController();
  TextEditingController vehicleModelTextEditingController = TextEditingController();
  TextEditingController vehicleNumberTextEditingController = TextEditingController();


  validateSignUpForm() {
    if (userNameTextEditingController.text.trim().length < 3) {
      associateMethods.showSnackBarMsg("name must be at least 3 characters", context);
    } else if (userPhoneTextEditingController.text.trim().length != 10) {
      associateMethods.showSnackBarMsg("phone number must be 10 digits", context);
    } else if (!emailTextEditingController.text.contains("@")) {
      associateMethods.showSnackBarMsg("Email is not valid", context);
    } else if (vehicleModelTextEditingController.text.trim(). isEmpty) {
      associateMethods.showSnackBarMsg("veuillez saisir un model de véhicule", context);
    }   else if (vehicleColorTextEditingController.text.trim(). isEmpty) {
      associateMethods.showSnackBarMsg("veuillez saisir une couleur de véhicule", context);
    }
    else if (vehicleColorTextEditingController.text.trim(). isEmpty) {
      associateMethods.showSnackBarMsg("veuillez saisir un matricule", context);
    }

    else {
      signUserNow();
    }
  }

  signUserNow() async {
    showDialog(
      context: context,
      builder: (BuildContext context) => LoadingDialog(messageText: "Inscription en cours..."),
    );

    try {
      final User? firebaseUser = (await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: emailTextEditingController.text.trim(),
        password: passwordTextEditingController.text.trim(),
      )
          .catchError((onError) {
        Navigator.pop(context);
        associateMethods.showSnackBarMsg(onError.toString(), context);
      }))
          .user;
        Map carDataMap = {
          "carColor" : vehicleColorTextEditingController.text.trim(),
          "carModel" : vehicleModelTextEditingController.text.trim(),
          "carNumber" : vehicleNumberTextEditingController.text.trim(),
        };
      if (firebaseUser != null) {
        Map driverDataMap = {
          "name": userNameTextEditingController.text.trim(),
          "email": emailTextEditingController.text.trim(),
          "phone": userPhoneTextEditingController.text.trim(),
          "id": firebaseUser.uid,
          "blockstatus": "no",
          "car_details" : carDataMap,
        };

        await FirebaseDatabase.instance.ref().child("drivers").child(firebaseUser.uid).set(driverDataMap);

        Navigator.pop(context);
        associateMethods.showSnackBarMsg("Bienvenue parmi nous !", context);
        Navigator.push(context, MaterialPageRoute(builder: (c) => const HomePage()));

      } else {
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      FirebaseAuth.instance.signOut();
      associateMethods.showSnackBarMsg(e.message ?? "Erreur inconnue", context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              const SizedBox(height: 122),
              Image.asset(
                "assets/goverlogo.png",
                width: MediaQuery.of(context).size.width * .65,
              ),
              const Text(
                "Créer un nouveau compte",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                ),
              ),
              const SizedBox(height: 120),
              Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  children: [
                    TextField(
                      controller: emailTextEditingController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: "Adresse Email",
                        labelStyle: TextStyle(fontSize: 14),
                      ),
                      style: const TextStyle(
                        color: Colors.deepPurple,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 22),
                    TextField(
                      controller: userNameTextEditingController,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        labelText: "Nom d'utilisateur ",
                        labelStyle: TextStyle(fontSize: 14),
                      ),
                      style: const TextStyle(
                        color: Colors.deepPurple,
                        fontSize: 15,
                      ),
                    ),


                    const SizedBox(height: 22),
                    TextField(
                      controller: vehicleModelTextEditingController,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        labelText: "modele du véhicule ",
                        labelStyle: TextStyle(fontSize: 14),
                      ),
                      style: const TextStyle(
                        color: Colors.deepPurple,
                        fontSize: 15,
                      ),
                    ),





                    const SizedBox(height: 22),
                    TextField(
                      controller: vehicleNumberTextEditingController,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        labelText: "Immatriculation ",
                        labelStyle: TextStyle(fontSize: 14),
                      ),
                      style: const TextStyle(
                        color: Colors.deepPurple,
                        fontSize: 15,
                      ),
                    ),


















                    const SizedBox(height: 22),
                    TextField(
                      controller: userPhoneTextEditingController,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        labelText: "Mobile",
                        labelStyle: TextStyle(fontSize: 14),
                      ),
                      style: const TextStyle(
                        color: Colors.deepPurple,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 22),
                    TextField(
                      controller: passwordTextEditingController,
                      obscureText: true,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        labelText: "Mot de passe",
                        labelStyle: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                      style: const TextStyle(
                        color: Colors.deepPurple,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: () {
                        validateSignUpForm();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 10),
                      ),
                      child: const Text(
                        "Créer mon compte",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (c) => const SigninPage()));
                },
                child: const Text(
                  "Vous avez déjà un compte ? Identifiez-vous !",
                  style: TextStyle(
                    color: Colors.deepPurple,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}