import 'package:flutter/material.dart';
import 'device_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.grey.shade300,
      appBar: AppBar(
        title: const Text('Smart Devices'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            DeviceCard(
              deviceName: 'Kettle',
              deviceIp: '192.168.0.101',
            ),
            SizedBox(width: 20),
            DeviceCard(
              deviceName: 'Bedside Lamp',
              deviceIp: '192.168.0.102',
            ),
          ],
        ),
      ),
    );
  }
}
