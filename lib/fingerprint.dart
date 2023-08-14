import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:newlogin/home.dart';
import 'check.dart';

class LocationPage extends StatefulWidget {
  @override
  _LocationPageState createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  late GoogleMapController mapController;
  Position? currentLocation;
  String? currentAddress;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  Future<void> _initLocation() async {
    await getCurrentLocation();
  }

  Future<void> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }
    }

    currentLocation = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    _getAddressFromCoordinates();
  }

  Future<void> _getAddressFromCoordinates() async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        currentLocation!.latitude,
        currentLocation!.longitude,
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

  Future<void> checkAuthorizationAndNavigate() async {
    QuerySnapshot authorizedLocationsSnapshot =
    await _firestore.collection('Authorized_Locations').get();

    final List<QueryDocumentSnapshot> authorizedLocations =
        authorizedLocationsSnapshot.docs;

    bool isAuthorized = false;

    for (QueryDocumentSnapshot location in authorizedLocations) {
      double authorizedLatitude = location['latitude'];
      double authorizedLongitude = location['longitude'];

      double distanceInMeters = Geolocator.distanceBetween(
        currentLocation!.latitude,
        currentLocation!.longitude,
        authorizedLatitude,
        authorizedLongitude,
      );

      if (distanceInMeters < 1000) {
        isAuthorized = true;
        break;
      }
    }

    if (isAuthorized) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => EmployeeDetails()),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Unauthorized'),
          content: Text('You are not in an authorized area.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Live Location Tracker'),
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
                  currentLocation!.latitude,
                  currentLocation!.longitude,
                ),
                zoom: 15,
              ),
              onMapCreated: (GoogleMapController controller) {
                mapController = controller;
              },
              markers: {
                Marker(
                  markerId: MarkerId('currentLocation'),
                  position: LatLng(
                    currentLocation!.latitude,
                    currentLocation!.longitude,
                  ),
                ),
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.location_pin),
        onPressed: () async {
          await getCurrentLocation();
          await checkAuthorizationAndNavigate();
        },
      ),
    );
  }
}
