import 'package:flutter/material.dart';
import 'package:internet/screens/SpeedTestApp.dart';
import 'package:internet/screens/plaints.dart';
import '../screens/home_screen.dart';
import '../screens/history_screen.dart';
import '../screens/search_screen.dart';

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
    const ComplaintsScreen(key: PageStorageKey('ComplaintsScreen')),
    const HistoryScreen(key: PageStorageKey('HistoryScreen')),
    const SearchScreen(key: PageStorageKey('SearchScreen')),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens, // Show the selected screen
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 5,
              spreadRadius: 1,
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index; // Update the selected index
            });
          },
          type: BottomNavigationBarType.fixed, // Ensures a consistent layout
          backgroundColor: Colors.transparent, // Background already handled
          selectedItemColor: Colors.blue, // Highlight selected item
          unselectedItemColor: Colors.grey, // Dim unselected items
          elevation: 0, // Remove BottomNavigationBar shadow
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.speed),
              label: "Speed",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.feedback),
              label: "Plaints",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history),
              label: "History",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.star), // Changed icon to Star
              label: "Search",
            ),
          ],
        ),
      ),
    );
  }
}
