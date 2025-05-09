// device_discovery_page.dart
import 'package:flutter/material.dart';
import 'shelly_service.dart';

class DeviceDiscoveryPage extends StatefulWidget {
  const DeviceDiscoveryPage({super.key});

  @override
  State<DeviceDiscoveryPage> createState() => _DeviceDiscoveryPageState();
}

class _DeviceDiscoveryPageState extends State<DeviceDiscoveryPage> {
  bool _isScanning = false;
  List<Map<String, dynamic>> _discoveredDevices = [];
  String _errorMessage = '';
  final TextEditingController _ipController = TextEditingController();

  @override
  void dispose() {
    _ipController.dispose();
    super.dispose();
  }

  Future<void> _startScan() async {
    setState(() {
      _isScanning = true;
      _discoveredDevices = [];
      _errorMessage = '';
    });

    try {
      final devices = await ShellyService.discoverDevices();
      
      if (mounted) {
        setState(() {
          _isScanning = false;
          _discoveredDevices = devices;
          
          if (devices.isEmpty) {
            _errorMessage = 'No Shelly devices found on your network';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isScanning = false;
          _errorMessage = 'Error scanning network: $e';
        });
      }
    }
  }

  Future<void> _addDeviceManually() async {
    final ip = _ipController.text.trim();
    if (ip.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid IP address')),
      );
      return;
    }

    setState(() {
      _isScanning = true;
      _errorMessage = '';
    });

    try {
      final response = await ShellyService.getDeviceStatus(ip);
      
      if (response.success) {
        setState(() {
          _isScanning = false;
          // Add device to list if not already present
          if (!_discoveredDevices.any((device) => device['ip'] == ip)) {
            _discoveredDevices.add({
              'name': 'Shelly Device',
              'ip': ip,
              'type': 'SHELLY',
            });
          }
          _ipController.clear();
        });
      } else {
        setState(() {
          _isScanning = false;
          _errorMessage = 'No Shelly device found at $ip';
        });
      }
    } catch (e) {
      setState(() {
        _isScanning = false;
        _errorMessage = 'Error connecting to device: $e';
      });
    }
  }
  
  void _addToControlPage(BuildContext context, Map<String, dynamic> device) {
    // Show snackbar to confirm
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added ${device['name']} to control page'),
        duration: const Duration(seconds: 2),
      ),
    );
    
    // Here you would handle adding this device to your persistence layer
    // For now, we'll just navigate back
    Navigator.pop(context, device);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('Discover Devices'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Manual entry
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ipController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Enter device IP address',
                      hintStyle: TextStyle(color: Colors.grey.shade400),
                      filled: true,
                      fillColor: const Color(0xFF1E1E2A),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _isScanning ? null : _addDeviceManually,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Add'),
                ),
              ],
            ),
          ),
          
          // Scan button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isScanning ? null : _startScan,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(Icons.search),
                label: Text(_isScanning ? 'Scanning...' : 'Scan Network'),
              ),
            ),
          ),
          
          // Error message
          if (_errorMessage.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                _errorMessage,
                style: const TextStyle(color: Colors.redAccent),
                textAlign: TextAlign.center,
              ),
            ),
          
          // Loading indicator
          if (_isScanning)
            const Padding(
              padding: EdgeInsets.all(24.0),
              child: CircularProgressIndicator(),
            ),
          
          // Device list
          Expanded(
            child: _discoveredDevices.isEmpty && !_isScanning
                ? Center(
                    child: Text(
                      'No devices found.\nTap "Scan Network" to search.',
                      style: TextStyle(color: Colors.grey.shade400),
                      textAlign: TextAlign.center,
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _discoveredDevices.length,
                    itemBuilder: (context, index) {
                      final device = _discoveredDevices[index];
                      return Card(
                        color: const Color(0xFF1E1E2A),
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: const Icon(
                            Icons.device_hub,
                            color: Colors.amber,
                          ),
                          title: Text(
                            device['name'] ?? 'Unknown Device',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            'IP: ${device['ip']} • Type: ${device['type'] ?? 'Unknown'}',
                            style: TextStyle(color: Colors.grey.shade400),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.add_circle_outline, color: Colors.greenAccent),
                            onPressed: () => _addToControlPage(context, device),
                          ),
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