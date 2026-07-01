import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../../../locations/presentation/screens/locations_screen.dart';
import '../../../todo/presentation/screens/todo_screen.dart';
import '../../../sync/presentation/screens/sync_screen.dart';
import '../../../locations/presentation/bloc/location_bloc.dart';
import '../../../todo/presentation/bloc/todo_bloc.dart';
import '../../../../injection_container.dart' as di;

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      BlocProvider(
        create: (_) => di.sl<TodoBloc>(),
        child: const TodoScreen(),
      ),
      BlocProvider(
        create: (_) => di.sl<LocationBloc>(),
        child: const LocationsScreen(),
      ),
      BlocProvider(
        create: (_) => di.sl<TodoBloc>(),
        child: const SyncScreen(),
      ),
      const ProfileScreen(),
    ];
  }

  Widget _buildNavIcon(String assetPath, bool isSelected) {
    return SvgPicture.asset(
      assetPath,
      width: 24,
      height: 24,
      colorFilter: ColorFilter.mode(
        isSelected ? Theme.of(context).primaryColor : Colors.grey,
        BlendMode.srcIn,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: _buildNavIcon('assets/icon/tasks.svg', _currentIndex == 0),
            activeIcon: _buildNavIcon('assets/icon/tasks.svg', true),
            label: 'Tasks',
          ),
          BottomNavigationBarItem(
            icon: _buildNavIcon('assets/icon/location.svg', _currentIndex == 1),
            activeIcon: _buildNavIcon('assets/icon/location.svg', true),
            label: 'Locations',
          ),
          BottomNavigationBarItem(
            icon: _buildNavIcon('assets/icon/sync.svg', _currentIndex == 2),
            activeIcon: _buildNavIcon('assets/icon/sync.svg', true),
            label: 'Sync',
          ),
          BottomNavigationBarItem(
            icon: _buildNavIcon('assets/icon/profile.svg', _currentIndex == 3),
            activeIcon: _buildNavIcon('assets/icon/profile.svg', true),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

