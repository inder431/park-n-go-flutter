import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:parking_go/admin/Qr_Scanner.dart';
import 'package:parking_go/admin/admin_main.dart' as admin;
import 'package:parking_go/admin/booking_history.dart';
import 'package:parking_go/admin/parking_management.dart';
import 'package:parking_go/admin/rates.dart';
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
            item("Parking Area", () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ParkingSlotManagementScreen()));
            }, context),
            item("Booking History", () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => BookingHistoryScreen()));
            }, context),
            item("Parking Rates", () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ParkingRatesManagement()));
            }, context),
            item("Scanner", () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => ScanQr()));
            }, context),
            item("Logout", () async {
              SharedPreferences sharedPreferences =
                  await SharedPreferences.getInstance();
              if (sharedPreferences.containsKey("login")) {
                sharedPreferences.remove("login");
              }
              Navigator.of(context).popUntil((route) => route.isFirst);
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => admin.MyApp()));
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
