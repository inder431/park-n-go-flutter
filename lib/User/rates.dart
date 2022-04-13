import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:parking_go/User/Services/rates.dart';

import 'drawer.dart';

class ParkingRates extends StatefulWidget {
  const ParkingRates({Key? key}) : super(key: key);

  @override
  _ParkingRatesState createState() => _ParkingRatesState();
}

class _ParkingRatesState extends State<ParkingRates> {
  late double w, h;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  Map? rates = null;
  bool loading = true;

  loadRates() async {
    RatesService ratesService = new RatesService();
    Map? rates = await ratesService.getParkingRates();
    setState(() {
      this.rates = rates;
      loading = false;
    });
  }

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIOverlays([]);
    loadRates();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    w = MediaQuery.of(context).size.width;
    h = MediaQuery.of(context).size.height;
    return Scaffold(
      key: _scaffoldKey,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                  "Parking Rates",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 20),
                ),
                Spacer(),
                SizedBox(
                  width: w * .05,
                ),
              ],
            ),
          ),
          SizedBox(
            height: h * .1,
          ),
          !loading
              ? Container(
                  margin: EdgeInsets.all(15),
                  child: rates != null
                      ? Table(
                          border: TableBorder
                              .all(), // Allows to add a border decoration around your table
                          children: [
                              TableRow(children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    "Time",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    "Price",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20),
                                  ),
                                ),
                              ]),
                              for (var key in rates!.keys.toList())
                                TableRow(children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      key.toString(),
                                      style: TextStyle(fontSize: 20),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      rates![key],
                                      style: TextStyle(fontSize: 20),
                                    ),
                                  ),
                                ]),
                            ])
                      : Text("No rates to load."),
                )
              : Container(
                  width: 30,
                  height: 30,
                  child: CircularProgressIndicator(),
                ),
          Container(
            margin: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "- Rates doesnot include taxes.",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  "- Rates are shown as a guide only and are subject to change without any notice.",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
