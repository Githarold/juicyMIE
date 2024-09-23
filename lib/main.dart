import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/printer_connection_screen.dart';
import 'screens/gcode_management_screen.dart';
import 'screens/print_progress_screen.dart';

void main() {
  runApp(const PrinterControlApp());
}

class PrinterControlApp extends StatelessWidget {
  const PrinterControlApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '3D Printer Control',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _screens = <Widget>[
    HomeScreen(),
    PrinterConnectionScreen(),
    GCodeManagementScreen(),
    PrintProgressScreen(),
    SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.print),
            label: 'Printer',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.code),
            label: 'G-code',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assessment),
            label: 'Progress',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
