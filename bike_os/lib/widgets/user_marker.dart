import 'package:flutter/material.dart';

class UserMarkerWidget extends StatelessWidget {
  final String username;
  final String avatarUrl;
  final String? status;
  final bool isMe;

  const UserMarkerWidget({
    super.key,
    required this.username,
    required this.avatarUrl,
    this.status,
    this.isMe = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Avatar Circle
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: isMe ? const Color(0xFF00E676) : Colors.white,
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
            image: DecorationImage(
              image: NetworkImage(avatarUrl),
              fit: BoxFit.cover,
            ),
          ),
        ),
        
        // Name Tag
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            username,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black),
          ),
        ),

        // Status Tag
        if (status != null && status!.isNotEmpty) ...[
          const SizedBox(height: 2),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              status!,
              style: const TextStyle(fontSize: 9, color: Colors.white),
            ),
          ),
        ]
      ],
    );
  }
}
