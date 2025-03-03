import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:gover_driver_app/global.dart';
import 'package:gover_driver_app/model/trip_details.dart';
import 'package:gover_driver_app/widgets/loading_dialog.dart';

import '../widgets/notification_dialog.dart';

class PushNotificationService {
  FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  /// Generates (or retrieves) the FCM token for this device,
  /// saves it to Realtime Database under driver's node,
  /// and subscribes to relevant topics.
  Future<String?> generateDeviceRecognitionToken() async {
    print("[PushNotificationService] generateDeviceRecognitionToken() called");

    String? deviceRecognitionToken = await firebaseMessaging.getToken();

    print("[PushNotificationService] FCM Token: $deviceRecognitionToken");

    if (deviceRecognitionToken != null) {
      final driverUid = FirebaseAuth.instance.currentUser?.uid;
      if (driverUid != null) {
        DatabaseReference ref = FirebaseDatabase.instance
            .ref()
            .child("drivers")
            .child(driverUid)
            .child("deviceToken");

        await ref.set(deviceRecognitionToken);
        print("[PushNotificationService] Saved driver token to DB for uid: $driverUid");
      }

      // Subscriptions
      await firebaseMessaging.subscribeToTopic("drivers");
      await firebaseMessaging.subscribeToTopic("users");
      print("[PushNotificationService] Subscribed to topics: drivers & users");
    }

    return deviceRecognitionToken;
  }

  /// Listens for new notifications and handles them for:
  /// 1) Terminated state (getInitialMessage)
  /// 2) Foreground state (onMessage)
  /// 3) Background state (onMessageOpenedApp)
  Future<void> startListeningForNewNotification(BuildContext context) async {
    print("[PushNotificationService] startListeningForNewNotification() called");

    // 1) Terminated state:
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? remoteMsg) {
      if (remoteMsg != null) {
        print("[PushNotificationService] getInitialMessage => data: ${remoteMsg.data}");
        String tripID = remoteMsg.data["tripId"] ?? "";
        retrieveTripRequestInfo(tripID, context);
      } else {
        print("[PushNotificationService] getInitialMessage => No initial message");
      }
    });

    // 2) Foreground state:
    FirebaseMessaging.onMessage.listen((RemoteMessage? remoteMsg) {
      if (remoteMsg != null) {
        print("[PushNotificationService] onMessage => data: ${remoteMsg.data}");
        String tripID = remoteMsg.data["tripId"] ?? "";
        retrieveTripRequestInfo(tripID, context);
      } else {
        print("[PushNotificationService] onMessage => remoteMsg was null");
      }
    });

    // 3) Background state:
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage? remoteMsg) {
      if (remoteMsg != null) {
        print("[PushNotificationService] onMessageOpenedApp => data: ${remoteMsg.data}");
        String tripID = remoteMsg.data["tripId"] ?? "";
        retrieveTripRequestInfo(tripID, context);
      } else {
        print("[PushNotificationService] onMessageOpenedApp => remoteMsg was null");
      }
    });
  }

  /// Optional: track token refresh.
  void startListeningForTokenRefresh() {
    print("[PushNotificationService] startListeningForTokenRefresh() called");

    firebaseMessaging.onTokenRefresh.listen((newToken) async {
      print("[PushNotificationService] Token refreshed => $newToken");
      final driverUid = FirebaseAuth.instance.currentUser?.uid;
      if (driverUid != null) {
        DatabaseReference ref = FirebaseDatabase.instance
            .ref()
            .child("drivers")
            .child(driverUid)
            .child("deviceToken");
        await ref.set(newToken);
        print("[PushNotificationService] Updated driver token in DB");
      }
    });
  }

  /// Retrieve trip request info from the database for a given tripID.
  /// Logs the raw data and prints out the parsed values.
  Future<void> retrieveTripRequestInfo(String tripID, BuildContext context) async {
    print("[PushNotificationService] retrieveTripRequestInfo() called for tripID: $tripID");

    // Show a loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => LoadingDialog(messageText: "Getting trip details..."),
    );

    DatabaseReference tripRequestsRef = FirebaseDatabase.instance.ref().child("tripRequests").child(tripID);
    tripRequestsRef.once().then((dataSnapshot) {
      Navigator.pop(context); // dismiss loading

      // Log the raw data from the snapshot
      print("[PushNotificationService] Raw trip data: ${dataSnapshot.snapshot.value}");

      // Check if data is not null
      if (dataSnapshot.snapshot.value == null) {
        print("[PushNotificationService] No trip data found for tripID: $tripID");
        return;
      }

      Map data = dataSnapshot.snapshot.value as Map;

      // Safely extract pickUpLatLng
      Map? pickUpMap = data["pickUpLatLng"];
      if (pickUpMap == null) {
        print("[PushNotificationService] pickUpLatLng is null");
        return;
      }
      double pickUpLat = double.parse(pickUpMap["latitude"].toString());
      double pickUpLng = double.parse(pickUpMap["longitude"].toString());

      // Safely extract dropOffLatLng
      Map? dropOffMap = data["dropOffLatLng"];
      if (dropOffMap == null) {
        print("[PushNotificationService] dropOffLatLng is null");
        return;
      }
      double dropOffLat = double.parse(dropOffMap["latitude"].toString());
      double dropOffLng = double.parse(dropOffMap["longitude"].toString());

      TripDetails tripDetailsInfo = TripDetails();
      tripDetailsInfo.pickUpLatLng = LatLng(pickUpLat, pickUpLng);
      tripDetailsInfo.dropOffLatLng = LatLng(dropOffLat, dropOffLng);

      // Use the correct fields for pickUp and dropOff addresses
      tripDetailsInfo.pickAddress = data["pickUpAddress"] ?? "Unknown Pickup";
      tripDetailsInfo.dropOffAddress = data["dropOffAddress"] ?? "Unknown Dropoff";
      tripDetailsInfo.userName = data["userName"] ?? "Unknown";
      tripDetailsInfo.userPhone = data["userPhone"] ?? "Unknown";
      tripDetailsInfo.tripID = tripID;

      // Log the parsed trip details
      print("[PushNotificationService] Parsed TripDetails:");
      print("  tripID: ${tripDetailsInfo.tripID}");
      print("  pickAddress: ${tripDetailsInfo.pickAddress}");
      print("  dropOffAddress: ${tripDetailsInfo.dropOffAddress}");
      print("  pickUpLatLng: ${tripDetailsInfo.pickUpLatLng}");
      print("  dropOffLatLng: ${tripDetailsInfo.dropOffLatLng}");
      print("  userName: ${tripDetailsInfo.userName}");
      print("  userPhone: ${tripDetailsInfo.userPhone}");

      // Show a loading dialog
      showDialog(
        context: context,
        builder: (BuildContext context) => NotificationDialog(tripDetailsInfo: tripDetailsInfo,),
      );

      // TODO: You might want to navigate to a notification dialog or trip details screen
    }).catchError((error) {
      Navigator.pop(context); // dismiss loading if there's an error
      print("[PushNotificationService] Error retrieving trip info: $error");
    });
  }
}
