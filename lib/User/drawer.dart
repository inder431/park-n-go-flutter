import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:parking_go/admin/sigin.dart';
import 'package:parking_go/User/booking_history.dart';
import 'package:parking_go/User/customer_feedback.dart';
import 'package:parking_go/main.dart';
import 'package:parking_go/User/profile.dart';
import 'package:parking_go/User/reserve_slot.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NavDrawer extends StatelessWidget {
  late double w, h;
  @override
  Widget build(BuildContext context) {
    h = MediaQuery.of(context).size.height;
    w = MediaQuery.of(context).size.width;
    return Drawer(
      child: Container(
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SizedBox(
              height: 15,
            ),
            item("Book Slot", () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => ReserveSlotScreen()));
            }, context),
            item("Booking History", () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => BookingHistoryScreen()));
            }, context),
            item("Profile", () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => ProfileScreen()));
            }, context),
            item("Logout", () async {
              if (FirebaseAuth.instance.currentUser != null) {
                await FirebaseAuth.instance.signOut();
              }
              if (await GoogleSignIn().isSignedIn()) {
                await GoogleSignIn().signOut();
              }
              SharedPreferences sharedPreferences =
                  await SharedPreferences.getInstance();
              if (sharedPreferences.containsKey("userEmail")) {
                sharedPreferences.remove("userEmail");
              }
              Navigator.of(context).popUntil((route) => route.isFirst);
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => MyHomePage()));
            }, context),
          ],
        ),
      ),
    );
  }

  Widget item(String title, Function onPressed, BuildContext context) {
    return GestureDetector(
      onTap: () async {
        Navigator.of(context).pop();
        await onPressed();
        SystemChrome.setEnabledSystemUIOverlays([]);
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(5)),
          color: Colors.green,
        ),
        padding: EdgeInsets.only(left: 15, top: 15, bottom: 15),
        margin: EdgeInsets.only(left: 5, right: 5, top: 10),
        child: Text(
          title,
          style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
              letterSpacing: .8),
        ),
      ),
    );
  }
}
