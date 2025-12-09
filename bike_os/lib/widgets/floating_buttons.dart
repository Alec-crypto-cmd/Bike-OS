import 'package:flutter/material.dart';

class MapFloatingButtons extends StatelessWidget {
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onCenterLocation;
  final VoidCallback onCompass;
  final VoidCallback onFriends;

  const MapFloatingButtons({
    super.key,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onCenterLocation,
    required this.onCompass,
    required this.onFriends,
  });

  Widget _buildBtn(IconData icon, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: FloatingActionButton(
        heroTag: null, // Avoid tag conflicts
        mini: true,
        backgroundColor: const Color(0xFF1E1E1E),
        foregroundColor: Colors.white,
        onPressed: onTap,
        child: Icon(icon),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _buildBtn(Icons.people, onFriends),
        const SizedBox(height: 10),
        _buildBtn(Icons.explore, onCompass),
        _buildBtn(Icons.add, onZoomIn),
        _buildBtn(Icons.remove, onZoomOut),
        _buildBtn(Icons.my_location, onCenterLocation),
      ],
    );
  }
}
