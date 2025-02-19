import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:gover_driver_app/push_notification/push_notification_service.dart';
// import 'package:provider/provider.dart'; // If needed
import '../auth/signin_page.dart';
import '../global.dart';
import '../methods/google_maps_methods.dart';
import '../permissions/permission.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Google Maps
  final Completer<GoogleMapController> googleMapCompleterController =
  Completer<GoogleMapController>();
  GoogleMapController? controllerGoogleMap;

  // Driver location
  Position? currentPositionOfDriver;

  // For drawer
  final GlobalKey<ScaffoldState> sKey = GlobalKey<ScaffoldState>();

  // Realtime Database references
  DatabaseReference? newTripRequestReference;

  // Layout
  double bottomMapPadding = 0;

  // Driver availability
  bool isDriverAvailable = false;

  PermissionMethods permissionMethods = PermissionMethods();



  // Initial camera position
  static const CameraPosition initialCameraPosition = CameraPosition(
    target: LatLng(0.0, 0.0),
    zoom: 14,
  );

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
  }

  Future<void> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw 'Les services de localisation sont désactivés.';
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw 'L\'autorisation de localisation a été refusée.';
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw 'L\'accès à la localisation est définitivement refusé.';
      }

      Position userPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation,
      );

      setState(() => currentPositionOfDriver = userPosition);

      LatLng userLatLng = LatLng(userPosition.latitude, userPosition.longitude);
      if (controllerGoogleMap != null) {
        await controllerGoogleMap!.animateCamera(
          CameraUpdate.newLatLngZoom(userLatLng, 15),
        );
      }

      // Convert position to address
      await GoogleMapsMethods.convertGeographicCoOrdinatesIntoHumanReadableAddress(
        currentPositionOfDriver!,
        context,
      );

      // Retrieve driver info and check block status
      await getDriverInfoAndCheckBlockStatus();
    } catch (e) {
      associateMethods.showSnackBarMsg(e.toString(), context);
    }
    await initializePushNotificationSystem();

    await permissionMethods.askNotificationPermission();

  }

  Future<void> getDriverInfoAndCheckBlockStatus() async {
    try {
      DatabaseReference reference = FirebaseDatabase.instance
          .ref()
          .child("drivers")
          .child(FirebaseAuth.instance.currentUser!.uid);

      final dataSnap = await reference.once();
      if (dataSnap.snapshot.value != null) {
        final driverData = dataSnap.snapshot.value as Map;

        if (driverData["blockstatus"] == "no") {
          // Example: store data in variables or global
          setState(() {
            driverName = driverData["name"];
            driverPhone = driverData["phone"];

            carColor = driverData["car_details"]["carColor"];
            carModel = driverData["car_details"]["carModel"];
            carNumber = driverData["car_details"]["carNumber"];
          });
        } else {
          // Driver is blocked
          await FirebaseAuth.instance.signOut();
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (c) => const SigninPage()),
          );
          associateMethods.showSnackBarMsg(
            "Votre compte a été bloqué. Contactez un administrateur.",
            context,
          );
        }
      } else {
        // No data => sign out
        await FirebaseAuth.instance.signOut();
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (c) => const SigninPage()),
        );
      }
    } catch (e) {
      associateMethods.showSnackBarMsg(e.toString(), context);
    }
  }

  // Mark driver as online in Geofire
  void goOnline() {
    // Initialize the "onlineDrivers" node
    Geofire.initialize("onlineDrivers");
    // Set the driver's current location
    if (currentPositionOfDriver != null) {
      Geofire.setLocation(
        FirebaseAuth.instance.currentUser!.uid,
        currentPositionOfDriver!.latitude,
        currentPositionOfDriver!.longitude,
      );
    }

    // Mark the driver as waiting for trip requests
    newTripRequestReference = FirebaseDatabase.instance
        .ref()
        .child("driver")
        .child(FirebaseAuth.instance.currentUser!.uid)
        .child("newTripStatus");

    newTripRequestReference!.set("waiting");
    newTripRequestReference!.onValue.listen((event) {});
  }

  // Start location updates for driver
  void setandGetLocationUpdates() {
    positionStreamHomepage = Geolocator.getPositionStream().listen((Position position) {
      currentPositionOfDriver = position;

      if (isDriverAvailable) {
        Geofire.setLocation(
          FirebaseAuth.instance.currentUser!.uid,
          position.latitude,
          position.longitude,
        );
      }

      LatLng positionLatLng = LatLng(position.latitude, position.longitude);
      controllerGoogleMap?.animateCamera(
        CameraUpdate.newLatLng(positionLatLng),
      );
    });
  }

  // Mark driver as offline in Geofire
  void goOffline() {
    // Remove location from Geofire
    Geofire.removeLocation(FirebaseAuth.instance.currentUser!.uid);

    // Stop listening
    if (newTripRequestReference != null) {
      newTripRequestReference!.onDisconnect();
      newTripRequestReference!.remove();
      newTripRequestReference = null;
    }
  }



  initializePushNotificationSystem()
  {
    PushNotificationService notificationService = PushNotificationService();
    notificationService.generateDeviceRecognitionToken();
    notificationService.startListeningForNewNotification(context);
  }





  /// Shows a bottom sheet to confirm going Online or Offline
  void showAvailabilityConfirmationSheet() {
    // If currently offline => confirm going online
    String title = isDriverAvailable ? "Go Offline?" : "Go Online?";
    String description = isDriverAvailable
        ? "Are you sure you want to go OFFLINE? Passengers won't be able to request you."
        : "Are you sure you want to go ONLINE? You'll start receiving trip requests.";
    String confirmBtnText = isDriverAvailable ? "Yes, Go Offline" : "Yes, Go Online";

    showModalBottomSheet(
      context: context,
      builder: (BuildContext ctx) {
        return Container(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                description,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Cancel button
                  OutlinedButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text("Cancel"),
                  ),
                  // Confirm button
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(ctx).pop(); // Close the sheet
                      toggleDriverAvailability();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDriverAvailable ? Colors.red : Colors.green,
                    ),
                    child: Text(confirmBtnText),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  /// The method that actually toggles the driver's availability
  void toggleDriverAvailability() {
    if (isDriverAvailable) {
      // GO OFFLINE
      goOffline();
      setState(() => isDriverAvailable = false);
    } else {
      // GO ONLINE
      goOnline();
      setandGetLocationUpdates();
      setState(() => isDriverAvailable = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: sKey,
      drawer: _buildDrawer(),
      body: Stack(
        children: [
          _buildGoogleMap(),

          // GO ONLINE/OFFLINE BUTTON
          Positioned(
            top: 60,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDriverAvailable ? Colors.red : Colors.green,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                onPressed: showAvailabilityConfirmationSheet,
                child: Text(
                  isDriverAvailable ? "Go Offline" : "Go Online",
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return SizedBox(
      width: 280,
      // Populate your drawer items...
    );
  }

  Widget _buildGoogleMap() {
    return GoogleMap(
      padding: EdgeInsets.only(top: 26, bottom: bottomMapPadding),
      mapType: MapType.normal,
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
      zoomGesturesEnabled: true,
      zoomControlsEnabled: true,
      initialCameraPosition: initialCameraPosition,
      onMapCreated: (GoogleMapController mapController) {
        controllerGoogleMap = mapController;
        googleMapCompleterController.complete(controllerGoogleMap);
        // After map is created, fetch location
        getCurrentLocation();
      },
    );
  }
}
