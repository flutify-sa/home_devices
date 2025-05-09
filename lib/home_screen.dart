import 'package:flutter/material.dart';
import 'device_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background image
        Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/purple.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        // Foreground content
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(foregroundColor: Colors.white,
            backgroundColor: Colors.transparent,
            elevation: 0,
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
        ),
      ],
    );
  }
}
