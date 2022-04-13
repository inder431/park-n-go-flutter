import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';
import 'package:parking_go/common/models/ReservationModel.dart';
import 'package:parking_go/common/models/parking_model.dart';
import 'package:parking_go/User/confirm_reservation.dart';
import 'package:toast/toast.dart';

import 'drawer.dart';

class TimeSelectionScreen extends StatefulWidget {
  ParkingModel pkm;
  String slotId;
  TimeSelectionScreen({required this.pkm, required this.slotId});
  @override
  _TimeSelectionScreenState createState() => _TimeSelectionScreenState();
}

class _TimeSelectionScreenState extends State<TimeSelectionScreen> {
  late double w, h;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  DateTime nowTime = DateTime.now();
  DateTime newTime = DateTime.now();
  double amountBeforeTax = 0;
  double totalAmount = 0;
  double gst = 0;
  double qst = 0;
  String hours = '0';
  String mins = '0';
  late ReservationModel rsm;
  void initValues() {
    setState(() {
      nowTime = DateTime.now();
      newTime = nowTime.add(Duration(minutes: 30));
    });
    calculateBill();
  }

  calculateBill() {
    int minDiff = newTime.difference(nowTime).inMinutes;
    if (newTime.difference(nowTime).inMinutes < 30) {
      Toast.show("Minimum parking time is 30 minutes", context,
          duration: Toast.LENGTH_LONG,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          gravity: Toast.CENTER);
      initValues();
      return;
    }
    if (minDiff < 60) {
      amountBeforeTax = 5;
    } else if (minDiff >= 60 && minDiff < 180) {
      amountBeforeTax = newTime.difference(nowTime).inHours * 4;
    } else if (minDiff >= 180 && minDiff < 360) {
      amountBeforeTax = newTime.difference(nowTime).inHours * 3.5;
    } else if (minDiff >= 360 && minDiff < 720) {
      amountBeforeTax = newTime.difference(nowTime).inHours * 3.25;
    } else if (minDiff >= 720 && minDiff <= 1440) {
      amountBeforeTax = 30;
    } else if (minDiff > 1440) {
      amountBeforeTax = newTime.difference(nowTime).inDays * 30;
    }
    setPrice();
  }

  setPrice() {
    setState(() {
      gst = (amountBeforeTax * 0.05);
      qst = (amountBeforeTax * 0.0997);
      totalAmount = amountBeforeTax + gst + qst;
    });
    hours = newTime.difference(nowTime).inHours.toString();
    mins = newTime.difference(nowTime).inMinutes.toString();
    rsm = new ReservationModel(
        resId: (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString(),
        hour: hours,
        min: mins,
        amountBeforeTax: amountBeforeTax.toString(),
        gst: gst.toString(),
        qst: qst.toString(),
        totalAmount: totalAmount.toString(),
        slotId: widget.slotId);
  }

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIOverlays([]);
    initValues();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    w = MediaQuery.of(context).size.width;
    h = MediaQuery.of(context).size.height;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      key: _scaffoldKey,
      drawer: Container(width: w, child: NavDrawer()),
      body: SingleChildScrollView(
        child: Column(
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
                    "Reserve A Slot",
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
              height: h * .1,
            ),
            Container(
              padding: EdgeInsets.all(15),
              alignment: Alignment.topLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Time",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 48,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: h * .04,
                  ),
                  fromDate(nowTime),
                  SizedBox(
                    height: h * .04,
                  ),
                  toDate(newTime),
                  SizedBox(
                    height: h * .04,
                  ),
                  Text(
                    "Amount Before Taxes : \$ ${amountBeforeTax.round().toString()}",
                    style: TextStyle(fontSize: 16),
                  ),
                  Text(
                    "GST(5%): \$ ${gst.toStringAsPrecision(2)}",
                    style: TextStyle(fontSize: 16),
                  ),
                  Text(
                    "QST(9.97%): \$ ${qst.toStringAsPrecision(2)}",
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(
                    height: h * .03,
                  ),
                  Text(
                    "Total Amount : \$ ${totalAmount.round().toString()}",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  SizedBox(
                    height: h * .04,
                  ),
                  Center(
                    child: SizedBox(
                      width: w * .8,
                      height: 60,
                      child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        ConfirmReservationScreen(
                                          pkm: widget.pkm,
                                          reservation: rsm,
                                        ))).then((value) {
                              initValues();
                            });
                          },
                          child: Text(
                            'Reserve Slot',
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
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget fromDate(DateTime dateTime) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "From",
          style: TextStyle(fontSize: 20),
        ),
        SizedBox(
          height: 15,
        ),
        Row(
          children: [
            boxText(new DateFormat('yyyy-MM-dd hh:mm a').format(dateTime)),
            SizedBox(
              width: 10,
            ),
            GestureDetector(
                onTap: () {
                  DateTime now = DateTime.now();
                  DatePicker.showDateTimePicker(context,
                      showTitleActions: true,
                      minTime: DateTime(
                          now.year,
                          now.month,
                          now.day,
                          now.hour,
                          now.minute,
                          now.second,
                          now.millisecond,
                          now.microsecond),
                      maxTime: DateTime(now.year + 1, now.month, now.day),
                      onChanged: (date) {
                    print('change $date');
                  }, onConfirm: (date) {
                    setState(() {
                      nowTime = date;
                    });
                    calculateBill();
                  }, currentTime: DateTime.now(), locale: LocaleType.en);
                },
                child: Container(
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                      shape: BoxShape.rectangle, color: Color(0xffDDDDDD)),
                  child: Center(
                    child: Icon(
                      Icons.date_range,
                      color: Colors.green,
                    ),
                  ),
                ))
          ],
        )
      ],
    );
  }

  Widget toDate(DateTime dateTime) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "To",
          style: TextStyle(fontSize: 20),
        ),
        SizedBox(
          height: 15,
        ),
        Row(
          children: [
            boxText(new DateFormat('yyyy-MM-dd hh:mm a').format(dateTime)),
            SizedBox(
              width: 10,
            ),
            GestureDetector(
                onTap: () {
                  DateTime now = DateTime.now();
                  DatePicker.showDateTimePicker(context,
                      showTitleActions: true,
                      minTime: DateTime(
                          now.year,
                          now.month,
                          now.day,
                          now.hour,
                          now.minute,
                          now.second,
                          now.millisecond,
                          now.microsecond),
                      maxTime: DateTime(now.year + 1, now.month, now.day),
                      onChanged: (date) {
                    print('change $date');
                  }, onConfirm: (date) {
                    setState(() {
                      newTime = date;
                    });
                    calculateBill();
                  }, currentTime: DateTime.now(), locale: LocaleType.en);
                },
                child: Container(
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                      shape: BoxShape.rectangle, color: Color(0xffDDDDDD)),
                  child: Center(
                    child: Icon(
                      Icons.date_range,
                      color: Colors.green,
                    ),
                  ),
                ))
          ],
        )
      ],
    );
  }

  Widget boxText(String text) {
    return Container(
      padding: EdgeInsets.all(15),
      decoration:
          BoxDecoration(shape: BoxShape.rectangle, color: Color(0xffDDDDDD)),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.w500, color: Colors.black87),
        ),
      ),
    );
  }
}
