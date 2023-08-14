import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthorizedLocationsPage extends StatefulWidget {
  @override
  _AuthorizedLocationsPageState createState() => _AuthorizedLocationsPageState();
}

class _AuthorizedLocationsPageState extends State<AuthorizedLocationsPage> {
  late CollectionReference _authorizedLocationsCollection;

  @override
  void initState() {
    super.initState();
    _authorizedLocationsCollection = FirebaseFirestore.instance.collection('Authorized_Locations');
  }

  Future<void> _deleteLocation(String locationId) async {
    // Show confirmation dialog before deleting
    bool confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Delete"),
          content: Text("Are you sure you want to delete this location?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false), // No
              child: Text("No"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true), // Yes
              child: Text("Yes"),
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      // Delete the location from Firestore
      await _authorizedLocationsCollection.doc(locationId).delete();
      setState(() {});
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

              return ListTile(
                title: Text(locationId),
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => _deleteLocation(locationId),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
