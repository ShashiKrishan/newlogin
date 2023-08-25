import 'package:flutter/material.dart';
import 'package:newlogin/home.dart';
import 'package:newlogin/user_login.dart';
import 'package:newlogin/admin_viewUser.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import 'manage_locations.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Attendance App',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      home: UserLoginScreen(),
    );
  }
}

class AdminDashboardScreen extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance; // Initialize FirebaseAuth

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigoAccent,
        title: Text("Admin Dashboard"),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () async {
              await _auth.signOut(); // Sign out the user
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => UserLoginScreen(),
                ),
                    (route) => false,
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.blueAccent,
              Colors.orangeAccent,
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
              Container(
                width: 200, // Set the width of the buttons container
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) {
                          return HomeScreen();
                        },
                      ),
                    );
                  },
                  child: Text("Home Screen"),
                ),
              ),
              SizedBox(height: 20),
              Container(
                width: 200, // Set the width of the buttons container
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) {
                          return AddNewUsersScreen();
                        },
                      ),
                    );
                  },
                  child: Text("Manage Users"),
                ),
              ),
              SizedBox(height: 20),
              Container(
                width: 200, // Set the width of the buttons container
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) {
                          return ManageLocationsScreen();
                        },
                      ),
                    );
                  },
                  child: Text("Manage Locations"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
