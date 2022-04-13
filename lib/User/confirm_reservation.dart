import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:parking_go/common/models/ReservationModel.dart';
import 'package:parking_go/common/models/parking_model.dart';
import 'package:parking_go/User/Services/parking_servicew.dart';
import 'package:toast/toast.dart';

import 'booking_confirmed.dart';

class ConfirmReservationScreen extends StatefulWidget {
  ParkingModel pkm;
  ReservationModel reservation;
  ConfirmReservationScreen({required this.pkm, required this.reservation});

  @override
  _ConfirmReservationScreenState createState() =>
      _ConfirmReservationScreenState();
}

class _ConfirmReservationScreenState extends State<ConfirmReservationScreen> {
  late double w, h;
  ParkingService ps = new ParkingService();

  void initState() {
    SystemChrome.setEnabledSystemUIOverlays([]);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    w = MediaQuery.of(context).size.width;
    h = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: Container(
        width: w,
        height: h,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                  margin: EdgeInsets.only(left: 14, top: 36),
                  alignment: Alignment.topLeft,
                  child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Icon(Icons.arrow_back))),
              SizedBox(
                height: h * .03,
              ),
              Container(
                margin: EdgeInsets.only(left: w * .04, right: w * .04),
                child: Center(
                  child: Text(
                    "Please Confirm Reservation",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                  ),
                ),
              ),
              SizedBox(
                height: h * .15,
              ),
              Center(
                child: TweenAnimationBuilder<Duration>(
                    duration: Duration(minutes: 5),
                    tween:
                        Tween(begin: Duration(minutes: 5), end: Duration.zero),
                    onEnd: () {
                      Toast.show("Time expired!", context,
                          backgroundColor: Colors.green,
                          textColor: Colors.white,
                          duration: Toast.LENGTH_LONG);
                      Navigator.pop(context);
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    builder:
                        (BuildContext context, Duration value, Widget? child) {
                      final minutes = value.inMinutes;
                      final seconds = value.inSeconds % 60;
                      return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Spacer(),
                              SizedBox(
                                width: 30,
                              ),
                              Text(
                                minutes.toString().padLeft(2, '0'),
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 35),
                              ),
                              SizedBox(
                                width: 3,
                              ),
                              Text(
                                ":",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 22),
                              ),
                              SizedBox(
                                width: 3,
                              ),
                              Text(
                                seconds.toString().padLeft(2, '0'),
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 35),
                              ),
                              SizedBox(
                                width: 3,
                              ),
                              Text(
                                'minutes',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 24),
                              ),
                              Spacer()
                            ],
                          ));
                    }),
              ),
              SizedBox(
                height: h * .1,
              ),
              showCharges(),
              SizedBox(
                height: h * .05,
              ),
              Center(
                child: SizedBox(
                  width: w * .8,
                  height: 60,
                  child: ElevatedButton(
                      onPressed: () async {
                        showResDialog(context, "Making Reservation");

                        widget.reservation.status = 1; // confirmed
                        await ps.makeReservation(
                            context, widget.pkm, widget.reservation);
                        Navigator.pop(context);
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => BookingConfirmScreen(
                                      resId: widget.reservation.resId!,
                                    )));
                      },
                      child: Text(
                        'Confirm',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                            letterSpacing: .9),
                      ),
                      style: ElevatedButton.styleFrom(
                        primary: Color(0xff41B546),
                      )),
                ),
              ),
              SizedBox(
                height: h * .03,
              ),
              Center(
                child: SizedBox(
                  width: w * .8,
                  height: 60,
                  child: ElevatedButton(
                      onPressed: () async {
                        widget.reservation.status = 0; // cancelled
                        showResDialog(context, "Cancelling Reservation");
                        await ps.cancelledReservation(
                            context, widget.reservation);
                        Navigator.pop(context);
                        Navigator.pop(context);
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                            letterSpacing: .9),
                      ),
                      style: ElevatedButton.styleFrom(
                        primary: Color(0xffD7DBD7),
                      )),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget showCharges() {
    return Container(
      margin: const EdgeInsets.all(15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Amount Before Taxes : \$ ${widget.reservation.amountBeforeTax}",
            style: TextStyle(fontSize: 16),
          ),
          Text(
            "GST(5%): \$ ${widget.reservation.gst}",
            style: TextStyle(fontSize: 16),
          ),
          Text(
            "QST(9.97%): \$ ${widget.reservation.qst}",
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(
            height: h * .03,
          ),
          Text(
            "Total Amount : \$ ${widget.reservation.totalAmount}",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ],
      ),
    );
  }

  showResDialog(BuildContext context, String msg) {
    AlertDialog alert = AlertDialog(
      title: Text(msg),
      content: Padding(
        padding: const EdgeInsets.fromLTRB(12.0, 0.0, 12.0, 12.0),
        child: Row(
          children: [
            CircularProgressIndicator(
                valueColor:
                    new AlwaysStoppedAnimation<Color>(Color(0xff01702E))),
            SizedBox(
              width: 10,
            ),
            Text("Please wait...")
          ],
        ),
      ),
    );
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
