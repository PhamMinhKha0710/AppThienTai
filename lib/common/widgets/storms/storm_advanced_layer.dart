// storm_advanced_layer.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_svg/flutter_svg.dart';

class StormAdvancedLayer extends StatefulWidget {
  final LatLng center;
  final double eyeRadiusKm;
  final double windRadiusKm;
  final List<LatLng> track; // ordered points of track
  final Duration trackDuration; // duration for a full loop of tracker
  final String? cloudSvgAsset; // e.g. 'assets/svgs/cloud_swirl.svg'
  final String? radarAsset; // e.g. 'assets/images/radar_overlay.png'
  final LatLngBounds? radarBounds; // bounds for radar image overlay (required if radarAsset provided)

  const StormAdvancedLayer({
    super.key,
    required this.center,
    this.eyeRadiusKm = 25,
    this.windRadiusKm = 150,
    this.track = const [],
    this.trackDuration = const Duration(seconds: 20),
    this.cloudSvgAsset,
    this.radarAsset,
    this.radarBounds,
  });

  @override
  State<StormAdvancedLayer> createState() => _StormAdvancedLayerState();
}

class _StormAdvancedLayerState extends State<StormAdvancedLayer>
    with TickerProviderStateMixin {
  late final AnimationController _spinCtrl;
  late final AnimationController _trackCtrl;
  final Distance _distance = const Distance();

  late List<double> _segmentKm; // lengths of segments
  late double _totalKm;

  @override
  void initState() {
    super.initState();

    _spinCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    _trackCtrl = AnimationController(
      vsync: this,
      duration: widget.trackDuration,
    )..repeat();

    _computeTrackLengths();
  }

  void _computeTrackLengths() {
    final pts = widget.track;
    final segs = <double>[];
    double total = 0.0;
    for (int i = 0; i + 1 < pts.length; i++) {
      final a = pts[i];
      final b = pts[i + 1];
      final km = _distance.as(LengthUnit.Kilometer, a, b);
      segs.add(km);
      total += km;
    }
    _segmentKm = segs;
    _totalKm = total;
  }

  @override
  void didUpdateWidget(covariant StormAdvancedLayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.track != oldWidget.track) {
      _computeTrackLengths();
    }
    if (widget.trackDuration != oldWidget.trackDuration) {
      _trackCtrl.duration = widget.trackDuration;
      _trackCtrl.reset();
      _trackCtrl.repeat();
    }
  }

  @override
  void dispose() {
    _spinCtrl.dispose();
    _trackCtrl.dispose();
    super.dispose();
  }

  // Great-circle position along track: fraction 0..1
  LatLng? _positionOnTrack(double frac) {
    final pts = widget.track;
    if (pts.isEmpty) return null;
    if (pts.length == 1) return pts[0];
    if (_totalKm == 0) return pts.first;

    final target = frac.clamp(0.0, 1.0) * _totalKm;
    double acc = 0.0;
    for (int i = 0; i < _segmentKm.length; i++) {
      final segLen = _segmentKm[i];
      if (acc + segLen >= target) {
        final inside = (target - acc) / segLen;
        final a = pts[i];
        final b = pts[i + 1];
        // linear interpolation on lat/lng (acceptable for short segments)
        final lat = a.latitude + (b.latitude - a.latitude) * inside;
        final lng = a.longitude + (b.longitude - a.longitude) * inside;
        return LatLng(lat, lng);
      }
      acc += segLen;
    }
    return pts.last;
  }

  // create circle polygon accurate on globe
  List<LatLng> _circle(LatLng center, double radiusKm, {int points = 64}) {
    const R = 6371.0;
    final d = radiusKm / R;
    final lat1 = center.latitude * pi / 180;
    final lon1 = center.longitude * pi / 180;

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
    return AnimatedBuilder(
      animation: Listenable.merge([_spinCtrl, _trackCtrl]),
      builder: (context, _) {
        // pulse effect
        final pulse = 1.0 + sin(_spinCtrl.value * 2 * pi) * 0.06;
        final windR = widget.windRadiusKm * (1.0 + 0.06 * sin(_spinCtrl.value * 2 * pi));
        final eyeR = widget.eyeRadiusKm * (0.9 + 0.1 * cos(_spinCtrl.value * 2 * pi));

        // collect layer widgets to render inside this wrapper
        final List<Widget> children = [];

        // Radar overlay if provided (use OverlayImageLayer + OverlayImage)
        if (widget.radarAsset != null && widget.radarBounds != null) {
          children.add(
            OverlayImageLayer(
              overlayImages: [
                OverlayImage(
                  bounds: widget.radarBounds!,
                  imageProvider: AssetImage(widget.radarAsset!),
                  opacity: 0.75,
                ),
              ],
            ),
          );
        }

        // Wind polygon + eye polygon
        children.add(
          PolygonLayer(
            polygons: [
              Polygon(
                points: _circle(widget.center, windR),
                color: Colors.blue.withOpacity(0.12 * pulse),
                borderColor: Colors.blue.withOpacity(0.45),
                borderStrokeWidth: 2,
              ),
              Polygon(
                points: _circle(widget.center, eyeR),
                color: Colors.red.withOpacity(0.12),
                borderColor: Colors.red.withOpacity(0.7),
                borderStrokeWidth: 2,
              ),
            ],
          ),
        );

        // Track polyline (static)
        if (widget.track.length > 1) {
          children.add(
            PolylineLayer(
              polylines: [
                Polyline(points: widget.track, strokeWidth: 3),
              ],
            ),
          );
        }

        // moving tracker along track
        final trackerPos = _positionOnTrack(_trackCtrl.value);
        if (trackerPos != null) {
          children.add(
            MarkerLayer(
              markers: [
                Marker(
                  point: trackerPos,
                  width: 18,
                  height: 18,
                 child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.yellowAccent,
                      boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
                    ),
                  ),
                )
              ],
            ),
          );
        }

        // Storm rotating icon + cloud SVG (cloud placed slightly offset above center)
        children.add(
          MarkerLayer(
            markers: [
              Marker(
                point: widget.center,
                width: 64,
                height: 64,
                child: Transform.rotate(
                  angle: _spinCtrl.value * 2 * pi,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      // gradient: RadialGradient(colors: [Colors.white, Colors.orange.shade700]),
                      boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 6)],
                    ),
                    child: const Center(child: Text('🌀', style: TextStyle(fontSize: 26))),
                  ),
                ),
              ),
              if (widget.cloudSvgAsset != null)
                Marker(
                  point: LatLng(widget.center.latitude + 0.03, widget.center.longitude + 0.03),
                  width: 80,
                  height: 80,
                  child: IgnorePointer(
                    child: Opacity(
                      opacity: 0.7,
                      child: SvgPicture.asset(widget.cloudSvgAsset!, fit: BoxFit.contain),
                    ),
                  ),
                ),
            ],
          ),
        );

        // Return a Stack that contains the layer widgets — place StormAdvancedLayer inside FlutterMap.children
        return Stack(children: children);
      },
    );
  }
}
