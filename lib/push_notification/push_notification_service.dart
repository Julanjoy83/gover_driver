import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';


class PushNotificationService
{
  FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  Future<String?> generateDeviceRecognitionToken() async
  {
    String? deviceRecognitionToken = await firebaseMessaging.getToken();
    DatabaseReference ref = FirebaseDatabase.instance.ref()
        .child("drivers").child(FirebaseAuth.instance.currentUser!.uid)
        .child("deviceToken");

    ref.set(deviceRecognitionToken);

    firebaseMessaging.subscribeToTopic("drivers");
    firebaseMessaging.subscribeToTopic("users");
  }

  startListeningForNewNotification(BuildContext context) async
  {

    ///1. terminated
    // when the app is completely closed
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? remoteMsg)
    {
        if(remoteMsg != null )
          {
           String tripID = remoteMsg.data["tripID"];
          }
    });


    ///2. Foreground
    //when the app is open
    FirebaseMessaging.onMessage.listen((RemoteMessage? remoteMsg)
    {
      if(remoteMsg != null )
      {
        String tripID = remoteMsg.data["tripID"];
      }
    });





    ///3. background
    // when the app is in the background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage? remoteMsg){
      if(remoteMsg != null )
      {
        String tripID = remoteMsg.data["tripID"];
      }
    });
  }

}