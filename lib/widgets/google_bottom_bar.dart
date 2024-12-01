import 'package:flutter/material.dart';
import 'package:internet/screens/SpeedTestApp.dart';
import 'package:internet/screens/plaints.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import '../screens/home_screen.dart';
import '../screens/history_screen.dart';
import '../screens/search_screen.dart';
import '../screens/profile_screen.dart'; // Future Profile or Placeholder Screen
import '../screens/video_screen.dart'; // Placeholder for Complaints Screen

class GoogleBottomBar extends StatefulWidget {
  const GoogleBottomBar({super.key});

  @override
  _GoogleBottomBarState createState() => _GoogleBottomBarState();
}

class _GoogleBottomBarState extends State<GoogleBottomBar> {
  int _selectedIndex = 0;

  // Define the list of screens corresponding to each tab.
  final List<Widget> _screens = [
    const HomeScreen(key: PageStorageKey('HomeScreen')),
    ComplaintsScreen(),
    // SpeedTestApp(), // Speed Test Page
    const HistoryScreen(key: PageStorageKey('HistoryScreen')), 
    SearchScreen(),// History Page
    // const SearchScreen(key: PageStorageKey('SearchScreen')), // Search/Operator Page
    // VideoScreen()
      // Complaints Page
  ];

  // Build the bottom bar items with icons and titles matching the design.
  List<SalomonBottomBarItem> _buildNavBarItems() {
    return [
      SalomonBottomBarItem(
        icon: const Icon(Icons.speed), // Icon for Speed Test
        // title: const Text("Speed"),
        selectedColor: Colors.blue, // Adjust color for selected state
        unselectedColor: Colors.grey,
      ),
      SalomonBottomBarItem(
        icon: const Icon(Icons.feedback), // Icon for Complaints
        // title: const Text("Complaints"),
        selectedColor: Colors.blue,
        unselectedColor: Colors.grey,
      ),
      SalomonBottomBarItem(
        icon: const Icon(Icons.history), // Icon for History
        // title: const Text("History"),
        selectedColor: Colors.blue,
        unselectedColor: Colors.grey,
      ),
      SalomonBottomBarItem(
        icon: const Icon(Icons.search), // Icon for Search/Operators
        // title: const Text("Search"),
        selectedColor: Colors.blue,
        unselectedColor: Colors.grey,
      ),
      
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens, // Show the selected screen
      ),
      bottomNavigationBar: SalomonBottomBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index; // Update selected index
          });
        },
        items: _buildNavBarItems(), // Add bottom bar items
      ),
    );
  }
}
