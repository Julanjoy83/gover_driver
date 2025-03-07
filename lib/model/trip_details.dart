import 'package:google_maps_flutter/google_maps_flutter.dart';

class TripDetails {
  String? tripID;
  LatLng? pickUpLatLng;
  String? pickAddress;
  LatLng? dropOffLatLng;
  String? dropOffAddress;
  String? userName;
  String? userPhone;

  // Ajouts pour l'inventaire
  int? totalItems;
  double? totalVolume;
  List<Map<String, dynamic>>? inventoryList;

  TripDetails({
    this.tripID,
    this.pickAddress,
    this.pickUpLatLng,
    this.dropOffAddress,
    this.dropOffLatLng,
    this.userName,
    this.userPhone,
    this.totalItems,
    this.totalVolume,
    this.inventoryList,
  });
}
