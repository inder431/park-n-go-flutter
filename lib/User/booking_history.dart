import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:parking_go/common/models/ReservationModel.dart';
import 'package:parking_go/User/Services/booking_history.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:toast/toast.dart';

class BookingHistoryScreen extends StatefulWidget {
  const BookingHistoryScreen({Key? key}) : super(key: key);

  @override
  _BookingHistoryScreenState createState() => _BookingHistoryScreenState();
}

//TimeSelectionScreen
class _BookingHistoryScreenState extends State<BookingHistoryScreen> {
  late double w, h;
  List<ReservationModel> bookings = [];
  bool loading = true;

  loadHistory() async {
    BookingHistoryService bs = new BookingHistoryService();
    bookings = await bs.getBookingHistory();
    setState(() {
      loading = false;
    });
  }

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIOverlays([]);
    loadHistory();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    w = MediaQuery.of(context).size.width;
    h = MediaQuery.of(context).size.height;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Container(
          width: w,
          height: h,
          child: Column(
            children: [
              Container(
                  color: Colors.green,
                  height: h * .08,
                  child: Row(
                    children: [
                      SizedBox(
                        width: 10,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                        ),
                      ),
                      Spacer(),
                      Text(
                        "Booking History",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 24),
                      ),
                      Spacer(),
                      SizedBox(
                        width: 10,
                      )
                    ],
                  )),
              SizedBox(
                height: h * .03,
              ),
              !loading
                  ? historyList()
                  : Expanded(
                      child: Center(
                      child: Container(
                        width: 30,
                        height: 30,
                        child: CircularProgressIndicator(),
                      ),
                    ))
            ],
          ),
        ),
      ),
    );
  }

  Widget historyList() {
    return bookings.length > 0
        ? ListView.builder(
            shrinkWrap: true,
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              return itemView(bookings[index]);
            })
        : Center(
            child: Text("No reservations yet!"),
          );
  }

  Widget itemView(ReservationModel rsm) {
    var bytes1 = utf8.encode(rsm.resId!);
    List<int> d = md5.convert(bytes1).bytes;
    String data = d.toString();
    return InkWell(
      onTap: () {
        if (rsm.status == 0) {
          Toast.show("Cancelled reservation!", context,
              textColor: Colors.white, backgroundColor: Colors.green);
          return;
        }
        if (rsm.status == 2) {
          Toast.show("Expired reservation!", context,
              textColor: Colors.white, backgroundColor: Colors.green);
          return;
        }
        showQr(data);
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          QrImage(
            data: data,
            version: QrVersions.auto,
            size: w * .3,
          ),
          Expanded(
            child: Container(
              margin: EdgeInsets.only(top: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(rsm.status == 0
                      ? "Cancelled On : ${new DateFormat('yyyy-MM-dd hh:mm').format(rsm.dateTime!)}"
                      : "Confirmed On : ${new DateFormat('yyyy-MM-dd hh:mm').format(rsm.dateTime!)}"),
                  SizedBox(
                    height: h * .01,
                  ),
                  Text(
                      "Duration : ${rsm.hour.toString().padLeft(2, '0')} hours and ${rsm.min.toString().padLeft(2, '0')} mins"),
                  SizedBox(
                    height: h * .01,
                  ),
                  Text("Amount : ${rsm.totalAmount}"),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        rsm.status == 0
                            ? "cancelled"
                            : rsm.status == 1
                                ? "confirmed"
                                : "expired",
                        style: TextStyle(
                            color: rsm.status == 0 || rsm.status == 2
                                ? Colors.red
                                : Colors.green),
                      ),
                      SizedBox(
                        width: 20,
                      )
                    ],
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  showQr(String data) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Reservation QR"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Get your QR Scanned!"),
              SizedBox(
                height: 15,
              ),
              QrImage(
                data: data,
                version: QrVersions.auto,
                size: w * .6,
              )
            ],
          ),
          actions: [
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ],
        );
      },
    );
  }
}
