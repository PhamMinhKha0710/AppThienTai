import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class StormLayer extends StatelessWidget {
  final LatLng center;
  final double eyeRadiusKm;
  final double windRadiusKm;
  final List<LatLng> track;

  const StormLayer({
    super.key,
    required this.center,
    required this.eyeRadiusKm,
    required this.windRadiusKm,
    required this.track,
  });

  // Tạo polygon tròn
  List<LatLng> _circle(LatLng c, double radiusKm, {int points = 80}) {
    const R = 6371.0; // km
    final d = radiusKm / R;
    final lat1 = c.latitude * pi / 180;
    final lon1 = c.longitude * pi / 180;

    final pts = <LatLng>[];
    for (int i = 0; i < points; i++) {
      final bearing = 2 * pi * i / points;
      final lat2 =
      asin(sin(lat1) * cos(d) + cos(lat1) * sin(d) * cos(bearing));
      final lon2 = lon1 +
          atan2(sin(bearing) * sin(d) * cos(lat1),
              cos(d) - sin(lat1) * sin(lat2));
      pts.add(LatLng(lat2 * 180 / pi, lon2 * 180 / pi));
    }
    return pts;
  }

  @override
  Widget build(BuildContext context) {
    return PolygonLayer(
      polygons: [
        // vùng gió mạnh
        Polygon(
          points: _circle(center, windRadiusKm),
          color: Colors.blue.withOpacity(0.12),
          borderColor: Colors.blue.withOpacity(0.6),
          borderStrokeWidth: 2,
        ),

        // mắt bão
        Polygon(
          points: _circle(center, eyeRadiusKm),
          color: Colors.red.withOpacity(0.15),
          borderColor: Colors.red.withOpacity(0.8),
          borderStrokeWidth: 2,
        ),
      ],
    );
  }
}
