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


  final List<Widget> _screens = [
    const HomeScreen(key: PageStorageKey('HomeScreen')),
    const ComplaintsScreen(key: PageStorageKey('ComplaintsScreen')),
    const HistoryScreen(key: PageStorageKey('HistoryScreen')),
    const SearchScreen(key: PageStorageKey('SearchScreen')),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: _screens[_selectedIndex],
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Theme(
              data: Theme.of(context).copyWith(
                splashFactory: NoSplash.splashFactory,
                highlightColor: Colors.transparent,
              ),
              child: Container(
                height: 70,
                clipBehavior: Clip.antiAlias,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(40)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 5,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: BottomNavigationBar(
                  iconSize: 26,
                  selectedFontSize: 14,
                  currentIndex: _selectedIndex,
                  onTap: (index) {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                  type: BottomNavigationBarType.fixed, 
                  backgroundColor: Colors.transparent,
                  selectedItemColor: Colors.blue,
                  unselectedItemColor: Colors.grey,
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
                      icon: Icon(Icons.star),
                      label: "Search",
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
