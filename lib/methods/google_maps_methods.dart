import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../appInfo/app_info.dart';
import '../global.dart';
import '../model/address_model.dart';

class GoogleMapsMethods {
  /// Envoie une requête GET à l'API et retourne le résultat en JSON
  static Future<dynamic> sendRequestToAPI(String apiUrl) async {
    try {
      http.Response responseFromAPI = await http.get(Uri.parse(apiUrl));

      if (responseFromAPI.statusCode == 200) {
        String dataFromApi = responseFromAPI.body;
        var dataDecoded = jsonDecode(dataFromApi);
        return dataDecoded; // Retourne les données au lieu de les ignorer
      } else {
        print("Erreur API : Code ${responseFromAPI.statusCode}");
        return "error";
      }
    } catch (errorMsg) {
      print("\n\nErreur survenue lors de la requête API :\n$errorMsg\n");
      return "error";
    }
  }

  /// Reverse geocoding : Convertit des coordonnées en adresse lisible
  static Future<String> convertGeographicCoOrdinatesIntoHumanReadableAddress(
      Position position, BuildContext context) async {
    String humanReadableAddress = "";
    String geoCodingApiUrl =
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$googleMapKey";

    var responseFromApi = await sendRequestToAPI(geoCodingApiUrl);

    if (responseFromApi != "error" &&
        responseFromApi["results"] != null &&
        responseFromApi["results"].isNotEmpty) {
      humanReadableAddress = responseFromApi["results"][0]["formatted_address"];
      print("Adresse obtenue : $humanReadableAddress");

      AddressModel addressModel = AddressModel();
      addressModel.humanReadableAddress = humanReadableAddress;
      addressModel.placeName = humanReadableAddress;
      addressModel.placeID = responseFromApi["results"][0]["place_id"];
      addressModel.latitudePosition = position.latitude;
      addressModel.longitudePosition = position.longitude;

      Provider.of<AppInfo>(context, listen: false)
          .updatePickUpLocation(addressModel);
    } else {
      print("\n\nErreur : Impossible de récupérer l'adresse.\n");
    }

    return humanReadableAddress;
  }
}
