import 'package:flutter/material.dart';

class PrinterConnectionScreen extends StatefulWidget {
  const PrinterConnectionScreen({Key? key}) : super(key: key);

  @override
  _PrinterConnectionScreenState createState() => _PrinterConnectionScreenState();
}

class _PrinterConnectionScreenState extends State<PrinterConnectionScreen> {
  bool isConnected = false;
  List<String> nearbyDevices = ['Printer 1', 'Printer 2', 'Printer 3']; // Example data

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Printer Connection'),
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              // Add Bluetooth scan logic here
              setState(() {
                nearbyDevices = ['Printer 1', 'Printer 2', 'Printer 3', 'Printer 4'];
              });
            },
            child: const Text('Scan for Devices'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: nearbyDevices.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(nearbyDevices[index]),
                  trailing: ElevatedButton(
                    onPressed: () {
                      // Add connection logic here
                      setState(() {
                        isConnected = !isConnected;
                      });
                    },
                    child: Text(isConnected ? 'Disconnect' : 'Connect'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
