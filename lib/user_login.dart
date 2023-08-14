import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:newlogin/home.dart';
import 'package:newlogin/utils/color_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'main.dart';

class UserLoginScreen extends StatefulWidget {
  @override
  _UserLoginScreenState createState() => _UserLoginScreenState();
}

class _UserLoginScreenState extends State<UserLoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  TextEditingController _emailTEC = TextEditingController();
  TextEditingController _passwordTEC = TextEditingController();

  Future<void> _login() async {
    var _email = _emailTEC.text;
    var _password = _passwordTEC.text;

    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: _email,
        password: _password,
      );

      String userUID = userCredential.user?.uid ?? '';
      // Replace 'userRoles' with your actual Firestore collection name
      DocumentSnapshot userRoleSnapshot = await FirebaseFirestore.instance
          .collection('userRoles')
          .doc(userUID)
          .get();

      if (userRoleSnapshot.exists) {
        String role = userRoleSnapshot.get('role');
        if (role == 'admin') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) {
                return AdminDashboardScreen(); // Navigate to LoginScreen for admin
              },
            ),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) {
                return HomeScreen(); // Navigate to HomeScreen for user
              },
            ),
          );
        }
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigoAccent,
        title: Text("User Login"),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              hexStringToColor("4169E1"),
              hexStringToColor("BDFCC9"),
              hexStringToColor("FF7F00")
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset("assets/images/LOGO.jpg"),
                SizedBox(
                  height: 20,
                ),
                const Text(
                  'Welcome to the CLW App',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 20,
                ),
                TextField(
                  controller: _emailTEC,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(),
                    hintText: "Enter Your User Id Here",
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                TextField(
                  controller: _passwordTEC,
                  obscureText: true,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.lock),
                    border: OutlineInputBorder(),
                    hintText: "Enter Your Password Here",
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  onPressed: _login,
                  child: Text("Login"),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    _emailTEC.clear();
                    _passwordTEC.clear();
                  },
                  child: Text("Clear"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
