import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:parking_go/common/models/parking_model.dart';
import 'package:toast/toast.dart';

import 'Services/parking_service.dart';

class ParkingSlotManagementScreen extends StatefulWidget {
  const ParkingSlotManagementScreen({Key? key}) : super(key: key);

  @override
  _ParkingSlotManagementScreenState createState() =>
      _ParkingSlotManagementScreenState();
}

class _ParkingSlotManagementScreenState
    extends State<ParkingSlotManagementScreen> {
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
                        "Parking Management",
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
                            "Parking Floors",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20),
                          ),
                        ),
                        SizedBox(
                          height: h * .08,
                        ),
                        addFloor(),
                        SizedBox(
                          height: h * .03,
                        ),
                        renderSlots(currentFloor),
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
    return pkm.parkingFloors!.length > 0
        ? Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                showFloors(),
                SizedBox(
                  width: 5,
                ),
                addFloorIcon()
              ],
            ),
          )
        : addFloorBtn();
  }

  Widget addFloorIcon() {
    return GestureDetector(
      onTap: () {
        addNewFloor();
      },
      child: Container(
        width: 35,
        height: 35,
        decoration: BoxDecoration(
            color: Colors.black12,
            borderRadius: BorderRadius.all(Radius.circular(10))),
        child: Center(child: Icon(Icons.add)),
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
        onLongPress: () async {
          if (await ps.floorOptions(
              context, pkm, i, pkm.parkingFloors![i].status!)) getParking();
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

  Widget addFloorBtn() {
    return GestureDetector(
      onTap: () {
        addNewFloor();
      },
      child: Container(
        width: w * .5,
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15), color: Colors.green),
        child: Center(
          child: Text(
            "Add Floor",
            style: TextStyle(
                color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  addNewFloor() async {
    bool added = await ps.addFloorDialogue(context, pkm);
    SystemChrome.setEnabledSystemUIOverlays([]);
    if (added) getParking();
  }

  Widget renderSlots(int floor) {
    return Container(
        padding: EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            addSlotBtn(),
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
                        onLongPress: () async {
                          if (slot.status == 2) {
                            Toast.show("Booked!", context,
                                textColor: Colors.white,
                                backgroundColor: Colors.green);
                            return;
                          }
                          if (await ps.slotOptions(
                              context, pkm, currentFloor, index, slot.status!))
                            getParking();
                        },
                        child: Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              shape: BoxShape.rectangle,
                              border:
                                  Border.all(color: Colors.black, width: 1)),
                          child: slot.status == 0 // available for booking
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
                                      child: Text("Blocked!"),
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

  Widget addSlotBtn() {
    return GestureDetector(
      onTap: () async {
        if (await ps.addSlot(context, pkm, currentFloor)) getParking();
        SystemChrome.setEnabledSystemUIOverlays([]);
      },
      child: Container(
        margin: EdgeInsets.only(left: w * .2, bottom: 15),
        width: w * .3,
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15), color: Colors.green),
        child: Center(
          child: Text(
            "Add Slot",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
