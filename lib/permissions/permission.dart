import 'package:permission_handler/permission_handler.dart';

class PermissionMethods
{
  askLocationPermission()  async
  {
    await Permission.locationWhenInUse.isDenied.then((value) {
      if(value) {
        Permission.locationWhenInUse.request();
      }
    });
  }


  askNotificationPermission()  async
  {
    await Permission.notification.isDenied.then((value) {
      if(value) {
        Permission.notification.request();
      }
    });
  }

}