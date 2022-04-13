import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:parking_go/User/Services/rates.dart';
import 'package:parking_go/admin/Models/rate_model.dart';

import 'Services/rating_service.dart';

class ParkingRatesManagement extends StatefulWidget {
  const ParkingRatesManagement({Key? key}) : super(key: key);

  @override
  _ParkingRatesManagementState createState() => _ParkingRatesManagementState();
}

class _ParkingRatesManagementState extends State<ParkingRatesManagement> {
  late double w, h;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool loading = true;
  RatingModel? rtm;
  late RatingService ratesService = new RatingService();

  loadRates() async {
    SystemChrome.setEnabledSystemUIOverlays([]);
    setState(() {
      loading = true;
    });
    RatingModel? ratingModel = await ratesService.getParkingRates();
    setState(() {
      this.rtm = ratingModel;
      loading = false;
    });
  }

  @override
  void initState() {
    loadRates();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    w = MediaQuery.of(context).size.width;
    h = MediaQuery.of(context).size.height;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      key: _scaffoldKey,
      body: SingleChildScrollView(
        child: Column(
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
            Container(
              width: w * .4,
              height: 45,
              margin: EdgeInsets.only(left: 10),
              child: ElevatedButton(
                  onPressed: () async {
                    if (await ratesService.addRate(context, rtm!, false))
                      loadRates();
                    SystemChrome.setEnabledSystemUIOverlays([]);
                  },
                  child: Text(
                    'Add New',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        letterSpacing: .9),
                  ),
                  style: ElevatedButton.styleFrom(
                    primary: Color(0Xff41B546),
                  )),
            ),
            !loading
                ? Container(
                    margin: EdgeInsets.all(15),
                    child: rtm != null && rtm!.rates!.length > 0
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
                                for (Rates rate in rtm!.rates!)
                                  TableRow(children: [
                                    InkWell(
                                      onLongPress: () async {
                                        if (await ratesService.rateOptions(
                                            context, rtm!, rate.rateId!))
                                          loadRates();
                                        SystemChrome.setEnabledSystemUIOverlays(
                                            []);
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          rate.time.toString(),
                                          style: TextStyle(fontSize: 20),
                                        ),
                                      ),
                                    ),
                                    InkWell(
                                      onLongPress: () async {
                                        if (await ratesService.rateOptions(
                                            context, rtm!, rate.rateId!))
                                          loadRates();
                                        SystemChrome.setEnabledSystemUIOverlays(
                                            []);
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          rate.price.toString(),
                                          style: TextStyle(fontSize: 20),
                                        ),
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
      ),
    );
  }
}
