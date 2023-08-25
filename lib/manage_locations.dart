import 'package:flutter/material.dart';
import 'package:newlogin/suggested_locations.dart';
import 'package:newlogin/utils/color_utils.dart';

import 'authorized_locations.dart';
import 'location_added_user.dart';
import 'main.dart';

class ManageLocationsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigoAccent,
        title: Text("Manage Locations"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AdminDashboardScreen()),
            );
          },
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              hexStringToColor("4169E1"),
              hexStringToColor("BDFCC9"),
              hexStringToColor("FF7F00"),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              Image.asset("assets/images/LOGO.jpg"),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) {
                        return SuggestedLocationsScreen();
                      },
                    ),
                  );
                },
                child: Text("Suggested Locations"),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) {
                        return AuthorizedLocationsPage();
                      },
                    ),
                  );
                },
                child: Text("Authorized Locations"),
              ),

              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) {
                        return LocationAddedUserPage();
                      },
                    ),
                  );
                },
                child: Text("Location Added Users"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
