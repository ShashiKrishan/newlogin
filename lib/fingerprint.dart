import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LocationPage extends StatefulWidget {
  @override
  _LocationPageState createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  late GoogleMapController mapController;
  late Position currentLocation;
  String? currentAddress;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

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
    getAddressFromCoordinates();
  }

  Future<void> getAddressFromCoordinates() async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        currentLocation.latitude,
        currentLocation.longitude,
      );
      if (placemarks.isNotEmpty) {
        Placemark placemark = placemarks[0];
        setState(() {
          currentAddress =
          '${placemark.name}, ${placemark.locality}, ${placemark.administrativeArea}';
        });
      }
    } catch (e) {
      print('Error retrieving location address: $e');
    }
  }

  void storeLocationDetails() async {
    try {
      String? userId = _auth.currentUser?.uid;

      await _firestore.collection('location_details').add({
        'userId': userId,
        'address': currentAddress,
        'latitude': currentLocation.latitude,
        'longitude': currentLocation.longitude,
        'timestamp': Timestamp.now(),
      });

      print('Location details stored in Firestore');
    } catch (e) {
      print('Error storing location details: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Live Location Tracker'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            child: Text(
              currentAddress ?? 'Loading...',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: GoogleMap(
              mapType: MapType.normal,
              initialCameraPosition: CameraPosition(
                target: LatLng(
                    currentLocation.latitude, currentLocation.longitude),
                zoom: 15,
              ),
              onMapCreated: (GoogleMapController controller) {
                mapController = controller;
              },
              markers: {
                Marker(
                  markerId: MarkerId('currentLocation'),
                  position:
                  LatLng(currentLocation.latitude, currentLocation.longitude),
                ),
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.location_pin),
        onPressed: () {
          getCurrentLocation();
          storeLocationDetails();
        },
      ),
    );
  }
}
