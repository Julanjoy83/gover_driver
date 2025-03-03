import 'package:google_maps_flutter/google_maps_flutter.dart';

class TripDetails
{
  String? tripID;
  LatLng? pickUpLatLng;
  String? pickAddress;

  LatLng? dropOffLatLng;
  String? dropOffAddress;

  String? userName;
  String? userPhone;

  TripDetails({
    this.tripID,
    this.pickAddress,
    this.pickUpLatLng,
    this.dropOffAddress,
    this.dropOffLatLng,
    this.userName,
    this.userPhone
});
}




