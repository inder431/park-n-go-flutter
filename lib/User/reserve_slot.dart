import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:parking_go/User/select_time.dart';
import 'package:toast/toast.dart';

import 'package:parking_go/common/models/parking_model.dart';
import '../User/Services/parking_servicew.dart';

class ReserveSlotScreen extends StatefulWidget {
  const ReserveSlotScreen({Key? key}) : super(key: key);

  @override
  _ReserveSlotScreenState createState() => _ReserveSlotScreenState();
}

//TimeSelectionScreen
class _ReserveSlotScreenState extends State<ReserveSlotScreen> {
  late double w, h;
  late ParkingModel pkm;
  ParkingService ps = new ParkingService();
  bool loading = true;
  int currentFloor = 0;

  getParking() async {
    setState(() {
      loading = true;
    });
    ParkingModel? pk = await ps.loadParking();
    setState(() {
      pkm = pk!;
      loading = false;
    });
  }

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIOverlays([]);
    getParking();
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
                        "Radisson Hotel",
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
                height: h * .05,
              ),
              !loading
                  ? Column(
                      children: [
                        Center(
                          child: Text(
                            "Select Parking Slot",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20),
                          ),
                        ),
                        SizedBox(
                          height: h * .05,
                        ),
                        addFloor(),
                        SizedBox(
                          height: h * .03,
                        ),
                        renderSlots(currentFloor),
                        SizedBox(
                          height: h * .03,
                        ),
                        Center(
                          child: SizedBox(
                            height: 45,
                            child: ElevatedButton(
                                onPressed: () {
                                  String? slotId = checkIfSomeSelected();
                                  if (slotId != null) {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                TimeSelectionScreen(
                                                  pkm: pkm,
                                                  slotId: slotId,
                                                )));
                                  } else {
                                    Toast.show("No slot is selected!", context,
                                        textColor: Colors.white,
                                        backgroundColor: Colors.green);
                                  }
                                },
                                child: Text(
                                  'Reserve Slot',
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
                        )
                      ],
                    )
                  : Container(
                      width: 30,
                      height: 30,
                      child: CircularProgressIndicator(),
                    )
            ],
          ),
        ),
      ),
    );
  }

  Widget addFloor() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          showFloors(),
        ],
      ),
    );
  }

  Widget showFloors() {
    return Container(
      padding: EdgeInsets.only(left: 10, right: 10),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15), color: Colors.green),
      child: Row(mainAxisSize: MainAxisSize.min, children: getFloorChilds()),
    );
  }

  List<Widget> getFloorChilds() {
    List<Widget> floorChilds = [];
    for (int i = 0; i < pkm.parkingFloors!.length; i++) {
      floorChilds.add(GestureDetector(
        onTap: () {
          setState(() {
            currentFloor = i;
          });
        },
        child: Padding(
            padding: EdgeInsets.all(10),
            child: Text(
              pkm.parkingFloors![i].floorName!,
              style: TextStyle(
                  color: currentFloor == i ? Colors.yellow : Colors.white,
                  fontWeight: FontWeight.bold),
            )),
      ));
      if (pkm.parkingFloors!.length > 1 && i != pkm.parkingFloors!.length - 1) {
        floorChilds.add(Container(
          width: 1,
          height: 20,
          color: Colors.white,
        ));
      }
    }
    return floorChilds;
  }

  Widget renderSlots(int floor) {
    return Container(
        padding: EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            pkm.parkingFloors![floor].parkingSlots!.length > 0
                ? GridView.builder(
                    shrinkWrap: true,
                    itemCount: pkm.parkingFloors![floor].parkingSlots!.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 2,
                        crossAxisSpacing: 4.0,
                        mainAxisSpacing: 4.0),
                    itemBuilder: (BuildContext context, int index) {
                      ParkingSlots slot =
                          pkm.parkingFloors![floor].parkingSlots![index];
                      return InkWell(
                        onTap: () async {
                          slotSelection(index);
                        },
                        child: Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              shape: BoxShape.rectangle,
                              color: slot.status == 1
                                  ? Colors.blue.withOpacity(.3)
                                  : Colors.white,
                              border:
                                  Border.all(color: Colors.black, width: 1)),
                          child: slot.status == 0 ||
                                  slot.status == 1 // available for booking
                              ? Center(
                                  child: Text(
                                    slot.slotName.toString(),
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 22,
                                        letterSpacing: 5),
                                  ),
                                )
                              : slot.status == 2 // booked
                                  ? Image.asset(
                                      'assets/car.png',
                                      width: 100,
                                      height: 50,
                                    )
                                  : Center(
                                      // blocked
                                      child: Text("Not Available!"),
                                    ),
                        ),
                      );
                    },
                  )
                : Center(
                    child: Container(
                      margin: EdgeInsets.only(top: h * .2),
                      child: Text("Floor is empty."),
                    ),
                  )
          ],
        ));
  }

  // 9 -- blocked, 0--unselected, 1--> selected, 2--> booked
  slotSelection(int index) {
    int status = pkm.parkingFloors![currentFloor].parkingSlots![index].status!;
    if (status == 9) {
      // block slot
      Toast.show("Sorry can't select. This slot is blocked!", context,
          textColor: Colors.white, backgroundColor: Colors.green);
      return;
    }
    if (status == 2) {
      // booked slot
      Toast.show("Sorry can't select. Already booked!", context,
          textColor: Colors.white, backgroundColor: Colors.green);
      return;
    }
    // unselect all other
    for (int i = 0; i < pkm.parkingFloors!.length; i++) {
      for (int j = 0; j < pkm.parkingFloors![i].parkingSlots!.length; j++) {
        int status = pkm.parkingFloors![i].parkingSlots![j].status!;
        if (status == 1) {
          pkm.parkingFloors![i].parkingSlots![j].status = 0;
        }
      }
    }
    // select
    setState(() {
      pkm.parkingFloors![currentFloor].parkingSlots![index].status = 1;
    });
  }

  String? checkIfSomeSelected() {
    String? slotId = null;
    for (int i = 0; i < pkm.parkingFloors!.length; i++) {
      for (int j = 0; j < pkm.parkingFloors![i].parkingSlots!.length; j++) {
        int status = pkm.parkingFloors![i].parkingSlots![j].status!;
        if (status == 1) {
          // selected
          slotId = pkm.parkingFloors![i].parkingSlots![j].slotId;
          break;
        }
      }
    }
    return slotId;
  }
}
