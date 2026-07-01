import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../bloc/location_bloc.dart';
import '../bloc/location_event.dart';


class AddLocationScreen extends StatefulWidget {
  const AddLocationScreen({Key? key}) : super(key: key);

  @override
  State<AddLocationScreen> createState() => _AddLocationScreenState();
}

class _AddLocationScreenState extends State<AddLocationScreen> {
  final _nameController = TextEditingController();
  final _latController = TextEditingController();
  final _lngController = TextEditingController();
  double _radius = 150;
  bool _isActive = true;
  bool _isLoadingLocation = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: theme.iconTheme.color, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: Text('New location', style: TextStyle(color: theme.textTheme.titleLarge?.color, fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Map Placeholder
            Center(
              child: Container(
                height: 160,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    Color(0xFFE6EAEF).withValues(alpha: 0.0),
                    Color(0xFFE6EAEF)
                  ]),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Map background placeholder lines
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _MapGridPainter(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05)),
                      ),
                    ),
                    // The radius circle
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: theme.primaryColor.withValues(alpha: 0.3), width: 2),
                        color: theme.primaryColor.withValues(alpha: 0.1),
                      ),
                    ),
                    // The location pin
                    Icon(Icons.location_on, size: 36, color: theme.primaryColor),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            InkWell(
              onTap: _isLoadingLocation ? null : () async {
                setState(() => _isLoadingLocation = true);
                try {
                  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
                  if (!serviceEnabled) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Location services are disabled.')),
                      );
                    }
                    return;
                  }

                  LocationPermission permission = await Geolocator.checkPermission();
                  if (permission == LocationPermission.denied) {
                    permission = await Geolocator.requestPermission();
                    if (permission == LocationPermission.denied) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Location permissions are denied')),
                        );
                      }
                      return;
                    }
                  }
                  
                  if (permission == LocationPermission.deniedForever) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Location permissions are permanently denied, we cannot request permissions.')),
                      );
                    }
                    return;
                  } 

                  Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
                  _latController.text = position.latitude.toString();
                  _lngController.text = position.longitude.toString();

                  // Reverse geocode to get location name
                  try {
                    List<Placemark> placemarks = await placemarkFromCoordinates(
                      position.latitude,
                      position.longitude,
                    );
                    if (placemarks.isNotEmpty) {
                      final place = placemarks.first;
                      final name = [
                        place.subLocality,
                        place.locality,
                        place.administrativeArea,
                      ].where((s) => s != null && s.isNotEmpty).join(', ');
                      if (name.isNotEmpty) {
                        _nameController.text = name;
                      }
                    }
                  } catch (_) {
                    
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error getting location: $e')),
                      
                    );
                    print("============> ${e.toString()}");
                  }
                } finally {
                  if (mounted) setState(() => _isLoadingLocation = false);
                }
              },
              borderRadius: BorderRadius.circular(12),
              child: CustomPaint(
                painter: _DashedBorderPainter(color: _isLoadingLocation ? Colors.grey : theme.primaryColor),
                child: Container(
                  height: 50,
                  alignment: Alignment.center,
                  child: _isLoadingLocation 
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.my_location, color: theme.primaryColor, size: 18),
                            const SizedBox(width: 8),
                            Text('Use my current location', style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.w500, fontSize: 14)),
                          ],
                        ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            CustomTextField(
              hintText: 'Location name',
              controller: _nameController,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    hintText: 'Latitude',
                    controller: _latController,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomTextField(
                    hintText: 'Longitude',
                    controller: _lngController,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Geofence radius', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text('${_radius.toInt()} m', style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold, fontSize: 14)),
              ],
            ),
            const SizedBox(height: 8),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 4,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
                activeTrackColor: theme.primaryColor,
                inactiveTrackColor: isDark ? Colors.white12 : Colors.grey.shade200,
                thumbColor: theme.primaryColor,
                overlayColor: theme.primaryColor.withValues(alpha: 0.2),
              ),
              child: Slider(
                value: _radius,
                min: 50,
                max: 1000,
                onChanged: (val) {
                  setState(() {
                    _radius = val;
                  });
                },
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Active', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text('Workers can check in here', style: TextStyle(color: isDark ? Colors.white54 : Colors.grey.shade500, fontSize: 12)),
                  ],
                ),
                Switch(
                  value: _isActive,
                  activeColor: theme.primaryColor,
                  onChanged: (val) {
                    setState(() => _isActive = val);
                  },
                ),
              ],
            ),
            const SizedBox(height: 40),
            PrimaryButton(
              text: 'Save location',
              onPressed: () {
                final name = _nameController.text.trim();
                final lat = double.tryParse(_latController.text);
                final lng = double.tryParse(_lngController.text);

                if (name.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a location name')),
                  );
                  return;
                }
                if (lat == null || lng == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter valid latitude and longitude')),
                  );
                  return;
                }

                context.read<LocationBloc>().add(
                      CreateLocation(
                        name: name,
                        latitude: lat,
                        longitude: lng,
                        radiusM: _radius,
                      ),
                    );
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _MapGridPainter extends CustomPainter {
  final Color color;
  _MapGridPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.0;
    
    // Vertical line
    canvas.drawLine(Offset(size.width / 2, 0), Offset(size.width / 2, size.height), paint);
    // Horizontal line
    canvas.drawLine(Offset(0, size.height / 2), Offset(size.width, size.height / 2), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  _DashedBorderPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, size.width, size.height), const Radius.circular(12)));
    
    const dashWidth = 6.0;
    const dashSpace = 4.0;
    
    double distance = 0.0;
    for (var pathMetric in path.computeMetrics()) {
      while (distance < pathMetric.length) {
        canvas.drawPath(
          pathMetric.extractPath(distance, distance + dashWidth),
          paint,
        );
        distance += dashWidth + dashSpace;
      }
      distance = 0.0;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
