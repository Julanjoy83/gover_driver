import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'methods/associate_methods.dart';

AssociateMethods associateMethods = AssociateMethods();

String driverName = "";
String driverPhone = "";
String carColor = "";
String carModel = "";
String carNumber = "";




String googleMapKey = "AIzaSyBx78gcwV3hSAoNIZxQAbYTx2AJ8ik5wVw";

const CameraPosition kGooglePlex = CameraPosition(
  target: LatLng(37.42796133580664, -122.085749655962),
  zoom: 14.4746,
);

StreamSubscription<Position>? positionStreamHomepage;