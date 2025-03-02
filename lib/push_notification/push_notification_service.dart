import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';

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

    // 1) Terminated (completely closed)
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? remoteMsg) {
      if (remoteMsg != null) {
        print("[PushNotificationService] getInitialMessage => data: ${remoteMsg.data}");
        String tripID = remoteMsg.data["tripID"] ?? "";
        // Handle logic (navigate, show dialog, etc.)
      } else {
        print("[PushNotificationService] getInitialMessage => No initial message");
      }
    });

    // 2) Foreground (app is open)
    FirebaseMessaging.onMessage.listen((RemoteMessage? remoteMsg) {
      if (remoteMsg != null) {
        print("[PushNotificationService] onMessage => data: ${remoteMsg.data}");
        String tripID = remoteMsg.data["tripID"] ?? "";
        // Show a dialog/snackbar or handle logic
      } else {
        print("[PushNotificationService] onMessage => remoteMsg was null");
      }
    });

    // 3) Background (app opened from notification in background)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage? remoteMsg) {
      if (remoteMsg != null) {
        print("[PushNotificationService] onMessageOpenedApp => data: ${remoteMsg.data}");
        String tripID = remoteMsg.data["tripID"] ?? "";
        // Handle logic (e.g., navigate to a trip details page)
      } else {
        print("[PushNotificationService] onMessageOpenedApp => remoteMsg was null");
      }
    });
  }

  /// Optional: track token refresh. If the user reinstalled the app,
  /// or FCM rotates the token, you can update it in DB.
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
}
