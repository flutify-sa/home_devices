// shelly_service.dart
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
// ignore: unused_import
import 'package:flutter/foundation.dart';

/// Response from a Shelly device operation
class ShellyResponse {
  final bool success;
  final String message;
  final Map<String, dynamic>? data;

  ShellyResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory ShellyResponse.fromJson(Map<String, dynamic> json) {
    return ShellyResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? 'Unknown response',
      data: json['data'],
    );
  }

  factory ShellyResponse.error(String message) {
    return ShellyResponse(
      success: false,
      message: message,
    );
  }
}

/// Service for interacting with Shelly devices
class ShellyService {
  /// Timeout duration for requests
  static const Duration _timeout = Duration(seconds: 5);
  
  /// Toggle a Shelly device on or off
  static Future<ShellyResponse> toggleDevice({
    required String deviceIp,
    required bool turnOn,
  }) async {
    try {
      // The Shelly 1 Mini uses this endpoint format to control the relay
      final url = Uri.parse('http://$deviceIp/relay/0?turn=${turnOn ? 'on' : 'off'}');
      
      // Send the request with timeout
      final response = await http.get(url).timeout(_timeout);
      
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return ShellyResponse(
          success: true,
          message: 'Device ${turnOn ? 'turned on' : 'turned off'} successfully',
          data: jsonResponse,
        );
      } else {
        return ShellyResponse.error('Failed to control device: HTTP ${response.statusCode}');
      }
    } on TimeoutException {
      return ShellyResponse.error('Connection timed out');
    } on http.ClientException catch (e) {
      return ShellyResponse.error('Network error: ${e.message}');
    } catch (e) {
      return ShellyResponse.error('Error: $e');
    }
  }
  
  /// Get the current state of a Shelly device
  static Future<ShellyResponse> getDeviceStatus(String deviceIp) async {
    try {
      // Get device status endpoint for Shelly 1 Mini
      final url = Uri.parse('http://$deviceIp/status');
      
      // Send the request with timeout
      final response = await http.get(url).timeout(_timeout);
      
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        // For Shelly 1 Mini, relay status is under "relays" array
        final isOn = jsonResponse['relays'] != null && 
                    jsonResponse['relays'].isNotEmpty && 
                    jsonResponse['relays'][0]['ison'] == true;
                    
        return ShellyResponse(
          success: true,
          message: 'Device is ${isOn ? 'on' : 'off'}',
          data: {'isOn': isOn, 'deviceData': jsonResponse},
        );
      } else {
        return ShellyResponse.error('Failed to get device status: HTTP ${response.statusCode}');
      }
    } on TimeoutException {
      return ShellyResponse.error('Connection timed out');
    } on http.ClientException catch (e) {
      return ShellyResponse.error('Network error: ${e.message}');
    } catch (e) {
      return ShellyResponse.error('Error: $e');
    }
  }
  
  /// Scan local network for Shelly devices
  /// Note: This is a simplified implementation. A real implementation would use
  /// mDNS/Bonjour service discovery or similar
  static Future<List<Map<String, dynamic>>> discoverDevices() async {
    List<Map<String, dynamic>> foundDevices = [];
    
    // This is a basic example assuming devices are in the 192.168.1.x range
    // In a real app, you'd use proper mDNS or Shelly's cloud API
    for (int i = 2; i < 255; i++) {
      String ip = '192.168.1.$i';
      try {
        final url = Uri.parse('http://$ip/shelly');
        final response = await http.get(url).timeout(const Duration(milliseconds: 200));
        
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['type'] != null && data['type'].toString().startsWith('SHELLY')) {
            foundDevices.add({
              'name': data['name'] ?? 'Shelly Device',
              'ip': ip,
              'type': data['type'],
              'mac': data['mac'] ?? '',
            });
          }
        }
      } catch (_) {
        // Skip devices that don't respond or aren't Shelly devices
        continue;
      }
    }
    
    return foundDevices;
  }
}