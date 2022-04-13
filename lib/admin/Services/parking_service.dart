import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:parking_go/User/Services/booking_history.dart';
import 'package:parking_go/common/models/parking_model.dart';
import 'package:parking_go/common/models/ReservationModel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

class ParkingService {
  // update,create
  Future<bool> createOrUpdate(ParkingModel pkm) async {
    try {
      FirebaseFirestore.instance
          .collection('Parking')
          .doc('parking')
          .set(pkm.toJson(), SetOptions(merge: true));
      return true;
    } catch (e) {
      print("Error updating parking $e");
      return false;
    }
  }

  Future<ParkingModel?> loadParking() async {
    try {
      ParkingModel pkm = new ParkingModel();
      pkm.parkingFloors = [];
      DocumentSnapshot ds = await FirebaseFirestore.instance
          .collection('Parking')
          .doc('parking')
          .get();
      if (ds.exists)
        return ParkingModel.fromJson(ds.data() as Map<String, dynamic>);
      else
        return pkm;
    } catch (e) {
      print("Error getting parking $e");
      return null;
    }
  }

  Future<void> checkExpired() async {
    try {
      ParkingModel? pkm = await loadParking();
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      String uid = sharedPreferences.getString("userEmail")!;
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('Reservation')
          .where('uid', isEqualTo: uid)
          .get();
      if (snapshot.docs.length > 0) {
        for (DocumentSnapshot ds in snapshot.docs) {
          Map<String, dynamic> data = ds.data() as Map<String, dynamic>;
          ReservationModel rsm = ReservationModel.fromJson(data);
          rsm.dateTime =
              rsm.dateTime?.add(Duration(hours: int.parse(rsm.hour!)));
          rsm.dateTime =
              rsm.dateTime?.add(Duration(minutes: int.parse(rsm.min!)));
          //print('parking time ; ${rsm.dateTime} and now : ${DateTime.now()}');
          if (rsm.dateTime!.isBefore(DateTime.now())) {
            // expired
            if (rsm.status == 1) {
              // was booked not cancelled.
              data['status'] = 2;
              pkm = changeSlotToAvilable(pkm!, rsm.slotId!);
              await ds.reference.update(data);
              await createOrUpdate(pkm);
            }
          }
        }
      }
    } catch (e) {
      print("Error checking expiry $e");
    }
  }

  ParkingModel changeSlotToAvilable(ParkingModel pkm, String slotId) {
    for (int i = 0; i < pkm.parkingFloors!.length!; i++) {
      for (int j = 0; j < pkm.parkingFloors![i].parkingSlots!.length; j++) {
        if (pkm.parkingFloors![i].parkingSlots![j].slotId == slotId) {
          pkm.parkingFloors![i].parkingSlots![j].status = 0;
        }
      }
    }
    return pkm;
  }

  addFloorDialogue(BuildContext context, ParkingModel pkm) async {
    bool added = false;

    await showDialog(
      context: context,
      builder: (context) {
        bool updating = false;
        TextEditingController textEditingController =
            new TextEditingController();

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("Adding New Floor"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  textFeild("Type Floor Name...", textEditingController)
                ],
              ),
              actions: <Widget>[
                if (!updating)
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("Canel"),
                  ),
                if (!updating)
                  TextButton(
                    onPressed: () async {
                      // start progress
                      setState(() {
                        updating = true;
                      });
                      // add
                      pkm.parkingFloors?.add(new ParkingFloors(
                          floorName: textEditingController.text,
                          status: 0,
                          floorId:
                              (DateTime.now().millisecondsSinceEpoch ~/ 1000)
                                  .toString(),
                          parkingSlots: []));
                      bool updated = await createOrUpdate(pkm);
                      added = updated;
                      if (updated)
                        Toast.show("Created!", context);
                      else
                        Toast.show("Fail to create Floor!", context);
                      // stop progress
                      setState(() {
                        updating = false;
                      });
                      Navigator.pop(context);
                    },
                    child: Text("Add"),
                  ),
                if (updating)
                  Container(
                    width: 25,
                    height: 25,
                    margin: EdgeInsets.all(15),
                    child: CircularProgressIndicator(),
                  )
              ],
            );
          },
        );
      },
    );
    return added;
  }

  addSlot(BuildContext context, ParkingModel pkm, int floorIndex) async {
    bool added = false;

    await showDialog(
      context: context,
      builder: (context) {
        bool updating = false;
        TextEditingController textEditingController =
            new TextEditingController();

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("Adding New Slot"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  textFeild("Type Slot Name...", textEditingController)
                ],
              ),
              actions: <Widget>[
                if (!updating)
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("Canel"),
                  ),
                if (!updating)
                  TextButton(
                    onPressed: () async {
                      // start progress
                      setState(() {
                        updating = true;
                      });
                      // add
                      pkm.parkingFloors![floorIndex].parkingSlots!.add(
                          new ParkingSlots(
                              slotName: textEditingController.text,
                              slotId: (DateTime.now().millisecondsSinceEpoch ~/
                                      1000)
                                  .toString(),
                              status: 0));
                      bool updated = await createOrUpdate(pkm);
                      added = updated;
                      if (updated)
                        Toast.show("Created!", context);
                      else
                        Toast.show("Fail to create Slot!", context);
                      // stop progress
                      setState(() {
                        updating = false;
                      });
                      Navigator.pop(context);
                    },
                    child: Text("Add"),
                  ),
                if (updating)
                  Container(
                    width: 25,
                    height: 25,
                    margin: EdgeInsets.all(15),
                    child: CircularProgressIndicator(),
                  )
              ],
            );
          },
        );
      },
    );
    return added;
  }

  slotOptions(BuildContext context, ParkingModel pkm, int floorIndex,
      int slotIndex, int status) async {
    bool update = false;
    await showDialog(
      context: context,
      builder: (context) {
        bool updating = false;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("Modify Slot"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!updating)
                    GestureDetector(
                      onTap: () async {
                        setState(() {
                          updating = true;
                        });
                        for (int i = 0;
                            i <
                                pkm.parkingFloors![floorIndex].parkingSlots!
                                    .length;
                            i++) {
                          if (pkm.parkingFloors![floorIndex].parkingSlots![i]
                                  .slotId ==
                              pkm.parkingFloors![floorIndex]
                                  .parkingSlots![slotIndex].slotId) {
                            pkm.parkingFloors![floorIndex].parkingSlots!
                                .removeAt(i);
                          }
                        }
                        bool updated = await createOrUpdate(pkm);
                        update = updated;
                        if (updated)
                          Toast.show("Removed!", context);
                        else
                          Toast.show("Fail to remove!", context);
                        await Future.delayed(Duration(seconds: 1));
                        setState(() {
                          updating = false;
                        });
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: Colors.green),
                        child: Center(
                          child: Text(
                            "Remove",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  SizedBox(
                    height: 15,
                  ),
                  if (!updating)
                    GestureDetector(
                      onTap: () async {
                        setState(() {
                          updating = true;
                        });
                        if (status == 2) return;
                        if (status != 9) {
                          // not blocked
                          for (int i = 0;
                              i <
                                  pkm.parkingFloors![floorIndex].parkingSlots!
                                      .length;
                              i++) {
                            if (pkm.parkingFloors![floorIndex].parkingSlots![i]
                                    .slotId ==
                                pkm.parkingFloors![floorIndex]
                                    .parkingSlots![slotIndex].slotId) {
                              pkm.parkingFloors![floorIndex].parkingSlots![i]
                                  .status = 9;
                            }
                          }
                        } else {
                          for (int i = 0;
                              i <
                                  pkm.parkingFloors![floorIndex].parkingSlots!
                                      .length;
                              i++) {
                            if (pkm.parkingFloors![floorIndex].parkingSlots![i]
                                    .slotId ==
                                pkm.parkingFloors![floorIndex]
                                    .parkingSlots![slotIndex].slotId) {
                              pkm.parkingFloors![floorIndex].parkingSlots![i]
                                  .status = 0;
                            }
                          }
                        }
                        bool updated = await createOrUpdate(pkm);
                        update = updated;
                        if (updated)
                          Toast.show(
                              status == 9 ? "Unbloked" : "Blocked!", context);
                        else
                          Toast.show(
                              status == 9
                                  ? "Fail to un-block!"
                                  : "Fail to block!",
                              context);
                        await Future.delayed(Duration(seconds: 1));
                        setState(() {
                          updating = false;
                        });
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: Colors.green),
                        child: Center(
                          child: Text(
                            status == 9 ? "Un-block" : "Block",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  if (updating)
                    Center(
                      child: Container(
                        width: 30,
                        height: 30,
                        child: CircularProgressIndicator(),
                      ),
                    )
                ],
              ),
              actions: <Widget>[
                if (!updating)
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("Dismiss"),
                  ),
              ],
            );
          },
        );
      },
    );
    return update;
  }

  floorOptions(BuildContext context, ParkingModel pkm, int floorIndex,
      int status) async {
    bool update = false;
    await showDialog(
      context: context,
      builder: (context) {
        bool updating = false;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("Modify Floor"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!updating)
                    GestureDetector(
                      onTap: () async {
                        setState(() {
                          updating = true;
                        });
                        pkm.parkingFloors!.removeAt(floorIndex);
                        bool updated = await createOrUpdate(pkm);
                        update = updated;
                        if (updated)
                          Toast.show("Removed!", context);
                        else
                          Toast.show("Fail to remove!", context);
                        await Future.delayed(Duration(seconds: 1));
                        setState(() {
                          updating = false;
                        });
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: Colors.green),
                        child: Center(
                          child: Text(
                            "Remove",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  SizedBox(
                    height: 15,
                  ),
                  if (!updating)
                    GestureDetector(
                      onTap: () async {
                        setState(() {
                          updating = true;
                        });
                        for (int i = 0;
                            i <
                                pkm.parkingFloors![floorIndex].parkingSlots!
                                    .length;
                            i++) {
                          if (pkm.parkingFloors![floorIndex].parkingSlots![i]
                                  .status !=
                              2) {
                            if (status == 1) {
                              // blocked
                              pkm.parkingFloors![floorIndex].parkingSlots![i]
                                  .status = 0;
                            } else {
                              pkm.parkingFloors![floorIndex].parkingSlots![i]
                                  .status = 9;
                            }
                          }
                        }
                        if (pkm.parkingFloors![floorIndex].status == 1) {
                          pkm.parkingFloors![floorIndex].status = 0;
                        } else {
                          pkm.parkingFloors![floorIndex].status = 1;
                        }
                        bool updated = await createOrUpdate(pkm);
                        update = updated;
                        if (updated)
                          Toast.show(
                              status == 1 ? "Unbloked" : "Blocked!", context);
                        else
                          Toast.show(
                              status == 1
                                  ? "Fail to un-block!"
                                  : "Fail to block!",
                              context);
                        await Future.delayed(Duration(seconds: 1));
                        setState(() {
                          updating = false;
                        });
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: Colors.green),
                        child: Center(
                          child: Text(
                            status == 1 ? "Un-block" : "Block",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  if (updating)
                    Center(
                      child: Container(
                        width: 30,
                        height: 30,
                        child: CircularProgressIndicator(),
                      ),
                    )
                ],
              ),
              actions: <Widget>[
                if (!updating)
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("Dismiss"),
                  ),
              ],
            );
          },
        );
      },
    );
    return update;
  }

  Widget textFeild(String hint, TextEditingController controller) {
    return Container(
      height: 39,
      color: Color(0xffE0DFDF),
      width: 200,
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
            border: InputBorder.none,
            filled: true,
            hintStyle: TextStyle(color: Colors.black45),
            hintText: hint,
            fillColor: Color(0xffE0DFDF)),
      ),
    );
  }
}
