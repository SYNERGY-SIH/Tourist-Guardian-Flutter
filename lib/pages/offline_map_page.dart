import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:my_app/utils/colors.dart';
import 'package:my_app/widgets/custom_button.dart';

enum ZoneType { red, yellow, grey }

class Zone {
  final String id;
  final LatLng center;
  final ZoneType type;

  Zone({required this.id, required this.center, required this.type});
}

class OfflineMapPage extends StatefulWidget {
  const OfflineMapPage({Key? key}) : super(key: key);

  @override
  State<OfflineMapPage> createState() => _OfflineMapPageState();
}

class _OfflineMapPageState extends State<OfflineMapPage> {
  GoogleMapController? _mapController;

  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(26.1445, 91.7362),
    zoom: 6.5,
  );

  final Set<Marker> _touristMarkers = {
    const Marker(markerId: MarkerId("Tawang Monastery"), position: LatLng(27.5873, 91.8590), infoWindow: InfoWindow(title: "Tawang Monastery", snippet: "Arunachal Pradesh")),
    const Marker(markerId: MarkerId("Kaziranga National Park"), position: LatLng(26.5786, 93.1709), infoWindow: InfoWindow(title: "Kaziranga National Park", snippet: "Assam")),
    const Marker(markerId: MarkerId("Nohkalikai Falls"), position: LatLng(25.2769, 91.6882), infoWindow: InfoWindow(title: "Nohkalikai Falls", snippet: "Meghalaya")),
    const Marker(markerId: MarkerId("Loktak Lake"), position: LatLng(24.5425, 93.8051), infoWindow: InfoWindow(title: "Loktak Lake", snippet: "Manipur")),
  };

  final List<Zone> _zones = [
    // Red Zones
    Zone(id: "r1", center: const LatLng(26.18, 91.74), type: ZoneType.red),
    Zone(id: "r2", center: const LatLng(25.57, 91.89), type: ZoneType.red),
    // ... other red zones

    // Yellow Zones
    Zone(id: "y1", center: const LatLng(27.68, 92.40), type: ZoneType.yellow),
    Zone(id: "y2", center: const LatLng(26.75, 94.21), type: ZoneType.yellow),
    // ... other yellow zones

    // Grey Zones for Natural Disasters
    Zone(id: "g1", center: const LatLng(27.33, 92.64), type: ZoneType.grey),
    // NEW: Additional Grey Zones
    Zone(id: "g2", center: const LatLng(23.36, 92.71), type: ZoneType.grey), // Mizoram - Landslide Prone
    Zone(id: "g3", center: const LatLng(25.90, 93.75), type: ZoneType.grey), // Nagaland - Flood Prone
    Zone(id: "g4", center: const LatLng(27.60, 95.35), type: ZoneType.grey), // Arunachal - Remote Area
  ];

  Set<Circle> _zoneCircles = {};
  Set<Marker> _zoneMarkers = {};
  Set<Marker> _safePointMarkers = {};

  @override
  void initState() {
    super.initState();
    _buildZones();
    _loadCustomMarkers();
  }

  void _loadCustomMarkers() async {
    final BitmapDescriptor hospitalIcon = await _createCustomMarkerBitmap(Icons.local_hospital, Colors.green);
    final BitmapDescriptor policeIcon = await _createCustomMarkerBitmap(Icons.local_police, Colors.blue);

    final safePoints = <Marker>{
      // Hospitals
      Marker(markerId: const MarkerId("h1"), position: const LatLng(26.14, 91.75), infoWindow: const InfoWindow(title: "Guwahati Medical College"), icon: hospitalIcon),
      Marker(markerId: const MarkerId("h2"), position: const LatLng(25.57, 91.88), infoWindow: const InfoWindow(title: "NEIGRIHMS Hospital, Shillong"), icon: hospitalIcon),
      Marker(markerId: const MarkerId("h3"), position: const LatLng(27.48, 94.92), infoWindow: const InfoWindow(title: "Assam Medical College, Dibrugarh"), icon: hospitalIcon),

      // Police Stations (Original 3)
      Marker(markerId: const MarkerId("p1"), position: const LatLng(26.19, 91.75), infoWindow: const InfoWindow(title: "Paltan Bazaar Police Station"), icon: policeIcon),
      Marker(markerId: const MarkerId("p2"), position: const LatLng(25.57, 91.89), infoWindow: const InfoWindow(title: "Sadar Police Station, Shillong"), icon: policeIcon),
      Marker(markerId: const MarkerId("p3"), position: const LatLng(23.83, 91.27), infoWindow: const InfoWindow(title: "Agartala West Police Station"), icon: policeIcon),
      
      // NEW: 20 Additional Police Stations
      Marker(markerId: const MarkerId("p4"), position: const LatLng(26.15, 91.73), infoWindow: const InfoWindow(title: "Dispur Police Station, Guwahati"), icon: policeIcon),
      Marker(markerId: const MarkerId("p5"), position: const LatLng(24.81, 93.93), infoWindow: const InfoWindow(title: "Imphal Police Station, Manipur"), icon: policeIcon),
      Marker(markerId: const MarkerId("p6"), position: const LatLng(23.72, 92.71), infoWindow: const InfoWindow(title: "Aizawl Police Station, Mizoram"), icon: policeIcon),
      Marker(markerId: const MarkerId("p7"), position: const LatLng(25.67, 94.12), infoWindow: const InfoWindow(title: "Kohima North Police Station, Nagaland"), icon: policeIcon),
      Marker(markerId: const MarkerId("p8"), position: const LatLng(27.08, 93.62), infoWindow: const InfoWindow(title: "Itanagar Police Station, Arunachal Pradesh"), icon: policeIcon),
      Marker(markerId: const MarkerId("p9"), position: const LatLng(26.74, 94.20), infoWindow: const InfoWindow(title: "Jorhat Police Station, Assam"), icon: policeIcon),
      Marker(markerId: const MarkerId("p10"), position: const LatLng(27.47, 94.90), infoWindow: const InfoWindow(title: "Dibrugarh Police Station, Assam"), icon: policeIcon),
      Marker(markerId: const MarkerId("p11"), position: const LatLng(25.59, 91.87), infoWindow: const InfoWindow(title: "Laitumkhrah Police Station, Meghalaya"), icon: policeIcon),
      Marker(markerId: const MarkerId("p12"), position: const LatLng(24.80, 92.79), infoWindow: const InfoWindow(title: "Silchar Police Station, Assam"), icon: policeIcon),
      Marker(markerId: const MarkerId("p13"), position: const LatLng(23.84, 91.28), infoWindow: const InfoWindow(title: "East Agartala Police Station, Tripura"), icon: policeIcon),
      Marker(markerId: const MarkerId("p14"), position: const LatLng(25.91, 93.73), infoWindow: const InfoWindow(title: "Dimapur East Police Station, Nagaland"), icon: policeIcon),
      Marker(markerId: const MarkerId("p15"), position: const LatLng(27.58, 91.85), infoWindow: const InfoWindow(title: "Tawang Police Station, Arunachal Pradesh"), icon: policeIcon),
      Marker(markerId: const MarkerId("p16"), position: const LatLng(26.40, 90.56), infoWindow: const InfoWindow(title: "Bongaigaon Police Station, Assam"), icon: policeIcon),
      Marker(markerId: const MarkerId("p17"), position: const LatLng(24.91, 93.94), infoWindow: const InfoWindow(title: "Porompat Police Station, Manipur"), icon: policeIcon),
      Marker(markerId: const MarkerId("p18"), position: const LatLng(25.13, 92.27), infoWindow: const InfoWindow(title: "Jowai Police Station, Meghalaya"), icon: policeIcon),
      Marker(markerId: const MarkerId("p19"), position: const LatLng(22.84, 92.29), infoWindow: const InfoWindow(title: "Lunglei Police Station, Mizoram"), icon: policeIcon),
      Marker(markerId: const MarkerId("p20"), position: const LatLng(26.23, 92.80), infoWindow: const InfoWindow(title: "Nagaon Police Station, Assam"), icon: policeIcon),
      Marker(markerId: const MarkerId("p21"), position: const LatLng(26.90, 89.47), infoWindow: const InfoWindow(title: "Alipurduar Police Station, West Bengal (border)"), icon: policeIcon),
      Marker(markerId: const MarkerId("p22"), position: const LatLng(27.28, 95.91), infoWindow: const InfoWindow(title: "Tinsukia Police Station, Assam"), icon: policeIcon),
      Marker(markerId: const MarkerId("p23"), position: const LatLng(27.97, 95.33), infoWindow: const InfoWindow(title: "Roing Police Station, Arunachal Pradesh"), icon: policeIcon),
    };

    if (mounted) {
      setState(() {
        _safePointMarkers = safePoints;
      });
    }
  }
  
  void _buildZones() {
    final circles = <Circle>{};
    final markers = <Marker>{};

    for (final zone in _zones) {
      final double radius = zone.type == ZoneType.red ? 20000 : (zone.type == ZoneType.yellow ? 10000 : 30000);
      final Color fillColor = zone.type == ZoneType.red ? Colors.red.withOpacity(0.3) : (zone.type == ZoneType.yellow ? Colors.yellow.withOpacity(0.3) : Colors.grey.withOpacity(0.4));
      final Color strokeColor = zone.type == ZoneType.red ? Colors.red : (zone.type == ZoneType.yellow ? Colors.yellow : Colors.grey);
      final String snippet = zone.type == ZoneType.red
          ? "High number of crime reports in this area."
          : (zone.type == ZoneType.yellow
              ? "Area with moderate crime reports. Caution advised."
              : "Natural Disaster Alert: High risk of landslides/floods.");

      circles.add(
        Circle(
          circleId: CircleId(zone.id),
          center: zone.center,
          radius: radius,
          fillColor: fillColor,
          strokeColor: strokeColor,
          strokeWidth: 2,
        ),
      );

      markers.add(
        Marker(
          markerId: MarkerId("marker_${zone.id}"),
          position: zone.center,
          alpha: 0.0,
          anchor: const Offset(0.5, 0.5),
          infoWindow: InfoWindow(
            title: zone.type == ZoneType.grey ? "Natural Disaster Zone" : "Alert Zone",
            snippet: snippet,
          ),
        ),
      );
    }
    
    if (mounted) {
      setState(() {
        _zoneCircles = circles;
        _zoneMarkers = markers;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
              child: GoogleMap(
                initialCameraPosition: _initialPosition,
                onMapCreated: (controller) => _mapController = controller,
                markers: _touristMarkers.union(_zoneMarkers).union(_safePointMarkers),
                circles: _zoneCircles,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
              ),
            ),
          ),
          _buildActivitySection(),
        ],
      ),
    );
  }

  Widget _buildActivitySection() {
    return Container(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text("Activity Section", textAlign: TextAlign.center, style: TextStyle(color: AppColors.text, fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          CustomButton(text: "Report an Incident", onPressed: () {}),
          const SizedBox(height: 12),
          CustomButton(text: "Self-Defense Tutorials", onPressed: () {}),
        ],
      ),
    );
  }

  Future<BitmapDescriptor> _createCustomMarkerBitmap(IconData iconData, Color color) async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final Paint paint = Paint()..color = color;
    const double size = 100.0;
    
    canvas.drawCircle(const Offset(size / 2, size / 2), size / 2, paint);
    
    final TextPainter textPainter = TextPainter(textDirection: TextDirection.ltr);
    textPainter.text = TextSpan(
      text: String.fromCharCode(iconData.codePoint),
      style: TextStyle(
        fontSize: size * 0.6,
        fontFamily: iconData.fontFamily,
        color: Colors.white,
      ),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset((size - textPainter.width) / 2, (size - textPainter.height) / 2));
    
    final img = await pictureRecorder.endRecording().toImage(size.toInt(), size.toInt());
    final data = await img.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.fromBytes(data!.buffer.asUint8List());
  }
}