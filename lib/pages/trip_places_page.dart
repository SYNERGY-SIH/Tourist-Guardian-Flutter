import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart'; // <-- IMPORT a
import 'package:my_app/utils/colors.dart';
import 'package:my_app/widgets/custom_button.dart';

// A simple data class to hold place information
class Place {
  final String name;
  final LatLng? coordinates; // Nullable for places added by name

  Place({required this.name, this.coordinates});
}

class TripPlacesPage extends StatefulWidget {
  const TripPlacesPage({Key? key}) : super(key: key);

  @override
  _TripPlacesPageState createState() => _TripPlacesPageState();
}

class _TripPlacesPageState extends State<TripPlacesPage> {
  final _listKey = GlobalKey<AnimatedListState>();
  final TextEditingController _placeController = TextEditingController();
  final List<Place> _places = [];
  final Completer<GoogleMapController> _mapController = Completer();

  // NEW: State for loading indicators
  bool _isGeocoding = false;

  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(26.1445, 91.7362),
    zoom: 6.5,
  );

  // MODIFIED: Reverse geocoding to get address from tap
  void _addPlaceFromTap(LatLng position) async {
    try {
      final List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        // Create a user-friendly name from the placemark details
        final placeName = "${placemark.name}, ${placemark.locality}".replaceAll(", ,", ",");
        final newPlace = Place(name: placeName, coordinates: position);

        setState(() {
          _places.insert(0, newPlace);
          _listKey.currentState?.insertItem(0, duration: const Duration(milliseconds: 300));
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Could not determine address for this location.")),
      );
    }
  }

  // MODIFIED: Geocoding to get coordinates from text
  void _addPlaceFromText() async {
    final placeName = _placeController.text.trim();
    if (placeName.isEmpty) return;

    setState(() => _isGeocoding = true); // Show loading indicator

    try {
      final List<Location> locations = await locationFromAddress(placeName);
      if (locations.isNotEmpty) {
        final location = locations.first;
        final newPlace = Place(
          name: placeName,
          coordinates: LatLng(location.latitude, location.longitude),
        );
        setState(() {
          _places.insert(0, newPlace);
          _listKey.currentState?.insertItem(0, duration: const Duration(milliseconds: 300));
          _placeController.clear();
          FocusScope.of(context).unfocus();
        });
        // Animate map to the new location
        final controller = await _mapController.future;
        controller.animateCamera(CameraUpdate.newLatLngZoom(newPlace.coordinates!, 12));
      } else {
        throw Exception("No location found.");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Could not find location: '$placeName'")),
      );
    } finally {
      setState(() => _isGeocoding = false); // Hide loading indicator
    }
  }


  // Unchanged methods...
  void _removePlace(int index) {
    setState(() {
      final removedPlace = _places.removeAt(index);
      _listKey.currentState?.removeItem(
        index,
        (context, animation) => _buildRemovedItem(removedPlace, animation),
        duration: const Duration(milliseconds: 300),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final Set<Marker> markers = _places
        .where((p) => p.coordinates != null)
        .map((p) => Marker(
              markerId: MarkerId(p.name),
              position: p.coordinates!,
              infoWindow: InfoWindow(title: p.name),
            ))
        .toSet();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Plan Your Itinerary"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildMapView(markers),
              const SizedBox(height: 20),
              _buildPlaceInputField(), // This widget is now updated
              const SizedBox(height: 20),
              const Text(
                "Selected Places",
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              _places.isEmpty
                  ? _buildEmptyState()
                  : _buildPlacesList(),
              const SizedBox(height: 20),
              CustomButton(
                text: "Finish and Get ID",
                onPressed: () {
                  if (_places.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Please add at least one place."),
                        backgroundColor: AppColors.error,
                      ),
                    );
                    return;
                  }
                  Navigator.pushNamed(context, '/home');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMapView(Set<Marker> markers) {
    return SizedBox(
      height: 300,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: GoogleMap(
          initialCameraPosition: _initialPosition,
          onMapCreated: (controller) {
            if (!_mapController.isCompleted) _mapController.complete(controller);
          },
          markers: markers,
          onTap: _addPlaceFromTap,
        ),
      ),
    );
  }

  // MODIFIED: Input field now shows a loading indicator
  Widget _buildPlaceInputField() {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: _placeController,
            onFieldSubmitted: (_) => _addPlaceFromText(),
            decoration: InputDecoration(
              hintText: "Or type a place name...",
              filled: true,
              fillColor: AppColors.surface,
              prefixIcon: const Icon(Icons.edit_location_alt_outlined, color: AppColors.textSecondary),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
            style: const TextStyle(color: AppColors.text),
          ),
        ),
        const SizedBox(width: 8),
        _isGeocoding
          ? const CircularProgressIndicator()
          : IconButton.filled(
              style: IconButton.styleFrom(backgroundColor: AppColors.primary),
              icon: const Icon(Icons.add, color: Colors.white),
              onPressed: _addPlaceFromText,
            ),
      ],
    );
  }

  // The rest of the build methods are unchanged...
  Widget _buildPlacesList() {
    return AnimatedList(
      key: _listKey,
      initialItemCount: _places.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index, animation) {
        final place = _places[index];
        return SizeTransition(
          sizeFactor: animation,
          child: Card(
            margin: const EdgeInsets.symmetric(vertical: 4),
            elevation: 0,
            color: AppColors.surface,
            child: ListTile(
              leading: Icon(
                place.coordinates != null ? Icons.pin_drop_outlined : Icons.notes_rounded,
                color: AppColors.primary
              ),
              title: Text(place.name, style: const TextStyle(color: AppColors.text)),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline, color: AppColors.error),
                onPressed: () => _removePlace(index),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
     return Card(
      elevation: 0,
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Icon(Icons.info_outline, color: AppColors.primary),
            const SizedBox(height: 12),
            const Text(
              "Your itinerary is empty. Tap on the map or type a name to add a destination.",
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRemovedItem(Place place, Animation<double> animation) {
    return SizeTransition(
      sizeFactor: animation,
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 4),
        color: AppColors.error.withOpacity(0.5),
        child: ListTile(
          leading: const Icon(Icons.delete_outline, color: Colors.white),
          title: Text(
            place.name,
            style: const TextStyle(
              color: Colors.white,
              decoration: TextDecoration.lineThrough,
            ),
          ),
        ),
      ),
    );
  }
}