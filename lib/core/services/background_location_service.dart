import 'dart:async';
import 'dart:ui';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive_flutter/hive_flutter.dart';

// Track which geofences we're currently inside
final Map<String, bool> _geofenceStates = {};

Future<void> initializeBackgroundService() async {
  final service = FlutterBackgroundService();

  final channel = AndroidNotificationChannel(
    'geofence_channel',
    'Geofence Notifications',
    description: 'This channel is used for geofence entry notifications.',
    importance: Importance.defaultImportance,
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
Future<void> onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  await flutterLocalNotificationsPlugin.initialize(
    const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    ),
  );

  Timer.periodic(const Duration(minutes: 1), (timer) async {
    try {
      // Check permissions first to avoid throwing exceptions constantly
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        return; // Don't try to get location if we don't have permission
      }

      // Get current position with high accuracy
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Initialize Hive in background isolate if needed
      await Hive.initFlutter();

      // Open locations box if not already open
      final Box locationsBox;
      if (Hive.isBoxOpen('locations')) {
        locationsBox = Hive.box('locations');
      } else {
        locationsBox = await Hive.openBox('locations');
      }
      final locationsList = locationsBox.values.toList();

      // Check each location for geofence
      for (final locationData in locationsList) {
        final locationId = locationData['id'] as String?;
        final locationName = locationData['name'] as String?;
        final lat = locationData['latitude'] as double?;
        final lng = locationData['longitude'] as double?;
        final radiusM = (locationData['radius_m'] ?? locationData['radiusM']) as int? ?? 100;
        final isActive = locationData['is_active'] as bool? ?? true;

        if (locationId == null || lat == null || lng == null || !isActive) {
          continue;
        }

        // Calculate distance between current position and location
        final distance = Geolocator.distanceBetween(
          position.latitude,
          position.longitude,
          lat,
          lng,
        );

        // Check if currently inside geofence
        final isInsideNow = distance < radiusM;
        final wasInsideBefore = _geofenceStates[locationId] ?? false;

        // State transition: entering geofence
        if (isInsideNow && !wasInsideBefore) {
          _geofenceStates[locationId] = true;
          await _showNotification(
            flutterLocalNotificationsPlugin,
            'Entered: $locationName',
            'You entered the geofence for $locationName (${distance.toStringAsFixed(0)}m away)',
            locationId,
          );
        }

        // State transition: leaving geofence
        if (!isInsideNow && wasInsideBefore) {
          _geofenceStates[locationId] = false;
          await _showNotification(
            flutterLocalNotificationsPlugin,
            'Left: $locationName',
            'You left the geofence for $locationName (${distance.toStringAsFixed(0)}m away)',
            locationId,
          );
        }

        // Update state if changed
        if (isInsideNow != wasInsideBefore) {
          _geofenceStates[locationId] = isInsideNow;
        }
      }
    } catch (e) {
      print('Location error in background: $e');
    }
  });
}

Future<void> _showNotification(
  FlutterLocalNotificationsPlugin plugin,
  String title,
  String body,
  String locationId,
) async {
  final notificationDetails = NotificationDetails(
    android: AndroidNotificationDetails(
      'geofence_channel',
      'Geofence Notifications',
      channelDescription: 'Notifications for geofence entry and exit',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      ticker: 'ticker',
    ),
    iOS: const DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    ),
  );

  await plugin.show(
    locationId.hashCode,
    title,
    body,
    notificationDetails,
  );
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
