import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/floating_buttons.dart';
import '../../widgets/user_marker.dart'; // Logic embedded
import '../../services/location_service.dart';
import '../../services/supabase_service.dart';
import '../../services/routing_service.dart';
import '../../services/offline_tiles_service.dart';
import '../../models/location.dart';
import 'dart:math';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  MapLibreMapController? mapController;
  final SupabaseService _supabase = SupabaseService();
  final RoutingService _routing = RoutingService();
  final OfflineTilesService _offline = OfflineTilesService();
  
  List<UserLocation> _userLocations = [];
  
  // Navigation State
  bool _isNavigating = false;
  LatLng? _destination;
  List<LatLng> _routeCoords = [];
  
  static const LatLng _initialPosition = LatLng(52.5200, 13.4050);

  @override
  void initState() {
    super.initState();
    _subscribeToLocations();
  }

  void _subscribeToLocations() {
    _supabase.subscribeToLocations().listen((locations) {
      if (mounted) {
        setState(() {
          _userLocations = locations;
        });
        _updateMapMarkers();
      }
    });
  }

  void _onMapCreated(MapLibreMapController controller) {
    mapController = controller;
  }

  Future<void> _updateMapMarkers() async {
    if (mapController == null) return;
    await mapController!.clearCircles();
    // Re-draw circles
    for (var loc in _userLocations) {
      final isMe = loc.userId == _supabase.currentUser?.id;
      await mapController!.addCircle(
        CircleOptions(
          geometry: LatLng(loc.lat, loc.lng),
          circleColor: isMe ? '#00E676' : '#FF5252',
          circleRadius: 10,
          circleStrokeWidth: 2,
          circleStrokeColor: '#FFFFFF',
        ),
      );
    }
  }

  // Navigation Logic
  Future<void> _startNavigation(LatLng dest) async {
    final me = _userLocations.firstWhere((l) => l.userId == _supabase.currentUser?.id);
    final start = LatLng(me.lat, me.lng);
    
    // Calculate Route
    final route = await _routing.getRoute(start, dest);
    
    setState(() {
      _destination = dest;
      _routeCoords = route;
      _isNavigating = true;
    });

    // Draw Line
    if (mapController != null && route.isNotEmpty) {
      await mapController!.clearLines();
      await mapController!.addLine(
        LineOptions(
          geometry: route,
          lineColor: '#00E676',
          lineWidth: 5.0,
          lineOpacity: 0.8,
        ),
      );
    }
    
    // Notify Server
    _supabase.updateStatus("Navigating to Dest");
  }

  // Offline Logic
  Future<void> _downloadArea() async {
    if (mapController == null) return;
    
    // Get visible region
    final region = await mapController!.getVisibleRegion();
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Download Area?"),
        content: Text("Download visible tiles for offline use?\nZoom 12-14"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx), 
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _performDownload(region);
            }, 
            child: const Text("Download"),
          ),
        ],
      ),
    );
  }

  Future<void> _performDownload(LatLngBounds region) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Downloading tiles intentionally...")),
    );
    
    await _offline.downloadRegion(
      region.northeast.latitude,
      region.southwest.latitude,
      region.northeast.longitude,
      region.southwest.longitude,
    );
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Download Complete!")),
    );
  }

  // Gestures
  void _onMapClick(Point<double> point, LatLng coords) {
    if (!_isNavigating) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("Navigate here?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                _startNavigation(coords);
              },
              child: const Text("Go"),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          MapLibreMap(
            styleString: "https://demotiles.maplibre.org/style.json",
            initialCameraPosition: const CameraPosition(
              target: _initialPosition,
              zoom: 12,
            ),
            onMapCreated: _onMapCreated,
            myLocationEnabled: true,
            onMapClick: _onMapClick,
          ),
          
          // Helper Buttons
          Positioned(
            right: 20,
            bottom: 30, // Stacked 
            child: Column(
              children: [
                FloatingActionButton(
                  mini: true,
                  heroTag: "offline",
                  child: const Icon(Icons.download),
                  onPressed: _downloadArea,
                ),
                const SizedBox(height: 10),
                MapFloatingButtons(
                  onZoomIn: () => mapController?.animateCamera(CameraUpdate.zoomIn()),
                  onZoomOut: () => mapController?.animateCamera(CameraUpdate.zoomOut()),
                  onCompass: () => mapController?.animateCamera(CameraUpdate.bearingTo(0)),
                  onCenterLocation: () {}, // Already impl
                  onFriends: () => context.push('/friends'),
                ),
              ],
            ),
          ),
          
          if (_isNavigating)
             Positioned(
               top: 50,
               left: 20,
               right: 20,
               child: Container(
                 padding: const EdgeInsets.all(16),
                 color: Colors.black87,
                 child: Row(
                   children: [
                     const Icon(Icons.turn_right, size: 40, color: Colors.white),
                     const SizedBox(width: 10),
                     const Expanded(
                       child: Text(
                         "Follow route...", 
                         style: TextStyle(color: Colors.white, fontSize: 18),
                       ),
                     ),
                     IconButton(
                       icon: const Icon(Icons.close, color: Colors.red),
                       onPressed: () {
                         setState(() {
                           _isNavigating = false;
                           mapController?.clearLines();
                         });
                         _supabase.updateStatus("Online");
                       },
                     )
                   ],
                 ),
               ),
             ),
        ],
      ),
    );
  }
}
