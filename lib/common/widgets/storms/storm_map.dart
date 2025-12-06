// lib/widgets/storm_map.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

// Helper: sinh polygon mô tả vòng tròn (độ chính xác tốt cho km)
List<LatLng> circlePolygon(LatLng center, double radiusKm, {int points = 64}) {
  final R = 6371.0; // Earth radius km
  final lat1 = center.latitudeInRad;
  final lon1 = center.longitudeInRad;
  final d = radiusKm / R;
  final coords = <LatLng>[];
  for (int i = 0; i < points; i++) {
    final bearing = 2 * pi * i / points;
    final lat2 = asin(sin(lat1) * cos(d) + cos(lat1) * sin(d) * cos(bearing));
    final lon2 = lon1 +
        atan2(sin(bearing) * sin(d) * cos(lat1),
            cos(d) - sin(lat1) * sin(lat2));
    coords.add(LatLng(lat2 * 180 / pi, lon2 * 180 / pi));
  }
  return coords;
}

// Stateful widget để support animation (xoay icon)
class StormMap extends StatefulWidget {
  final LatLng stormCenter;
  final double eyeRadiusKm; // bán kính mắt bão
  final double windRadiusKm; // bán kính gió mạnh
  final List<LatLng>? track; // đường di chuyển

  const StormMap({
    super.key,
    required this.stormCenter,
    this.eyeRadiusKm = 20,
    this.windRadiusKm = 150,
    this.track,
  });

  @override
  State<StormMap> createState() => _StormMapState();
}

class _StormMapState extends State<StormMap> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 6))
      ..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final eyePoly = circlePolygon(widget.stormCenter, widget.eyeRadiusKm, points: 80);
    final windPoly = circlePolygon(widget.stormCenter, widget.windRadiusKm, points: 120);

    // sample custom storm icon - you can use an asset instead
    final stormIcon = Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [Colors.white, Colors.orange.shade700]),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 6)],
      ),
      child: Center(child: Text('🌀', style: TextStyle(fontSize: 20))),
    );

    return FlutterMap(
      options: MapOptions(
        initialCenter: widget.stormCenter,
        initialZoom: 6.0,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
          subdomains: const ['a', 'b', 'c'],
        ),
        // Wind radius polygon (semi-transparent)
        PolygonLayer(
          polygons: [
            Polygon(
              points: windPoly,
              color: Colors.blue.withOpacity(0.12),
              borderColor: Colors.blue.withOpacity(0.5),
              borderStrokeWidth: 2,
            ),
            // Eye ring
            Polygon(
              points: eyePoly,
              color: Colors.red.withOpacity(0.06),
              borderColor: Colors.red.withOpacity(0.7),
              borderStrokeWidth: 2,
            ),
          ],
        ),
        // Track polyline
        if (widget.track != null && widget.track!.length > 1)
          PolylineLayer(
            polylines: [
              Polyline(points: widget.track!, strokeWidth: 3, ),
            ],
          ),
        // Animated rotating storm marker
        MarkerLayer(
          markers: [
            Marker(
              point: widget.stormCenter,
              width: 64,
              height: 64,
              child: AnimatedBuilder(
                animation: _ctrl,
                builder: (_, child) {
                  return Transform.rotate(
                    angle: _ctrl.value * 2 * pi,
                    child: child,
                  );
                },
                child: stormIcon,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
