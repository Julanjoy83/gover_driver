import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../appInfo/app_info.dart';
import '../auth/signin_page.dart';
import '../global.dart';
import '../methods/google_maps_methods.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Completer<GoogleMapController> googleMapCompleterController = Completer<GoogleMapController>();
  GoogleMapController? controllerGoogleMap;
  Position? currentPositionOfDriver;
  final GlobalKey<ScaffoldState> sKey = GlobalKey<ScaffoldState>();
  DatabaseReference? newTripRequestReference;
  double searchContainerHeight = 220;
  double bottomMapPadding = 0;
  bool isDriverAvailable = false;

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
          desiredAccuracy: LocationAccuracy.bestForNavigation
      );

      setState(() => currentPositionOfDriver = userPosition);

      LatLng userLatLng = LatLng(userPosition.latitude, userPosition.longitude);
      if (controllerGoogleMap != null) {
        await controllerGoogleMap!.animateCamera(
            CameraUpdate.newLatLngZoom(userLatLng, 15)
        );
      }

      await GoogleMapsMethods.convertGeographicCoOrdinatesIntoHumanReadableAddress(
          currentPositionOfDriver!,
          context
      );
      await getDriverInfoAndCheckBlockStatus();

    } catch (e) {
      associateMethods.showSnackBarMsg(e.toString(), context);
    }
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
          setState(() {
            driverName = driverData["name"];
            driverPhone = driverData["phone"];

            carColor = driverData["car_details"]["carColor"];
            carModel = driverData["car_details"]["carModel"];
            carNumber = driverData["car_details"]["carNumber"];



          });
        } else {
          await FirebaseAuth.instance.signOut();
          if (!mounted) return;
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (c) => const SigninPage())
          );
          associateMethods.showSnackBarMsg(
              "Votre compte a été bloqué. Contactez un administrateur.",
              context
          );
        }
      } else {
        await FirebaseAuth.instance.signOut();
        if (!mounted) return;
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (c) => const SigninPage())
        );
      }
    } catch (e) {
      associateMethods.showSnackBarMsg(e.toString(), context);
    }
  }

  goOnline() {
    //all drivers available for new trip requests
    Geofire.initialize("onlineDrivers");
    Geofire.setLocation(
      FirebaseAuth.instance.currentUser!.uid,
      currentPositionOfDriver!.latitude,
      currentPositionOfDriver!.longitude,
    );

    newTripRequestReference = FirebaseDatabase.instance.ref()
        .child("driver")
        .child(FirebaseAuth.instance.currentUser!.uid)
        .child("newTripStatus");

    newTripRequestReference!.set("waiting");
    newTripRequestReference!.onValue.listen((event){});
  }

  setandGetLocationUpdates()
  {
    positionStreamHomepage = Geolocator.getPositionStream().listen((Position position) {
      currentPositionOfDriver = position;
      if(isDriverAvailable == true )
        {
          Geofire.setLocation(
            FirebaseAuth.instance.currentUser!.uid,
            currentPositionOfDriver!.latitude,
            currentPositionOfDriver!.longitude,
          );
        }

      LatLng positionLatLng = LatLng(position.latitude, position.longitude);
      controllerGoogleMap!.animateCamera(CameraUpdate.newLatLng(positionLatLng));

    });
  }

  goOffline()
  {
    //stop sharing
    Geofire.removeLocation(FirebaseAuth.instance.currentUser!.uid);
    //stop listening
    newTripRequestReference!.onDisconnect();
    newTripRequestReference!.remove();
    newTripRequestReference = null;



  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: sKey,
      drawer: _buildDrawer(),
      body: Stack(
        children: [
          _buildGoogleMap(),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return SizedBox(
      width: 280,
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
        getCurrentLocation();
      },
    );
  }



}

class SelectDestinationPage {
  const SelectDestinationPage();
}

class UserInventoryPage {
  const UserInventoryPage();
}