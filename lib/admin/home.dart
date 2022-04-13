import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:parking_go/admin/Qr_Scanner.dart';
import 'package:parking_go/admin/Services/parking_service.dart';
import 'package:parking_go/admin/booking_history.dart';
import 'package:parking_go/admin/drawer.dart';
import 'package:parking_go/admin/parking_management.dart';
import 'package:parking_go/admin/rates.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({Key? key}) : super(key: key);

  @override
  _AdminHomeState createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  late double w, h;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  checkExpired() {
    ParkingService parkingService = new ParkingService();
    parkingService.checkExpired();
  }

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIOverlays([]);
    checkExpired();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    w = MediaQuery.of(context).size.width;
    h = MediaQuery.of(context).size.height;
    return Scaffold(
      key: _scaffoldKey,
      drawer: NavDrawer(),
      body: Column(
        children: [
          Container(
            color: Colors.green,
            height: h * .08,
            child: Row(
              children: [
                SizedBox(
                  width: w * .05,
                ),
                GestureDetector(
                  onTap: () => _scaffoldKey.currentState?.openDrawer(),
                  child: Icon(
                    Icons.format_list_bulleted,
                    color: Colors.white,
                  ),
                ),
                Spacer(),
                Text(
                  "Dashboard",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 24),
                ),
                Spacer(),
                SizedBox(
                  width: w * .05,
                )
              ],
            ),
          ),
          SizedBox(
            height: h * .18,
          ),
          Container(
            margin: EdgeInsets.only(left: 10, right: 10),
            child: Row(
              children: [
                optionItem("Parking Area", "assets/parking.png", () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ParkingSlotManagementScreen()));
                }),
                optionItem("Parking Rates", "assets/dollar.png", () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ParkingRatesManagement()));
                }),
              ],
            ),
          ),
          SizedBox(
            height: h * .05,
          ),
          Container(
            margin: EdgeInsets.only(left: 10, right: 10),
            child: Row(
              children: [
                optionItem("History", "assets/history.png", () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => BookingHistoryScreen()));
                }),
                optionItem("Scanner", "assets/qr_scanner.png", () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => ScanQr()));
                }),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget optionItem(String name, String img, Function onPressed) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          onPressed();
        },
        child: Card(
          shape: BeveledRectangleBorder(
            borderRadius: BorderRadius.circular(2.0),
          ),
          child: Container(
            margin: EdgeInsets.all(15),
            child: Column(
              children: [
                Image.asset(
                  img,
                  width: w * .3,
                  height: w * .3,
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  name,
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Color(0xff999999)),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
