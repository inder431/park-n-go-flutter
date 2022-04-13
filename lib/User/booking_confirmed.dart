import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'drawer.dart';

class BookingConfirmScreen extends StatefulWidget {
  String resId;
  BookingConfirmScreen({required this.resId});
  @override
  _SBookingConfirmScreenState createState() => _SBookingConfirmScreenState();
}

class _SBookingConfirmScreenState extends State<BookingConfirmScreen> {
  String data = '';
  late double w, h;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  void encodeData() {
    var bytes1 = utf8.encode(widget.resId);
    List<int> d = md5.convert(bytes1).bytes;
    setState(() {
      data = d.toString();
    });
  }

  void startCountDown() {
    Future.delayed(Duration(seconds: 4), () {
      Navigator.pop(context);
      Navigator.pop(context);
      Navigator.pop(context);
      Navigator.pop(context);
    });
  }

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIOverlays([]);
    encodeData();
    super.initState();
    startCountDown();
  }

  @override
  Widget build(BuildContext context) {
    w = MediaQuery.of(context).size.width;
    h = MediaQuery.of(context).size.height;
    return Scaffold(
      key: _scaffoldKey,
      drawer: Container(width: w, child: NavDrawer()),
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
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
                  SizedBox(
                    width: w * .05,
                  )
                ],
              ),
            ),
            SizedBox(
              height: h * .02,
            ),
            Center(
                child: Image.asset(
              'assets/tick.png',
              width: w * .3,
              height: w * .3,
            )),
            SizedBox(
              height: h * .02,
            ),
            Center(
                child: Text(
              "Booking Confirmed",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            )),
            SizedBox(
              height: h * .02,
            ),
            Center(
              child: QrImage(
                data: data,
                version: QrVersions.auto,
                size: w * .8,
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Center(
                child: Container(
              width: w * .4,
              child: Text(
                "Scan Qr Code at Entrance",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            )),
            Spacer(),
            Center(
                child: Text(
              "Thank You Visit Again!",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            )),
            SizedBox(
              height: h * .1,
            ),
          ],
        ),
      ),
    );
  }
}
