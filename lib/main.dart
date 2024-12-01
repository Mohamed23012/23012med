import 'package:flutter/material.dart';
import 'widgets/google_bottom_bar.dart';
import 'package:provider/provider.dart';
import 'services/network_provider.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NetworkProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Network Information App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue, // Set the primary color for the app
        scaffoldBackgroundColor: Colors.blueGrey[50],
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          selectedItemColor: const Color(0xFF1E88E5),
          unselectedItemColor: Colors.grey,
          backgroundColor: Colors.white,
        ),
      ),
      navigatorKey: navigatorKey, // Assign the global navigatorKey here
      home: const GoogleBottomBar(), // Set GoogleBottomBar as the home widget
    );
  }
}

