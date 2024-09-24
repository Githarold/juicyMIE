import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'theme/theme_provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const PrinterControlApp(),
    ),
  );
}

class PrinterControlApp extends StatelessWidget {
  const PrinterControlApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: '3D 프린터',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.light(
              primary: Colors.blue,
              onPrimary: Colors.white,
              surface: Colors.grey[100]!,
              onSurface: Colors.black,
            ),
            scaffoldBackgroundColor: Colors.grey[100],
            cardTheme: CardTheme(
              color: Colors.white,
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            iconTheme: const IconThemeData(color: Colors.blue),
            textTheme: TextTheme(
              headlineMedium: TextStyle(color: Colors.black),
              titleMedium: TextStyle(color: Colors.black),
              titleSmall: TextStyle(color: Colors.black),
            ),
            appBarTheme: AppBarTheme(
              backgroundColor: Colors.blue,
              iconTheme: const IconThemeData(color: Colors.white),
              titleTextStyle: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.dark(
              primary: Colors.blue,
              onPrimary: Colors.black,
              surface: Colors.grey[900]!,
              onSurface: Colors.white,
            ),
            scaffoldBackgroundColor: Colors.grey[900],
            cardTheme: CardTheme(
              color: Colors.grey[800],
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            iconTheme: const IconThemeData(color: Colors.blueAccent),
            textTheme: TextTheme(
              headlineMedium: TextStyle(color: Colors.white),
              titleMedium: TextStyle(color: Colors.white),
              titleSmall: TextStyle(color: Colors.white),
            ),
            appBarTheme: AppBarTheme(
              backgroundColor: Colors.grey[900],
              iconTheme: const IconThemeData(color: Colors.blueAccent),
              titleTextStyle: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          themeMode: themeProvider.themeMode,
          home: const HomeScreen(),
        );
      },
    );
  }
}
