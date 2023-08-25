import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'manage_locations.dart';

class LocationAddedUserPage extends StatefulWidget {
  @override
  _LocationAddedUserPageState createState() => _LocationAddedUserPageState();
}

class _LocationAddedUserPageState extends State<LocationAddedUserPage> {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Location Added Users'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ManageLocationsScreen()),
            );
          },
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('AddedLocations').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final addedUsers = snapshot.data!.docs;

          return ListView.builder(
            itemCount: addedUsers.length,
            itemBuilder: (context, index) {
              final userDoc = addedUsers[index];
              final userEmail = userDoc.get('userEmail');

              return ListTile(
                title: Text(userEmail),
                trailing: ElevatedButton(
                  onPressed: () {
                    // Delete the user's document from AddedLocations collection
                    _firestore.collection('AddedLocations').doc(userDoc.id).delete();

                    // Check and delete from Authorized_Locations if matching user found
                    _deleteFromAuthorizedLocations(userEmail);
                  },
                  child: Text('Delete'),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _deleteFromAuthorizedLocations(String userEmail) async {
    final authorizedLocationDocs = await _firestore
        .collection('Authorized_Locations')
        .where('userEmail', isEqualTo: userEmail)
        .get();

    for (final doc in authorizedLocationDocs.docs) {
      await doc.reference.delete();
    }
  }
}
