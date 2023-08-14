import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:newlogin/home.dart';
import 'package:geocoding/geocoding.dart';

class EmployeeDetails extends StatefulWidget {
  @override
  _EmployeeDetailsState createState() => _EmployeeDetailsState();
}

class _EmployeeDetailsState extends State<EmployeeDetails> {
  String _employeeName = '';
  String _checkInTime = '-';
  String _checkInLocation = '-';
  String? _userId;

  final _employeeNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<Position?> _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return null;
    }
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  Future<void> _fetchUserId() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _userId = user.uid;
      });
    }
  }

  Future<String> _getAddressFromCoordinates(
      double latitude, double longitude) async {
    List<Placemark> placemarks = await placemarkFromCoordinates(
      latitude,
      longitude,
    );

    if (placemarks.isNotEmpty) {
      Placemark placemark = placemarks[0];
      return '${placemark.street}, ${placemark.locality}';
    } else {
      return 'Unknown Address';
    }
  }

  void _showCheckInSuccessfulDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Check In Successful'),
          content: Text('Thank You'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _checkIn() async {
    if (_formKey.currentState!.validate()) {
      Position? position = await _getCurrentLocation();
      if (position == null) {
        // Handle location permission denied
        return;
      }
      String checkInTime = DateTime.now().toString();

      String address = await _getAddressFromCoordinates(
        position.latitude,
        position.longitude,
      );

      setState(() {
        _checkInTime = checkInTime;
        _checkInLocation = address;
      });

      await FirebaseFirestore.instance.collection('checkInOut').add({
        'userId': _userId,
        'employeeName': _employeeName,
        'checkInTime': checkInTime,
        'checkInLocation': address,
      });

      _showCheckInSuccessfulDialog();
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchUserId();
  }

  @override
  void dispose() {
    _employeeNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Employee Check-In'),
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                TextFormField(
                  controller: _employeeNameController,
                  decoration: InputDecoration(
                    hintText: 'Enter Employee Name',
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'This field is required';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _employeeName = value!;
                  },
                  onFieldSubmitted: (value) {
                    setState(() {
                      _employeeName = value;
                    });
                  },
                ),
                SizedBox(height: 16.0),
                ListTile(
                  title: Text('Employee Name'),
                  subtitle: Text(_employeeName),
                ),
                ListTile(
                  title: Text('Check-In Time'),
                  subtitle: Text(_checkInTime),
                ),
                ListTile(
                  title: Text('Check-In Location'),
                  subtitle: Text(_checkInLocation),
                ),
                SizedBox(height: 16.0),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20),
                  child: ElevatedButton(
                    onPressed: _checkInTime == '-' ? _checkIn : null,
                    child: Text('Check-In'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
