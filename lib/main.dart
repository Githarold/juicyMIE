import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pentastic/theme/theme_provider.dart';
import 'package:pentastic/screens/home_screen.dart';
import 'package:pentastic/services/bluetooth_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final bluetoothService = BluetoothService();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider.value(value: bluetoothService),
      ],
      child: MyApp(bluetoothService: bluetoothService),
    ),
  );
}

class MyApp extends StatelessWidget {
  final BluetoothService bluetoothService;

  const MyApp({super.key, required this.bluetoothService});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Pentasticsss',
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: themeProvider.themeMode,
          home: HomeScreen(bluetoothService: bluetoothService),
        );
      },
    );
  }
}
