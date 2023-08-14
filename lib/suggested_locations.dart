import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SuggestedLocationsScreen extends StatefulWidget {
  @override
  _SuggestedLocationsScreenState createState() => _SuggestedLocationsScreenState();
}

class _SuggestedLocationsScreenState extends State<SuggestedLocationsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _authorizeLocation(String locationName) async {
    // Get the suggested location document data
    DocumentSnapshot locationSnapshot = await _firestore.collection('suggested_locations').doc(locationName).get();
    if (locationSnapshot.exists) {
      Map<String, dynamic> locationData = locationSnapshot.data() as Map<String, dynamic>;

      // Add the location to the "Authorized_Locations" collection
      await _firestore.collection('Authorized_Locations').doc(locationName).set(locationData);

      // Delete the location from the "suggested_locations" collection
      await _firestore.collection('suggested_locations').doc(locationName).delete();
    }
  }

  Future<void> _deleteLocation(String locationName) async {
    // Delete the location from the "suggested_locations" collection
    await _firestore.collection('suggested_locations').doc(locationName).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Suggested Locations'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('suggested_locations').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final locations = snapshot.data!.docs;

          return ListView.builder(
            itemCount: locations.length,
            itemBuilder: (context, index) {
              final locationName = locations[index].id;
              return ListTile(
                title: Text(locationName),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton(
                      onPressed: () => _authorizeLocation(locationName),
                      child: Text('Authorize'),
                    ),
                    TextButton(
                      onPressed: () => _deleteLocation(locationName),
                      child: Text('Delete'),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}