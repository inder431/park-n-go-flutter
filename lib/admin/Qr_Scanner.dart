import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_beep/flutter_beep.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:parking_go/common/models/ReservationModel.dart';
import 'package:parking_go/User/Services/booking_history.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'dart:io';

import 'package:toast/toast.dart';

class ScanQr extends StatefulWidget {
  @override
  _ScanQrState createState() => _ScanQrState();
}

class _ScanQrState extends State<ScanQr> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  late Barcode result;
  late QRViewController controller;
  String _qrInfo = 'Scan a QR/Bar code';
  bool _camState = false;
  bool processing = false;
  int count = 0;

  _qrCallback(String code) async {
    setState(() {
      _camState = false;
      _qrInfo = code;
    });
    await processingPopup(context);
  }

  _scanCode() {
    setState(() {
      _camState = true;
    });
  }

  @override
  void initState() {
    super.initState();
    _scanCode();
  }

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller.pauseCamera();
    } else if (Platform.isIOS) {
      controller.resumeCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: _camState
                ? QRView(
                    key: qrKey,
                    onQRViewCreated: _onQRViewCreated,
                  )
                : Container(),
          ),
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) async {
      count++;
      setState(() {
        _camState = false;
      });
      await _qrCallback(scanData.code);
    });
  }

  void pop() {
    for (int i = 0; i < count; i++) {
      Navigator.of(context, rootNavigator: true).pop();
    }
    count = 0;
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  progressBar() {
    AlertDialog alert = AlertDialog(
      content: SizedBox(
        width: 100,
        height: 40,
        child: SpinKitDualRing(
          color: Colors.pinkAccent,
          size: 30,
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

  processingPopup(BuildContext context) async {
    progressBar();
    String? msg = null;
    await Future.delayed(Duration(seconds: 1), () async {
      List<String> hashedBookings = await getHashedReservations();
      print("Qr scanned = $_qrInfo");
      print("Qr hash list = ${hashedBookings.toString()}");
      if (hashedBookings.contains(_qrInfo)) {
        msg = 'Matched!';
      }
      Navigator.of(context, rootNavigator: true).pop();
    });
    if (msg != null) {
      await FlutterBeep.beep();
      showMsg(msg!, msg != null);
      await Future.delayed(Duration(seconds: 2));
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else {
      await FlutterBeep.beep(false);
      await showMsg(msg == null ? "Not Matched!" : '', msg != null);
      setState(() {
        _camState = true;
      });
      Toast.show("Invalid Qr code!", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.TOP);
    }
  }

  showMsg(String msg, bool match) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              match
                  ? Icon(
                      Icons.check_circle_rounded,
                      color: Colors.green,
                      size: 60,
                    )
                  : Icon(
                      Icons.cancel,
                      color: Colors.red,
                      size: 60,
                    ),
              SizedBox(
                height: 15,
              ),
              Text(
                msg,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    color: match ? Colors.green : Colors.red),
              )
            ],
          ),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).pop();
                },
                child: Text("Ok"))
          ],
        );
      },
    );
  }

  Future<List<String>> getHashedReservations() async {
    List<String> hashedBookings = [];
    try {
      BookingHistoryService bs = new BookingHistoryService();
      List<ReservationModel> bookings = await bs.getBookingHistory();
      for (ReservationModel rsm in bookings) {
        var bytes1 = utf8.encode(rsm.resId!);
        List<int> d = md5.convert(bytes1).bytes;
        hashedBookings.add(d.toString());
      }
      return hashedBookings;
    } catch (e) {
      print("error getting hashed reservations $e");
      return hashedBookings;
    }
  }
}
