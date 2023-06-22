import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:newlogin/main.dart';

import 'package:newlogin/utils/color_utils.dart';




class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  TextEditingController _emailTEC = TextEditingController();
  TextEditingController _passwordTEC = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigoAccent,
        title: Text("Sign Up"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context, MaterialPageRoute(builder: (context) => LoginScreen())),
        ),
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
                  onPressed: () {
                    var _email = _emailTEC.text;
                    var _password = _passwordTEC.text;

                    _auth
                        .createUserWithEmailAndPassword(
                        email: _email, password: _password)
                        .then((UserCredential userCredential) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) {
                            return LoginScreen();
                          },
                        ),
                            (route) => false,
                      );
                    }).catchError((error) {
                      print('Error: $error');
                    });
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
}
