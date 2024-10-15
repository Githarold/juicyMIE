import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pentastic/theme/theme_provider.dart';
import 'package:pentastic/screens/home_screen.dart';
import 'package:pentastic/services/bluetooth_service.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BluetoothService()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Pentastic',
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: themeProvider.themeMode,
          home: Consumer<BluetoothService>(
            builder: (context, bluetoothService, child) {
              return HomeScreen(bluetoothService: bluetoothService);
            },
          ),
        );
      },
    );
  }
}
