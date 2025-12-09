import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'supabase_service.dart';

class LocationService {
  final SupabaseService _supabaseService = SupabaseService();
  StreamSubscription<Position>? _positionStream;
  
  // Throttle/Debounce state
  DateTime? _lastUpdate;
  static const Duration _throttleDuration = Duration(seconds: 1);
  static const double _minDistanceChange = 5.0; // meters

  Future<void> initialize() async {
    // 1. Request Permission
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied');
    }

    // 2. Start Listener
    _startPositionStream();
  }

  void _startPositionStream() {
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5, // Only notify if moved > 5m (Native filter)
    );

    _positionStream = Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((Position position) {
      _processLocationUpdate(position);
    });
  }

  void _processLocationUpdate(Position position) {
    final now = DateTime.now();

    // Custom Throttle Check (Time > 1s)
    if (_lastUpdate != null && now.difference(_lastUpdate!) < _throttleDuration) {
      return;
    }

    // Min Distance is handled by Geolocator stream, but we double check if needed
    // In this case, we trust the stream filter for distance + our time throttle.
    
    _lastUpdate = now;
    
    // Send to Supabase
    _supabaseService.updateLocation(
      position.latitude,
      position.longitude,
      'online', // Default status, logic can act on this later
    );
  }

  void dispose() {
    _positionStream?.cancel();
  }
}
