import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthorizedLocationsPage extends StatefulWidget {
  @override
  _AuthorizedLocationsPageState createState() => _AuthorizedLocationsPageState();
}

class _AuthorizedLocationsPageState extends State<AuthorizedLocationsPage> {
  late CollectionReference _authorizedLocationsCollection;
  late CollectionReference _addedLocationsCollection;

  @override
  void initState() {
    super.initState();
    _authorizedLocationsCollection = FirebaseFirestore.instance.collection('Authorized_Locations');
    _addedLocationsCollection = FirebaseFirestore.instance.collection('AddedLocations');
  }

  Future<void> _deleteLocation(String locationId, String userEmail) async {
    try {
      // Delete the location from Authorized_Locations
      await _authorizedLocationsCollection.doc(locationId).delete();

      // Query the AddedLocations collection for documents with the same userEmail
      final addedLocationsQuery = await _addedLocationsCollection
          .where('userEmail', isEqualTo: userEmail)
          .get();

      // Delete each matching document from AddedLocations
      for (final doc in addedLocationsQuery.docs) {
        await doc.reference.delete();
      }

      setState(() {
        // Refresh the UI
      });
    } catch (e) {
      print('Error deleting location: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Authorized Locations"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _authorizedLocationsCollection.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }

          if (snapshot.hasError) {
            return Text("Error: ${snapshot.error}");
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text("No authorized locations found."),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var location = snapshot.data!.docs[index];
              var locationId = location.id;
              var userEmail = location['userEmail'];

              return ListTile(
                title: Text(locationId),
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => _deleteLocation(locationId, userEmail),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
