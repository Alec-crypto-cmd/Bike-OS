class UserLocation {
  final String userId;
  final double lat;
  final double lng;
  final DateTime updatedAt;
  final String status; // 'online', 'navigating', 'inactive'

  UserLocation({
    required this.userId,
    required this.lat,
    required this.lng,
    required this.updatedAt,
    required this.status,
  });

  factory UserLocation.fromJson(Map<String, dynamic> json) {
    return UserLocation(
      userId: json['user_id'] as String,
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      status: json['status'] as String? ?? 'online',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'lat': lat,
      'lng': lng,
      'updated_at': updatedAt.toIso8601String(),
      'status': status,
    };
  }
}
