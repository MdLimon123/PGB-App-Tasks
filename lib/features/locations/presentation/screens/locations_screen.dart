import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../bloc/location_bloc.dart';
import '../bloc/location_event.dart';
import '../bloc/location_state.dart';
import 'add_location_screen.dart';

class LocationsScreen extends StatefulWidget {
  const LocationsScreen({Key? key}) : super(key: key);

  @override
  State<LocationsScreen> createState() => _LocationsScreenState();
}

class _LocationsScreenState extends State<LocationsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<LocationBloc>().add(const LoadLocations());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Locations', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(color: theme.primaryColor, borderRadius: BorderRadius.circular(12)),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(Icons.add, color: Colors.white),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => BlocProvider.value(
                            value: context.read<LocationBloc>(),
                            child: const AddLocationScreen(),
                          )),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search locations',
                  hintStyle: TextStyle(color: isDark ? Colors.grey : Colors.grey.shade500),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: SvgPicture.asset(
                      'assets/icon/search.svg',
                      width: 18,
                      height: 18,
                      colorFilter: ColorFilter.mode(isDark ? Colors.grey : Colors.grey.shade600, BlendMode.srcIn),
                    ),
                  ),
                  filled: true,
                  fillColor: theme.cardColor,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: BlocBuilder<LocationBloc, LocationState>(
                  builder: (context, state) {
                    if (state is LocationLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is LocationError) {
                      return Center(child: Text(state.message, style: const TextStyle(color: Colors.red)));
                    } else if (state is LocationsLoaded) {
                      if (state.locations.isEmpty) {
                        return Center(child: Text('No locations found', style: TextStyle(color: Colors.grey.shade500)));
                      }
                      return ListView.builder(
                        itemCount: state.locations.length,
                        itemBuilder: (context, index) {
                          final loc = state.locations[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: theme.cardColor,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                if (!isDark)
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.02),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: theme.primaryColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: SvgPicture.asset(
                                    'assets/icon/location.svg',
                                    colorFilter: ColorFilter.mode(theme.primaryColor, BlendMode.srcIn),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(loc.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(Icons.my_location, size: 14, color: Colors.grey),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              '${loc.latitude}, ${loc.longitude}',
                                              style: const TextStyle(color: Colors.grey, fontSize: 12),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(color: isDark ? Colors.white10 : Colors.grey.shade100, borderRadius: BorderRadius.circular(6)),
                                            child: Text('${loc.radiusM.toInt()} m radius', style: TextStyle(fontSize: 12, color: isDark ? Colors.white70 : Colors.grey.shade600, fontWeight: FontWeight.w500)),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(color: loc.isActive ? theme.primaryColor.withOpacity(0.1) : (isDark ? Colors.white10 : Colors.grey.shade100), borderRadius: BorderRadius.circular(6)),
                                            child: Text(loc.isActive ? 'Active' : 'Inactive', style: TextStyle(fontSize: 12, color: loc.isActive ? theme.primaryColor : (isDark ? Colors.white70 : Colors.grey.shade600), fontWeight: FontWeight.w600)),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(Icons.chevron_right, color: Colors.grey),
                              ],
                            ),
                          );
                        },
                      );
                    }
                    return const SizedBox();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
