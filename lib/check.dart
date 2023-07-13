import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:newlogin/home.dart';

class EmployeeDetails extends StatefulWidget {
  @override
  _EmployeeDetailsState createState() => _EmployeeDetailsState();
}

class _EmployeeDetailsState extends State<EmployeeDetails> {
  String _employeeName = '';
  String _checkInTime = '-';
  String _checkOutTime = '-';
  Position? _checkInLocation;
  Position? _checkOutLocation;

  final _employeeNameController = TextEditingController();

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

  void _checkIn() async {
    Position? position = await _getCurrentLocation();
    if (position == null) {
      // handle location permission denied
      return;
    }
    setState(() {
      _checkInTime = DateTime.now().toString();
      _checkInLocation = position;
    });
  }

  void _checkOut() async {
    Position? position = await _getCurrentLocation();
    if (position == null) {
      // handle location permission denied
      return;
    }
    setState(() {
      _checkOutTime = DateTime.now().toString();
      _checkOutLocation = position;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Employee CheckIn CheckOut Details'),
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
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _employeeNameController,
              decoration: InputDecoration(
                hintText: 'Enter Employee Name',
              ),
              onSubmitted: (value) {
                setState(() {
                  _employeeName = value;
                });
              },
            ),
          ),
          ListTile(
            title: Text('Employee Name'),
            subtitle: Text(_employeeName),
          ),
          ListTile(
            title: Text('Check In Time'),
            subtitle: Text(_checkInTime),
          ),
          ListTile(
            title: Text('Check In Location'),
            subtitle: Text(_checkInLocation == null
                ? 'Not available'
                : 'Lat: ${_checkInLocation!.latitude}, Lng: ${_checkInLocation!.longitude}'),
          ),
          ListTile(
            title: Text('Check Out Time'),
            subtitle: Text(_checkOutTime),
          ),
          ListTile(
            title: Text('Check Out Location'),
            subtitle: Text(_checkOutLocation == null
                ? 'Not available'
                : 'Lat: ${_checkOutLocation!.latitude}, Lng: ${_checkOutLocation!.longitude}'),
          ),
          Spacer(),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20),
            child: ElevatedButton(
              onPressed: _checkInTime == '-' ? _checkIn : null,
              child: Text('Check In'),
            ),
          ),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20),
            child: ElevatedButton(
              onPressed: _checkInTime != '-' ? _checkOut : null,
              child: Text('Check Out'),
            ),
          ),
        ],
      ),
    );
  }
}
