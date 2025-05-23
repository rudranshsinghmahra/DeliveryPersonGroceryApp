import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart' as loc;
import 'package:geocoding/geocoding.dart' as geocoding;
import '../screens/home_screen.dart';

class AuthProvider extends ChangeNotifier {
  File? image;
  bool isPictureAvailable = false;
  double shopLatitude = 0.0;
  double shopLongitude = 0.0;
  String? shopAddress;
  String? placeName;
  String email = "";
  String mobileNumber = "";
  CollectionReference deliveryBoy =
      FirebaseFirestore.instance.collection('deliveryBoys');

  Future<File?> getImage() async {
    final ImagePicker picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      image = File(pickedImage.path);
      isPictureAvailable = true;
      notifyListeners();
    } else {
      print("No Image Selected");
    }
    return image;
  }

  Future getCurrentAddress() async {
    loc.Location location = loc.Location();

    bool serviceEnabled;
    loc.PermissionStatus permissionGranted;
    loc.LocationData locationData;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == loc.PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != loc.PermissionStatus.granted) {
        return;
      }
    }

    locationData = await location.getLocation();
    double shopLatitude = locationData.latitude!;
    double shopLongitude = locationData.longitude!;
    notifyListeners();

    List<geocoding.Placemark> placeMarks =
        await geocoding.placemarkFromCoordinates(shopLatitude, shopLongitude);
    geocoding.Placemark place = placeMarks.first;

    shopAddress =
        '${place.name}, ${place.subLocality}, ${place.locality}, ${place.administrativeArea} ${place.country} - ${place.postalCode}';
    placeName = place.name ?? '';
    notifyListeners();

    return place;
  }

  // Email Registration
  Future<UserCredential?> registerDeliveryBoy(
      String email, String password, String mobile) async {
    this.email = email;
    mobileNumber = mobile;
    notifyListeners();
    UserCredential? userCredential;
    try {
      userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
        notifyListeners();
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
        notifyListeners();
      }
    } catch (e) {
      print(e.toString());
      notifyListeners();
    }
    return userCredential;
  }

  //Reset Password
  Future<void> authDataResetPassword(String email) async {
    this.email = email;
    notifyListeners();
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: email)
          .whenComplete(() {});
    } catch (e) {
      print(e.toString());
      notifyListeners();
    }
  }

  getEmailAddress(email) {
    this.email = email;
    notifyListeners();
  }

  //Login Vendor
  Future<UserCredential?> loginDeliveryBoy(
      String email, String password) async {
    this.email = email;
    notifyListeners();
    UserCredential? userCredential;
    try {
      userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
        notifyListeners();
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
        notifyListeners();
      }
    } catch (e) {
      print(e.toString());
      notifyListeners();
    }
    return userCredential;
  }

  // Save Vendor Data to Firestore
  Future<void> saveDeliveryBoyDataToDatabase(
      {required String url,
      required String name,
      required String mobile,
      required String password,
      context}) async {
    User? user = FirebaseAuth.instance.currentUser;
    CollectionReference deliveryBoys =
        FirebaseFirestore.instance.collection('deliveryBoys');
    deliveryBoys.doc(email).update({
      'uid': user?.uid,
      'name': name,
      'password': password,
      'mobile': mobileNumber,
      'address': '$placeName:$shopAddress',
      'location': GeoPoint(shopLatitude, shopLongitude),
      'imageUrl': url,
      'accVerified': false // only verified vendors can sell their products
    }).whenComplete(() {
      Navigator.pushReplacementNamed(context, HomeScreen.id);
    });
    return;
  }
}
