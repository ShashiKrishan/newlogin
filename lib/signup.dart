import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'admin_viewUser.dart';
import 'main.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  TextEditingController _emailTEC = TextEditingController();
  TextEditingController _passwordTEC = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigoAccent,
        title: Text("Sign Up"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddNewUsersScreen()),
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
                  'Create an account',
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
                    hintText: "Enter Your Email Address Here",
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
                  onPressed: () async {
                    var _email = _emailTEC.text;
                    var _password = _passwordTEC.text;

                    try {
                      UserCredential userCredential =
                      await _auth.createUserWithEmailAndPassword(
                        email: _email,
                        password: _password,
                      );

                      if (userCredential.user != null) {
                        await _firestore
                            .collection('users')
                            .doc(userCredential.user!.uid)
                            .set({
                          'email': _email,
                          // Add more fields as needed
                        });

                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (BuildContext context) {
                              return AdminDashboardScreen();
                            },
                          ),
                              (route) => false,
                        );
                      }
                    } catch (error) {
                      print('Error: $error');
                    }
                  },
                  child: Text("Sign Up"),
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

  Color hexStringToColor(String hexColor) {
    final buffer = StringBuffer();
    if (hexColor.length == 6 || hexColor.length == 7) buffer.write('ff');
    buffer.write(hexColor.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}
