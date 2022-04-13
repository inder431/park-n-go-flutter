import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:parking_go/admin/Models/rate_model.dart';
import 'package:flutter/material.dart';
import 'package:toast/toast.dart';

class RatingService {
  // update,create
  Future<bool> createOrUpdate(RatingModel rtm) async {
    try {
      FirebaseFirestore.instance
          .collection('ParkingRates')
          .doc('rates')
          .set(rtm.toJson(), SetOptions(merge: true));
      return true;
    } catch (e) {
      print("Error updating parking $e");
      return false;
    }
  }

  Future<RatingModel?> getParkingRates() async {
    try {
      RatingModel rtm = new RatingModel(rates: []);
      DocumentSnapshot ds = await FirebaseFirestore.instance
          .collection('ParkingRates')
          .doc('rates')
          .get();
      if (ds.exists)
        return RatingModel.fromJson(ds.data() as Map<String, dynamic>);
      else
        return rtm;
    } catch (e) {
      print("Error getting parking rates $e");
      return null;
    }
  }

  addRate(BuildContext context, RatingModel rtm, bool editMode,
      {String? timeVal, String? priceVal, int? index}) async {
    bool added = false;

    await showDialog(
      context: context,
      builder: (context) {
        bool updating = false;
        TextEditingController time =
            new TextEditingController(text: editMode ? timeVal : '');
        TextEditingController price =
            new TextEditingController(text: editMode ? priceVal : '');

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("Add New Rate"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  textFeild("Input time here...", time),
                  SizedBox(
                    height: 15,
                  ),
                  textFeild("Input price here...", price),
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
                      if (!editMode) {
                        rtm.rates!.add(new Rates(
                            price: price.text,
                            time: time.text,
                            rateId:
                                (DateTime.now().millisecondsSinceEpoch ~/ 1000)
                                    .toString()));
                      } else {
                        rtm.rates![index!].price = price.text;
                        rtm.rates![index!].time = time.text;
                      }
                      bool updated = await createOrUpdate(rtm);
                      added = updated;
                      if (updated)
                        Toast.show("Created!", context);
                      else
                        Toast.show("Failed to create rate!", context);
                      // stop progress
                      setState(() {
                        updating = false;
                      });
                      Navigator.pop(context);
                    },
                    child: Text(editMode ? "Submit" : "Add"),
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

  rateOptions(BuildContext context, RatingModel rtm, String ratingId) async {
    bool update = false;
    await showDialog(
      context: context,
      builder: (context) {
        bool updating = false;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("Modify Rate"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!updating)
                    GestureDetector(
                      onTap: () async {
                        setState(() {
                          updating = true;
                        });
                        for (int i = 0; i < rtm.rates!.length; i++) {
                          if (rtm.rates![i].rateId == ratingId) {
                            rtm.rates!.removeAt(i);
                          }
                        }
                        bool updated = await createOrUpdate(rtm);
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
                        Rates? rate;
                        int index = 0;
                        for (int i = 0; i < rtm.rates!.length; i++) {
                          if (rtm.rates![i].rateId == ratingId) {
                            rate = rtm.rates![i];
                            index = i;
                            break;
                          }
                        }
                        await addRate(context, rtm, true,
                            timeVal: rate!.time,
                            priceVal: rate!.price,
                            index: index);
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: Colors.green),
                        child: Center(
                          child: Text(
                            "Edit",
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
