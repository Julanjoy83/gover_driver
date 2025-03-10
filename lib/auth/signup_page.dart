import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Pour rootBundle
import 'package:gover_driver_app/auth/signin_page.dart';
import '../global.dart';
import '../pages/home_page.dart';
import '../widgets/loading_dialog.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({Key? key}) : super(key: key);

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  // Contrôleurs pour les champs d'inscription
  TextEditingController userNameTextEditingController = TextEditingController();
  TextEditingController userPhoneTextEditingController = TextEditingController();
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();
  TextEditingController vehicleColorTextEditingController = TextEditingController();
  // On n'utilise plus ce controller pour le modèle puisque l'on utilise le dropdown
  // TextEditingController vehicleModelTextEditingController = TextEditingController();
  TextEditingController vehicleNumberTextEditingController = TextEditingController();

  // Variables pour le Dropdown
  List<dynamic> carModels = [];
  String? selectedCarModel;
  String? selectedTrunkCapacity; // Capacité du coffre en m³ (sous forme de String)

  @override
  void initState() {
    super.initState();
    loadCarModels();
  }

  Future<void> loadCarModels() async {
    // Charger le fichier JSON depuis assets
    String jsonString = await rootBundle.loadString('assets/json/car_models.json');
    setState(() {
      carModels = json.decode(jsonString);
    });
  }

  void onCarModelChanged(String? newValue) {
    if (newValue == null) return;
    setState(() {
      selectedCarModel = newValue;
      // Recherche du modèle sélectionné dans la liste
      final selectedModel = carModels.firstWhere(
            (model) => model['modèle'] == newValue,
        orElse: () => null,
      );
      if (selectedModel != null) {
        var volume = selectedModel['volume_coffre_m3'];
        // Si le volume est un nombre, on l'utilise directement
        if (volume is num) {
          selectedTrunkCapacity = volume.toString();
        } else if (volume is Map) {
          // Si c'est un objet, on choisit ici la version "essence" par défaut
          selectedTrunkCapacity = volume['version_essence']?.toString() ?? "";
        } else {
          selectedTrunkCapacity = "";
        }
      } else {
        selectedTrunkCapacity = "";
      }
    });
  }

  void validateSignUpForm() {
    if (userNameTextEditingController.text.trim().length < 3) {
      associateMethods.showSnackBarMsg("Le nom doit comporter au moins 3 caractères", context);
    } else if (userPhoneTextEditingController.text.trim().length != 10) {
      associateMethods.showSnackBarMsg("Le numéro de téléphone doit contenir 10 chiffres", context);
    } else if (!emailTextEditingController.text.contains("@")) {
      associateMethods.showSnackBarMsg("L'adresse email n'est pas valide", context);
    } else if (selectedCarModel == null || selectedCarModel!.isEmpty) {
      associateMethods.showSnackBarMsg("Veuillez sélectionner un modèle de véhicule", context);
    } else if (vehicleColorTextEditingController.text.trim().isEmpty) {
      associateMethods.showSnackBarMsg("Veuillez saisir une couleur de véhicule", context);
    } else if (vehicleNumberTextEditingController.text.trim().isEmpty) {
      associateMethods.showSnackBarMsg("Veuillez saisir une immatriculation", context);
    } else {
      signUserNow();
    }
  }

  signUserNow() async {
    showDialog(
      context: context,
      builder: (BuildContext context) =>
          LoadingDialog(messageText: "Inscription en cours..."),
    );

    try {
      final User? firebaseUser = (await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: emailTextEditingController.text.trim(),
        password: passwordTextEditingController.text.trim(),
      ).catchError((onError) {
        Navigator.pop(context);
        associateMethods.showSnackBarMsg(onError.toString(), context);
      }))
          .user;

      // Créer la map avec les infos de la voiture
      Map carDataMap = {
        "carColor": vehicleColorTextEditingController.text.trim(),
        "carModel": selectedCarModel ?? "",
        "carNumber": vehicleNumberTextEditingController.text.trim(),
        "trunk_capacity": selectedTrunkCapacity ?? ""
      };

      if (firebaseUser != null) {
        Map driverDataMap = {
          "name": userNameTextEditingController.text.trim(),
          "email": emailTextEditingController.text.trim(),
          "phone": userPhoneTextEditingController.text.trim(),
          "id": firebaseUser.uid,
          "blockstatus": "no",
          "car_details": carDataMap,
        };

        await FirebaseDatabase.instance
            .ref()
            .child("drivers")
            .child(firebaseUser.uid)
            .set(driverDataMap);

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
                style: TextStyle(fontSize: 26),
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
                        labelText: "Nom d'utilisateur",
                        labelStyle: TextStyle(fontSize: 14),
                      ),
                      style: const TextStyle(
                        color: Colors.deepPurple,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 22),
                    // Dropdown pour le modèle de véhicule
                    carModels.isEmpty
                        ? const CircularProgressIndicator()
                        : DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: "Modèle du véhicule",
                        labelStyle: TextStyle(fontSize: 14),
                      ),
                      value: selectedCarModel,
                      items: carModels.map<DropdownMenuItem<String>>((model) {
                        return DropdownMenuItem<String>(
                          value: model['modèle'],
                          child: Text(model['modèle']),
                        );
                      }).toList(),
                      onChanged: onCarModelChanged,
                    ),
                    const SizedBox(height: 22),
                    // Champ en lecture seule pour afficher la capacité du coffre
                    TextField(
                      decoration: const InputDecoration(
                        labelText: "Capacité du coffre (m³)",
                        labelStyle: TextStyle(fontSize: 14),
                      ),
                      controller: TextEditingController(text: selectedTrunkCapacity),
                      readOnly: true,
                      style: const TextStyle(
                        color: Colors.deepPurple,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 22),
                    // Champ pour saisir la couleur du véhicule
                    TextField(
                      controller: vehicleColorTextEditingController,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        labelText: "Couleur du véhicule",
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
                        labelText: "Immatriculation",
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
                        labelStyle: TextStyle(fontSize: 14),
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
                  style: TextStyle(color: Colors.deepPurple),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
