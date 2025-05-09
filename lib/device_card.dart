// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Add this for HapticFeedback
import 'dart:math' as math;

class DeviceCard extends StatefulWidget {
  final String deviceName;
  final String deviceIp;
  final IconData icon;
  final Color accentColor;

  const DeviceCard({
    super.key,
    required this.deviceName,
    required this.deviceIp,
    this.icon = Icons.devices,
    this.accentColor = Colors.blue,
  });

  @override
  State<DeviceCard> createState() => _DeviceCardState();
}

class _DeviceCardState extends State<DeviceCard> with SingleTickerProviderStateMixin {
  bool _isDeviceOn = false;
  bool _isPressed = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _rotateAnimation = Tween<double>(begin: 0, end: 0.05).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticIn,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Toggle device on/off with haptic feedback
  void _toggleDevice(bool value) {
    HapticFeedback.mediumImpact();
    
    setState(() {
      _isDeviceOn = value;
    });

    if (value) {
      _animationController.forward().then((_) => _animationController.reverse());
    } else {
      _animationController.reverse();
    }

    // Simulate device control (e.g., toggle device via API)
    print('${widget.deviceName} is ${value ? 'ON' : 'OFF'}');
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = _isDeviceOn ? widget.accentColor : Colors.grey.shade800;
    final Color textColor = _isDeviceOn ? Colors.white : Colors.white ;
    
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.rotate(
            angle: _rotateAnimation.value,
            child: GestureDetector(
              onTapDown: (_) => setState(() => _isPressed = true),
              onTapUp: (_) => setState(() => _isPressed = false),
              onTapCancel: () => setState(() => _isPressed = false),
              onTap: () => _toggleDevice(!_isDeviceOn),
              child: Container(
                width: 170,
                height: 180, // Increased height to accommodate content
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _isDeviceOn ? primaryColor : Colors.purple,
                      _isDeviceOn ? primaryColor.withAlpha(204) : const Color(0xFF2D2D3A),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: _isDeviceOn 
                          ? primaryColor.withAlpha(153) 
                          : Colors.black.withAlpha(77),
                      blurRadius: _isDeviceOn ? 15 : 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                  border: Border.all(
                    color: _isDeviceOn 
                        ? primaryColor.withAlpha(153) 
                        : Colors.grey.withAlpha(126),
                    width: 1.5,
                  ),
                ),
                child: Stack(
                  children: [
                    // Background pulse animation when on
                    if (_isDeviceOn)
                      Positioned.fill(
                        child: _buildPulseEffect(primaryColor),
                      ),
                    
                    // Main content
                    Padding(
                      padding: const EdgeInsets.all(12.0), // Reduced padding
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Icon and Status
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: 46,
                                height: 46,
                                decoration: BoxDecoration(
                                  color: _isDeviceOn 
                                      ? Colors.white.withAlpha(51) 
                                      : Colors.grey.withAlpha(26),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  widget.icon,
                                  color: _isDeviceOn ? Colors.white : Colors.grey.shade400,
                                  size: 24,
                                ),
                              ),
                              _buildStatusIndicator(),
                            ],
                          ),
                          
                          // Device Info
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.deviceName,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.deviceIp,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: textColor.withAlpha(179),
                                ),
                              ),
                              
                              // Power toggle button
                              const SizedBox(height: 12),
                              _buildToggleSwitch(primaryColor),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    // Ripple effect on tap
                    if (_isPressed)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            color: Colors.white.withAlpha(26),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPulseEffect(Color color) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(seconds: 2),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: math.sin(value * math.pi) * 0.15,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.5,
                colors: [
                  color.withAlpha(179),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        );
      },
      onEnd: () {
        // Restart the animation when it ends
        if (mounted) {
          setState(() {});
        }
      },
    );
  }

  Widget _buildStatusIndicator() {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: _isDeviceOn ? Colors.greenAccent : Colors.redAccent,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: _isDeviceOn
                    ? Colors.greenAccent.withAlpha(153)
                    : Colors.redAccent.withAlpha(77),
                blurRadius: 4,
                spreadRadius: 1,
              ),
            ],
          ),
        ),
        SizedBox(width: 6),
        Text(
          _isDeviceOn ? 'ONLINE' : 'OFFLINE',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: _isDeviceOn ? Colors.greenAccent : Colors.redAccent,
            letterSpacing: 1.0,
          ),
        ),
      ],
    );
  }

  Widget _buildToggleSwitch(Color primaryColor) {
    return GestureDetector(
      onTap: () => _toggleDevice(!_isDeviceOn),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.power_settings_new_rounded,
              color: _isDeviceOn ? Colors.white : Colors.grey.shade400,
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              _isDeviceOn ? 'TURN OFF' : 'TURN ON',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _isDeviceOn ? Colors.white : Colors.grey.shade400,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
