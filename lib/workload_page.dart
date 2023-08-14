import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:multiple_images_picker/multiple_images_picker.dart';


import 'home.dart';

class WorkloadPage extends StatefulWidget {
  @override
  _WorkloadPageState createState() => _WorkloadPageState();
}

class _WorkloadPageState extends State<WorkloadPage> {
  final TextEditingController _workloadController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  List<Asset> _pickedImages = [];

  String _userId = '';

  @override
  void initState() {
    super.initState();
    _fetchUserId();
  }

  void _fetchUserId() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _userId = user.uid;
      });
    }
  }

  void _uploadWorkload() async {
    String workload = _workloadController.text.trim();
    String username = _usernameController.text.trim();

    if (workload.isNotEmpty && username.isNotEmpty) {
      try {
        // Upload images to Firebase Storage and get their download URLs
        List<String> imageUrls = await _uploadImagesToStorage();

        // Save workload details to Firestore
        await FirebaseFirestore.instance.collection('workloads_details').add({
          'userId': _userId,
          'username': username,
          'workload': workload,
          'imageUrls': imageUrls,
          'timestamp': FieldValue.serverTimestamp(),
        });

        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Success'),
              content: Text('Workload uploaded successfully!'),
              actions: [
                TextButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.pop(context);
                    _workloadController.clear();
                    _usernameController.clear();
                    setState(() {
                      _pickedImages.clear();
                    });
                  },
                ),
              ],
            );
          },
        );
      } catch (e) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Error'),
              content: Text('An error occurred. Please try again later.'),
              actions: [
                TextButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          },
        );
        print(e.toString());
      }
    }
  }

  Future<List<String>> _uploadImagesToStorage() async {
    List<String> imageUrls = [];

    for (var asset in _pickedImages) {
      try {
        // Upload image to Firebase Storage
        String fileName = DateTime.now().millisecondsSinceEpoch.toString();
        ByteData byteData = await asset.getByteData();
        List<int> imageData = byteData.buffer.asUint8List();
        Uint8List uint8ImageData = Uint8List.fromList(imageData);
        Reference storageReference =
        FirebaseStorage.instance.ref().child('images/$fileName');
        UploadTask uploadTask = storageReference.putData(uint8ImageData);
        TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
        String imageUrl = await taskSnapshot.ref.getDownloadURL();
        imageUrls.add(imageUrl);
      } catch (e) {
        print('Error uploading image: $e');
      }
    }

    return imageUrls;
  }


  Future<void> _getImages() async {
    List<Asset> pickedImages = await MultipleImagesPicker.pickImages(
      maxImages: 300,
      enableCamera: true,
      selectedAssets: _pickedImages,
    );

    if (pickedImages.isNotEmpty) {
      setState(() {
        _pickedImages = pickedImages;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload Workload'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
            );
          },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'User Name or ID'),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _workloadController,
              decoration: InputDecoration(labelText: 'Working Details'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              child: Text('Upload'),
              onPressed: _uploadWorkload,
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              child: Text('Add Images'),
              onPressed: _getImages,
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _pickedImages.length,
                itemBuilder: (context, index) {
                  return AssetThumb(
                    asset: _pickedImages[index],
                    width: 100,
                    height: 100,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}