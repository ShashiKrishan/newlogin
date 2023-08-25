import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'home.dart';

class AddNewLocationsPage extends StatefulWidget {
  @override
  _AddNewLocationsPageState createState() => _AddNewLocationsPageState();
}

class _AddNewLocationsPageState extends State<AddNewLocationsPage> {
  GoogleMapController? mapController;
  late Position currentLocation;
  Set<Marker> _markers = {};
  bool _isLoading = true;
  TextEditingController _locationNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
  }

  void getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location service is enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location service is not enabled, handle it accordingly
      return;
    }

    // Check location permission
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      // Request location permission
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        // Handle location permission denied
        return;
      }
    }

    // Get current location
    currentLocation = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    setState(() {
      _isLoading = false;
      addMarker();
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    addMarker();
  }

  void addMarker() {
    setState(() {
      _markers.add(Marker(
        markerId: MarkerId('currentLocation'),
        position: LatLng(currentLocation.latitude, currentLocation.longitude),
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Location'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
            );
          },
        ),
      ),
      body: _isLoading
          ? Center(
        child: CircularProgressIndicator(),
      )
          : Stack(
        children: [
          GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: CameraPosition(
              target: LatLng(
                  currentLocation.latitude, currentLocation.longitude),
              zoom: 15,
            ),
            onMapCreated: _onMapCreated,
            markers: _markers,
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _locationNameController,
                    decoration:
                    InputDecoration(labelText: 'Location Name'),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      _addNewLocation();
                    },
                    child: Text('Add Location'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _hasUserAddedLocation() async {
    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid;

    final addedLocationDoc = await FirebaseFirestore.instance
        .collection('AddedLocations')
        .doc(userId)
        .get();

    return addedLocationDoc.exists;
  }

  void _addNewLocation() async {
    try {
      bool hasAddedLocation = await _hasUserAddedLocation();
      if (hasAddedLocation) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('You have already added a location.')),
        );
        return;
      }

      double latitude = currentLocation.latitude;
      double longitude = currentLocation.longitude;
      String locationName = _locationNameController.text;

      // Save the new location to Firestore with the custom name as the document ID
      final user = FirebaseAuth.instance.currentUser;
      final userId = user?.uid;
      final userEmail = user?.email; // Get the user's email address

      await FirebaseFirestore.instance
          .collection('suggested_locations')
          .doc(locationName)
          .set({
        'latitude': latitude,
        'longitude': longitude,
        'timestamp': FieldValue.serverTimestamp(),
        'userEmail': userEmail, // Add the user's email address
      });

      // Mark that the user has added a location
      await FirebaseFirestore.instance
          .collection('AddedLocations')
          .doc(userId)
          .set({
        'timestamp': FieldValue.serverTimestamp(),
        'userEmail': userEmail, // Add the user's email address
      });

      // Show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('New location added successfully!')),
      );
    } catch (e) {
      // Show an error message if there's an issue
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding location: $e')),
      );
    }
  }
}
