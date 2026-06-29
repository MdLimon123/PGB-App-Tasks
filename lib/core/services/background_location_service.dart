import 'dart:async';
import 'dart:ui';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';

// Note: In a real app, you would inject the LocationRepository here to get the saved locations from Hive/LocalDB.
// For demonstration, we assume we fetch them or have a local copy.

Future<void> initializeBackgroundService() async {
  final service = FlutterBackgroundService();

  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'geofence_channel',
    'Geofence Notifications',
    description: 'This channel is used for geofence entry notifications.',
    importance: Importance.high,
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: true,
      isForegroundMode: true,
      notificationChannelId: 'geofence_channel',
      initialNotificationTitle: 'FieldTrack Service',
      initialNotificationContent: 'Monitoring locations',
      foregroundServiceNotificationId: 888,
    ),
    iosConfiguration: IosConfiguration(
      autoStart: true,
      onForeground: onStart,
      onBackground: onIosBackground,
    ),
  );

  service.startService();
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  return true;
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();
  
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Request location permission here if needed

  Timer.periodic(const Duration(minutes: 1), (timer) async {
    // 1. Get current position
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      // 2. Fetch locations from Local DB (e.g. Hive)
      // List<Location> locations = await localDataSource.getLocations();
      
      // Example static check for demonstration:
      // double distance = Geolocator.distanceBetween(position.latitude, position.longitude, targetLat, targetLng);
      // if (distance < targetRadius && !wasInsideBefore) {
      //    triggerNotification(location.name);
      // }
      
      print('Background location checked: \${position.latitude}, \${position.longitude}');
    } catch (e) {
      print('Location error in background: \$e');
    }
  });
}

void triggerNotification(String locationName, FlutterLocalNotificationsPlugin plugin) {
  plugin.show(
    locationName.hashCode,
    'Location Alert',
    'You entered \$locationName',
    const NotificationDetails(
      android: AndroidNotificationDetails(
        'geofence_channel',
        'Geofence Notifications',
        icon: 'ic_bg_service_small',
        importance: Importance.max,
        priority: Priority.high,
      ),
    ),
  );
}
