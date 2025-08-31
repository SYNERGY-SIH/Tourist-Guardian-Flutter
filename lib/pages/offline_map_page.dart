import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:my_app/utils/colors.dart';
import 'package:my_app/widgets/custom_button.dart';

// Enum to define the type of zone
enum ZoneType { red, yellow }

// A data class to hold zone information
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

  // Markers for popular tourist spots (unchanged)
  final Set<Marker> _touristMarkers = {
    const Marker(
        markerId: MarkerId("Tawang Monastery"),
        position: LatLng(27.5873, 91.8590),
        infoWindow:
            InfoWindow(title: "Tawang Monastery", snippet: "Arunachal Pradesh")),
    const Marker(
      markerId: MarkerId("Kaziranga National Park"),
      position: LatLng(26.5786, 93.1709),
      infoWindow: InfoWindow(title: "Kaziranga National Park", snippet: "Assam"),
    ),
    const Marker(
      markerId: MarkerId("Nohkalikai Falls"),
      position: LatLng(25.2769, 91.6882),
      infoWindow: InfoWindow(title: "Nohkalikai Falls", snippet: "Meghalaya"),
    ),
    const Marker(
      markerId: MarkerId("Loktak Lake"),
      position: LatLng(24.5425, 93.8051),
      infoWindow: InfoWindow(title: "Loktak Lake", snippet: "Manipur"),
    ),
  };

  // ### NEW: A list of all zones ###
  final List<Zone> _zones = [
    // Red Zones
    Zone(id: "r1", center: const LatLng(26.18, 91.74), type: ZoneType.red),
    Zone(id: "r2", center: const LatLng(25.57, 91.89), type: ZoneType.red),
    Zone(id: "r3", center: const LatLng(27.47, 94.91), type: ZoneType.red),
    Zone(id: "r4", center: const LatLng(23.83, 91.28), type: ZoneType.red),
    Zone(id: "r5", center: const LatLng(24.80, 93.94), type: ZoneType.red),
    Zone(id: "r6", center: const LatLng(25.67, 94.10), type: ZoneType.red),
    Zone(id: "r7", center: const LatLng(27.09, 89.63), type: ZoneType.red),
    Zone(id: "r8", center: const LatLng(27.98, 95.34), type: ZoneType.red),
    Zone(id: "r9", center: const LatLng(23.76, 92.71), type: ZoneType.red),
    Zone(id: "r10", center: const LatLng(25.16, 93.03), type: ZoneType.red),
    
    // Yellow Zones
    Zone(id: "y1", center: const LatLng(27.68, 92.40), type: ZoneType.yellow),
    Zone(id: "y2", center: const LatLng(26.75, 94.21), type: ZoneType.yellow),
    Zone(id: "y3", center: const LatLng(25.31, 92.79), type: ZoneType.yellow),
    Zone(id: "y4", center: const LatLng(24.49, 92.60), type: ZoneType.yellow),
    Zone(id: "y5", center: const LatLng(23.36, 91.98), type: ZoneType.yellow),
    Zone(id: "y6", center: const LatLng(26.08, 90.63), type: ZoneType.yellow),
    Zone(id: "y7", center: const LatLng(26.91, 95.01), type: ZoneType.yellow),
    Zone(id: "y8", center: const LatLng(22.97, 92.29), type: ZoneType.yellow),
    Zone(id: "y9", center: const LatLng(24.89, 94.62), type: ZoneType.yellow),
    Zone(id: "y10", center: const LatLng(27.33, 90.65), type: ZoneType.yellow),
  ];

  // State variables to hold the generated map objects
  Set<Circle> _zoneCircles = {};
  Set<Marker> _zoneMarkers = {};

  @override
  void initState() {
    super.initState();
    _buildZones();
  }

  // ### NEW: Method to generate circles and tappable markers from the zone list ###
  void _buildZones() {
    final circles = <Circle>{};
    final markers = <Marker>{};

    for (final zone in _zones) {
      // Create the visible circle
      circles.add(
        Circle(
          circleId: CircleId(zone.id),
          center: zone.center,
          // Increased radius: 20km for red, 10km for yellow
          radius: zone.type == ZoneType.red ? 20000 : 10000,
          fillColor: zone.type == ZoneType.red
              ? Colors.red.withOpacity(0.3)
              : Colors.yellow.withOpacity(0.3),
          strokeColor: zone.type == ZoneType.red ? Colors.red : Colors.yellow,
          strokeWidth: 2,
        ),
      );

      // Create the invisible, tappable marker for the info window
      markers.add(
        Marker(
          markerId: MarkerId("marker_${zone.id}"),
          position: zone.center,
          // Make the marker invisible by setting its opacity to 0
          alpha: 0.0,
          // Center the tap target on the circle's center point
          anchor: const Offset(0.5, 0.5),
          infoWindow: const InfoWindow(
            title: "Alert Zone",
            snippet: "Recently 15 crime reports filed in this area.",
          ),
        ),
      );
    }
    
    setState(() {
      _zoneCircles = circles;
      _zoneMarkers = markers;
    });
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
                // Combine the tourist markers and the invisible zone markers
                markers: _touristMarkers.union(_zoneMarkers),
                circles: _zoneCircles, // Add the circles to the map
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
          const Text(
            "Activity Section",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.text,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          CustomButton(
            text: "Report an Incident",
            onPressed: () => print("Report Incident Tapped"),
          ),
          const SizedBox(height: 12),
          CustomButton(
            text: "Self-Defense Tutorials",
            onPressed: () => print("Self-Defense Tutorials Tapped"),
          ),
        ],
      ),
    );
  }
}