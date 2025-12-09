import 'package:dio/dio.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

class RoutingService {
  final Dio _dio = Dio();
  final String _osrmUrl = "http://router.project-osrm.org/route/v1/driving"; // Demo Server

  Future<List<LatLng>> getRoute(LatLng start, LatLng end) async {
    try {
      final response = await _dio.get(
        "$_osrmUrl/${start.longitude},${start.latitude};${end.longitude},${end.latitude}",
        queryParameters: {
          'overview': 'full',
          'geometries': 'geojson',
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final routes = data['routes'] as List;
        if (routes.isNotEmpty) {
          final geometry = routes[0]['geometry'];
          final coordinates = geometry['coordinates'] as List;
          
          return coordinates.map<LatLng>((coord) {
            return LatLng(coord[1], coord[0]); // GeoJSON is Lng,Lat
          }).toList();
        }
      }
    } catch (e) {
      print("Routing Error: $e");
    }
    return [];
  }
}
