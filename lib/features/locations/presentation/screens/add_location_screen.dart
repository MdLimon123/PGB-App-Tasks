import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../domain/entities/location.dart';
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: theme.iconTheme.color),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('New location', style: TextStyle(color: theme.textTheme.titleLarge?.color, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Map Placeholder
            Container(
              height: 150,
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Icon(Icons.map, size: 50, color: theme.primaryColor.withOpacity(0.5)),
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () {
                // TODO: Get current location via geolocator
              },
              icon: Icon(Icons.my_location, color: theme.primaryColor),
              label: Text('Use my current location', style: TextStyle(color: theme.primaryColor)),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: theme.primaryColor),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 24),
            CustomTextField(
              hintText: 'Location name',
              prefixIcon: Icons.location_on_outlined,
              controller: _nameController,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    hintText: 'Latitude',
                    prefixIcon: Icons.explore_outlined,
                    controller: _latController,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomTextField(
                    hintText: 'Longitude',
                    prefixIcon: Icons.explore_outlined,
                    controller: _lngController,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Geofence radius', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('${_radius.toInt()} m', style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold)),
              ],
            ),
            Slider(
              value: _radius,
              min: 50,
              max: 1000,
              activeColor: theme.primaryColor,
              onChanged: (val) {
                setState(() {
                  _radius = val;
                });
              },
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Active', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text('Workers can check in here', style: TextStyle(color: Colors.grey, fontSize: 12)),
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
            const SizedBox(height: 32),
            PrimaryButton(
              text: 'Save location',
              onPressed: () {
                final loc = Location(
                  id: '',
                  name: _nameController.text,
                  latitude: double.tryParse(_latController.text) ?? 0,
                  longitude: double.tryParse(_lngController.text) ?? 0,
                  radiusM: _radius,
                  isActive: _isActive,
                );
                context.read<LocationBloc>().add(AddLocationEvent(loc));
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
