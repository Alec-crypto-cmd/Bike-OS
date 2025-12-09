import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'dart:math';

class OfflineTilesService {
  final Dio _dio = Dio();
  
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  String _getTileUrl(int z, int x, int y) {
    return "https://tile.openstreetmap.org/$z/$x/$y.png";
  }

  // Calculate tiles in bounding box
  List<Point<int>> _getTilesInBbox(double north, double south, double east, double west, int zoom) {
    // Basic tile math
    int long2tile(double lon) => ((lon + 180) / 360 * (1 << zoom)).floor();
    int lat2tile(double lat) => ((1 - log(tan(lat * pi / 180) + 1 / cos(lat * pi / 180)) / pi) / 2 * (1 << zoom)).floor();

    int x1 = long2tile(west);
    int x2 = long2tile(east);
    int y1 = lat2tile(north);
    int y2 = lat2tile(south);

    List<Point<int>> tiles = [];
    for (int x = x1; x <= x2; x++) {
      for (int y = y1; y <= y2; y++) {
        tiles.add(Point(x, y));
      }
    }
    return tiles;
  }

  Future<void> downloadRegion(double north, double south, double east, double west, {int minZoom = 12, int maxZoom = 14}) async {
    final path = await _localPath;
    final saveDir = Directory('$path/tiles');
    if (!saveDir.existsSync()) {
      saveDir.createSync(recursive: true);
    }

    for (int z = minZoom; z <= maxZoom; z++) {
      final tiles = _getTilesInBbox(north, south, east, west, z);
      
      for (var tile in tiles) {
        final url = _getTileUrl(z, tile.x, tile.y);
        final fileDest = '${saveDir.path}/$z/${tile.x}/${tile.y}.png';
        final file = File(fileDest);
        
        if (!file.existsSync()) {
          try {
            file.createSync(recursive: true);
            await _dio.download(url, fileDest);
            // In a real app, update progress stream here
          } catch (e) {
            print("Failed to download tile $z/${tile.x}/${tile.y}");
          }
        }
      }
    }
  }

  // Setup MapLibre to read local schema if offline
  // This usually involves a local server or a custom protocol.
  // For simplicity script, we return the path where tiles are stored.
  Future<String> getOfflineTilePath() async {
    final path = await _localPath;
    return '$path/tiles/{z}/{x}/{y}.png';
  }
}
