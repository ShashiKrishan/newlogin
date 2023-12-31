import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:newlogin/main.dart';
import 'package:newlogin/user_login.dart';
import 'package:newlogin/workload_page.dart';
import 'add_new_locations.dart';
import 'fingerprint.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home Screen"),
        actions: [
          IconButton(
            icon: Icon(Icons.logout_rounded),
            onPressed: () {
              FirebaseAuth.instance.signOut().then((value) {
                print("Signed Out");
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => UserLoginScreen()));
              });
            },
          ),
        ],
      ),
      body: Body(),
    );
  }
}

class Body extends StatefulWidget {
  @override
  State<Body> createState() => _Body();
}

class _Body extends State<Body> {
  List<String> imageList = [    "assets/images/img1.jpg",    "assets/images/img2.JPG",    "assets/images/img3.jpg",    "assets/images/img4.JPG",    "assets/images/img5.JPG"  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.orange,
            Colors.blueAccent,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 10,
          ),
          const Text(
            'Colombo Logistics Groups',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          SizedBox(
            height: 20,
          ),
          CarouselSlider(
              items: imageList
                  .map((e) => ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      e,
                      height: 200,
                      width: 100,
                      fit: BoxFit.cover,
                    ),
                  ],
                ),
              ))
                  .toList(),
              options: CarouselOptions(
                  autoPlay: true,
                  enableInfiniteScroll: false,
                  enlargeCenterPage: true,
                  height: 150)),
          SizedBox(
            height: 10,
          ),


          Padding(

              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: ElevatedButton.icon(

                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) {
                        return LocationPage();
                      },
                    ),

                  );


                  print("Location Details will appear soon");
                },
                icon: Icon(Icons.location_on_outlined),
                label: Text("Location Tracker", textAlign: TextAlign.center,),
                style: ElevatedButton.styleFrom(
                    primary: Colors.indigoAccent),

              )
          ),



          Padding(

              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: ElevatedButton.icon(

                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) {
                        return AddNewLocationsPage();
                      },
                    ),

                  );



                  print("Add New Location Details will appear soon");
                },
                icon: Icon(Icons.add_location),
                label: Text("Add New Location ", textAlign: TextAlign.center,),
                style: ElevatedButton.styleFrom(
                    primary: Colors.indigoAccent),

              )
          ),



          Padding(

              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: ElevatedButton.icon(

                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) {
                        return WorkloadPage();
                      },
                    ),

                  );


                  print("Working Details adding page will appear soon");
                },
                icon: Icon(Icons.work_history_rounded),
                label: Text("Working Details", textAlign: TextAlign.center,),
                style: ElevatedButton.styleFrom(
                    primary: Colors.indigoAccent),

              )
          ),



        ],

      ),
    );
  }



}




